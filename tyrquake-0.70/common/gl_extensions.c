/*
Copyright (C) 1996-1997 Id Software, Inc.
Copyright (C) 2013 Kevin Shanahan

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include <assert.h>
#include <string.h>

#include "console.h"
#include "cvar.h"
#include "glquake.h"
#include "qtypes.h"
#include "sys.h"

qboolean gl_npotable;
qboolean gl_texture_env_combine;

qboolean
GL_ExtensionCheck_String(const char *extension, const char *search)
{
    const int length = strlen(extension);
    while ((search = strstr(search, extension))) {
	if (!search[length] || search[length] == ' ')
	    return true;
	search += length;
    }

    return false;
}

qboolean
GL_ExtensionCheck(const char *extension)
{
    const char *search = (const char *)glGetString(GL_EXTENSIONS);
    return GL_ExtensionCheck_String(extension, search);
}

static qboolean gl_version_es;
static int gl_version_major;
static int gl_version_minor;

static inline qboolean
GL_VersionMinimum(int major, int minor)
{
    return gl_version_major > major || (gl_version_major == major && gl_version_minor >= minor);
}

void
GL_ParseVersionString(const char *version)
{
    char *gl_version, *token;

    if (!version)
        return;

    /* Get a writeable copy we can parse */
    gl_version = Z_StrDup(mainzone, version);

    /* OpenGL ES has a specific prefix, if found strip it off */
    if (!strncmp(gl_version, "OpenGL ES", 9)) {
        gl_version_es = true;
        token = strtok(gl_version, " .");
        token = strtok(NULL, " .");
        token = strtok(NULL, " .");
        gl_version_major = atoi(token);
        token = strtok(NULL, " .");
        gl_version_minor = atoi(token);
    } else {
        token = strtok(gl_version, " .");
        gl_version_major = atoi(token);
        token = strtok(NULL, " .");
        gl_version_minor = atoi(token);
    }

    Z_Free(mainzone, gl_version);
}

void
GL_ExtensionCheck_NPoT(void)
{
    gl_npotable = false;
    if (COM_CheckParm("-nonpot"))
	return;
    if (!GL_ExtensionCheck("GL_ARB_texture_non_power_of_two"))
	return;

    Con_DPrintf("Non-power-of-two textures available.\n");
    gl_npotable = true;
}

#ifdef DEBUG
void APIENTRY errorActiveTextureFunc(GLenum unused) { Sys_Error("%s: called without multitexture support!", __func__); }
#else
#define errorActiveTextureFunc NULL
#endif

void
GL_ExtensionCheck_MultiTexture()
{
    gl_mtexable = false;
    qglActiveTextureARB = errorActiveTextureFunc;
    qglClientActiveTexture = errorActiveTextureFunc;

    if (COM_CheckParm("-nomtex"))
        return;
    if (!GL_ExtensionCheck("GL_ARB_multitexture"))
        return;

    Con_Printf("ARB multitexture extensions found.\n");

    /* Check how many texture units there actually are */
    glGetIntegerv(GL_MAX_TEXTURE_UNITS, &gl_num_texture_units);
    if (gl_num_texture_units < 2) {
        Con_Printf("Only %i texture units, multitexture disabled.\n", gl_num_texture_units);
        return;
    }

    /* Retrieve function pointers for multitexture methods */
    qglActiveTextureARB = (lpActiveTextureFUNC)GL_GetProcAddress("glActiveTextureARB");
    qglClientActiveTexture = (lpClientStateFUNC)GL_GetProcAddress("glClientActiveTexture");

    if (!qglActiveTextureARB || !qglClientActiveTexture) {
        Con_Printf("ARB Multitexture symbols not found, disabled.\n");
        qglActiveTextureARB = errorActiveTextureFunc;
        qglClientActiveTexture = errorActiveTextureFunc;
        return;
    }

    Con_Printf("Multitexture enabled.  %i texture units available.\n", gl_num_texture_units);
    gl_mtexable = true;
}

void
GL_ExtensionCheck_Combine()
{
    gl_texture_env_combine = false;
    if (COM_CheckParm("-nocombine"))
        return;
    if (GL_VersionMinimum(1, 3))
        gl_texture_env_combine = true;
    else if (GL_ExtensionCheck("GL_ARB_texture_env_combine"))
        gl_texture_env_combine = true;
    else if (GL_ExtensionCheck("GL_EXT_texture_env_combine"))
        gl_texture_env_combine = true;
}


/*
 * Try to find a working version of automatic mipmap generation for
 * the special case of procedural textures (water/warp).
 */
lpGenerateMipmapFUNC qglGenerateMipmap;
void (*qglTexParameterGenerateMipmap)(GLboolean auto_mipmap);

static void APIENTRY qglGenerateMipmap_null(GLenum target) { };
static void qglTexParameterGenerateMipmap_null(GLboolean auto_mipmap) { };

static void
qglTexParameterGenerateMipmap_f(GLboolean auto_mipmap)
{
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, auto_mipmap);
}

#ifndef GL_GENERATE_MIPMAP_SGIS
#define GL_GENERATE_MIPMAP_SGIS 0x8191
#endif

static void
qglTexParameterGenerateMipmap_SGIS_f(GLboolean auto_mipmap)
{
    glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, auto_mipmap);
}

void
GL_ExtensionCheck_GenerateMipmaps()
{
    qglGenerateMipmap = NULL;
    qglTexParameterGenerateMipmap = NULL;

    if (GL_VersionMinimum(3, 0) || GL_ExtensionCheck("GL_ARB_framebuffer_object")) {
        /* New enough to use the recommended glGenerateMipmap function */
        qglGenerateMipmap = GL_GetProcAddress("glGenerateMipmap");
    } else if (GL_VersionMinimum(1, 4)) {
        /* Fall back to legacy GL_GENERATE_MIPMAP texture property */
        qglTexParameterGenerateMipmap = qglTexParameterGenerateMipmap_f;
    } else if (GL_ExtensionCheck("GL_SGIS_generate_mipmap")) {
        /* Fall back top legacy-legacy extension for older than GL 1.4 */
        qglTexParameterGenerateMipmap = qglTexParameterGenerateMipmap_SGIS_f;
    }

    /*
     * This is a bit of a hack.  Should be that we flag auto-mipmap
     * generation on the texture properties and use that to
     * conditionally enable mipmaps but this will do for now.
     */
    if (qglGenerateMipmap || qglTexParameterGenerateMipmap)
        texture_properties[TEXTURE_TYPE_TURB].mipmap = true;

    if (!qglGenerateMipmap)
        qglGenerateMipmap = qglGenerateMipmap_null;
    if (!qglTexParameterGenerateMipmap)
        qglTexParameterGenerateMipmap = qglTexParameterGenerateMipmap_null;
}


qboolean gl_buffer_objects_enabled;

void (APIENTRY *qglBindBuffer)(GLenum target, GLuint buffer);
void (APIENTRY *qglDeleteBuffers)(GLsizei n, const GLuint *buffers);
void (APIENTRY *qglGenBuffers)(GLsizei n, GLuint *buffers);
void (APIENTRY *qglBufferData)(GLenum target, GLsizeiptr size, const void *data, GLenum usage);
void (APIENTRY *qglBufferSubData)(GLenum target, GLintptr offset, GLsizeiptr size, const void *data);
void *(APIENTRY *qglMapBuffer)(GLenum target, GLenum access);

GLboolean (APIENTRY *qglUnmapBuffer)(GLenum target);
GLboolean (APIENTRY *qglIsBuffer)(GLuint buffer);

void
GL_ExtensionCheck_BufferObjects()
{
    gl_buffer_objects_enabled = false;
    if (COM_CheckParm("-noglbuffers"))
        return;

    if (GL_VersionMinimum(2, 1)) {
        qglGenBuffers    = GL_GetProcAddress("glGenBuffers");
        qglDeleteBuffers = GL_GetProcAddress("glDeleteBuffers");
        qglBindBuffer    = GL_GetProcAddress("glBindBuffer");
        qglBufferData    = GL_GetProcAddress("glBufferData");
        qglBufferSubData = GL_GetProcAddress("glBufferSubData");
        qglMapBuffer     = GL_GetProcAddress("glMapBuffer");
        qglUnmapBuffer   = GL_GetProcAddress("glUnmapBuffer");
        qglIsBuffer      = GL_GetProcAddress("glIsBuffer");
    } else if (GL_ExtensionCheck("GL_ARB_vertex_buffer_object")) {
        qglGenBuffers    = GL_GetProcAddress("glGenBuffersARB");
        qglDeleteBuffers = GL_GetProcAddress("glDeleteBuffersARB");
        qglBindBuffer    = GL_GetProcAddress("glBindBufferARB");
        qglBufferData    = GL_GetProcAddress("glBufferDataARB");
        qglBufferSubData = GL_GetProcAddress("glBufferSubDataARB");
        qglMapBuffer     = GL_GetProcAddress("glMapBufferARB");
        qglUnmapBuffer   = GL_GetProcAddress("glUnmapBufferARB");
        qglIsBuffer      = GL_GetProcAddress("glIsBufferARB");
    }

    /* Enabled if we got all the function pointers */
    gl_buffer_objects_enabled =
        qglGenBuffers    &&
        qglDeleteBuffers &&
        qglBindBuffer    &&
        qglBufferData    &&
        qglBufferSubData &&
        qglMapBuffer     &&
        qglUnmapBuffer   &&
        qglIsBuffer;

    if (gl_buffer_objects_enabled)
        Con_Printf("***** GL Buffer Objects Enabled!\n");
}

qboolean gl_vertex_program_enabled;

void (APIENTRY *qglProgramString)(GLenum target, GLenum format, GLsizei len, const void *string);
void (APIENTRY *qglBindProgram)(GLenum target, GLuint program);
void (APIENTRY *qglDeletePrograms)(GLsizei n, const GLuint *programs);
void (APIENTRY *qglGenPrograms)(GLsizei n, GLuint *programs);
void (APIENTRY *qglProgramEnvParameter4f)(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void (APIENTRY *qglProgramEnvParameter4fv)(GLenum target, GLuint index, const GLfloat *params);
void (APIENTRY *qglProgramLocalParameter4f)(GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void (APIENTRY *qglProgramLocalParameter4fv)(GLenum target, GLuint index, const GLfloat *params);
void (APIENTRY *qglGetProgramiv)(GLenum target, GLenum pname, GLint *params);
void (APIENTRY *qglGetProgramString)(GLenum target, GLenum pname, void *string);
void (APIENTRY *qglEnableVertexAttribArray)(GLuint index);
void (APIENTRY *qglDisableVertexAttribArray)(GLuint index);
void (APIENTRY *qglVertexAttribPointer)(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer);
GLboolean (APIENTRY *qglIsProgram)(GLuint program);

static qboolean
GL_ProgramFunctionsAreLoaded()
{
    return
        qglProgramString            &&
        qglBindProgram              &&
        qglDeletePrograms           &&
        qglGenPrograms              &&
        qglProgramLocalParameter4f  &&
        qglProgramLocalParameter4fv &&
        qglProgramEnvParameter4f    &&
        qglProgramEnvParameter4fv   &&
        qglEnableVertexAttribArray  &&
        qglDisableVertexAttribArray &&
        qglVertexAttribPointer      &&
        qglIsProgram;
}

static qboolean
GL_LoadProgramFunctions()
{
    if (GL_ProgramFunctionsAreLoaded())
        return true;

    if (GL_ExtensionCheck("GL_ARB_vertex_program") || GL_ExtensionCheck("GL_ARB_fragment_program")) {
        qglProgramString            = GL_GetProcAddress("glProgramStringARB");
        qglBindProgram              = GL_GetProcAddress("glBindProgramARB");
        qglDeletePrograms           = GL_GetProcAddress("glDeleteProgramsARB");
        qglGenPrograms              = GL_GetProcAddress("glGenProgramsARB");
        qglProgramLocalParameter4f  = GL_GetProcAddress("glProgramLocalParameter4fARB");
        qglProgramLocalParameter4fv = GL_GetProcAddress("glProgramLocalParameter4fvARB");
        qglProgramEnvParameter4f    = GL_GetProcAddress("glProgramEnvParameter4fARB");
        qglProgramEnvParameter4fv   = GL_GetProcAddress("glProgramEnvParameter4fvARB");
        qglEnableVertexAttribArray  = GL_GetProcAddress("glEnableVertexAttribArrayARB");
        qglDisableVertexAttribArray = GL_GetProcAddress("glDisableVertexAttribArrayARB");
        qglVertexAttribPointer      = GL_GetProcAddress("glVertexAttribPointerARB");
        qglIsProgram                = GL_GetProcAddress("glIsProgramARB");
    }

    return GL_ProgramFunctionsAreLoaded();
}

void
GL_ExtensionCheck_VertexProgram()
{
    gl_vertex_program_enabled = false;
    if (COM_CheckParm("-noglvertexprogram"))
        return;

    gl_vertex_program_enabled = GL_ExtensionCheck("GL_ARB_vertex_program") && GL_LoadProgramFunctions();
    if (gl_vertex_program_enabled)
        Con_Printf("***** GL Vertex Program Enabled!\n");
}

// Need to track these program/shader resources and re-init if context goes away
struct vertex_programs vp;

/* Interpolate animation, handle base texture + fullbright and fog coord */
static const char *alias_lerp_vp_text =
    "!!ARBvp1.0\n"
    "\n"
    "ATTRIB pos0        = vertex.position;\n"       // 0
    "ATTRIB pos1        = vertex.attrib[1];\n"      // 1 (usually weight)
    "ATTRIB norm0       = vertex.normal;\n"         // 2
    "ATTRIB norm1       = vertex.attrib[3];\n"      // 3 (usually color)
    "PARAM  mat[4]      = { state.matrix.mvp };\n"
    "PARAM  lerp0       = program.local[0];\n"
    "PARAM  lerp1       = program.local[1];\n"
    "PARAM  shadevector = program.local[2];\n"
    "PARAM  shadelight  = program.local[3];\n"
    "\n"
    "# Interpolate the vertex positions 0 and 1\n"
    "TEMP   lerpPos;\n"
    "MUL    lerpPos, pos0, lerp0;\n"
    "MAD    lerpPos, pos1, lerp1, lerpPos;\n"
    "\n"
    "# Interpolate normals\n"
    "TEMP   lerpNorm;\n"
    "MUL    lerpNorm, norm0, lerp0;\n"
    "MAD    lerpNorm, norm1, lerp1, lerpNorm;\n"
    "\n"
    "# Calculate lighting.  Shadevector is in model space, so no need to transform normal\n"
    "TEMP shadedot, dothigh, dotlow;\n"
    "DP3 shadedot, lerpNorm, shadevector;\n"
    "ADD dothigh, shadedot, 1.0;\n"
    "MAD dotlow, shadedot, 0.2954545, 1.0;\n"
    "MAX shadedot, dotlow, dothigh;\n"
    "MUL result.color, shadedot, shadelight;\n"
    "\n"
    "# Transform by concatenation of the MODELVIEW and PROJECTION matrices.\n"
    "TEMP   pos;\n"
    "DP4    pos.x, mat[0], lerpPos;\n"
    "DP4    pos.y, mat[1], lerpPos;\n"
    "DP4    pos.z, mat[2], lerpPos;\n"
    "DP4    pos.w, mat[3], lerpPos;\n"
    "MOV    result.position, pos;\n"
    "MOV    result.fogcoord, pos.z;\n"
    "\n"
    "# Pass two layers of texcoords unchanged.\n"
    "MOV    result.texcoord, vertex.texcoord;\n"
    "MOV    result.texcoord[1], vertex.texcoord[1];\n"
    "END\n";

/* No lerping case */
static const char *alias_nolerp_vp_text =
    "!!ARBvp1.0\n"
    "\n"
    "ATTRIB pos0        = vertex.position;\n"       // 0
    "ATTRIB norm0       = vertex.normal;\n"         // 2
    "PARAM  mat[4]      = { state.matrix.mvp };\n"
    "PARAM  shadevector = program.local[2];\n"
    "PARAM  shadelight  = program.local[3];\n"
    "\n"
    "# Calculate lighting.  Shadevector is in model space, so no need to transform normal\n"
    "TEMP shadedot, dothigh, dotlow;\n"
    "DP3 shadedot, norm0, shadevector;"
    "ADD dothigh, shadedot, 1.0;\n"
    "MAD dotlow, shadedot, 0.2954545, 1.0;\n"
    "MAX shadedot, dotlow, dothigh;\n"
    "MUL result.color, shadedot, shadelight;\n"
    "\n"
    "# Transform by concatenation of the MODELVIEW and PROJECTION matrices.\n"
    "TEMP   pos;\n"
    "DP4    pos.x, mat[0], pos0;\n"
    "DP4    pos.y, mat[1], pos0;\n"
    "DP4    pos.z, mat[2], pos0;\n"
    "DP4    pos.w, mat[3], pos0;\n"
    "MOV    result.position, pos;\n"
    "MOV    result.fogcoord, pos.z;\n"
    "\n"
    "# Pass the texcoords unchanged.\n"
    "MOV    result.texcoord, vertex.texcoord;\n"
    "MOV    result.texcoord[1], vertex.texcoord[1];\n"
    "END\n";

static const char *
ProgramTypeString(GLenum program_type)
{
    switch (program_type) {
        case GL_VERTEX_PROGRAM_ARB: return "vertex";
        case GL_FRAGMENT_PROGRAM_ARB: return "fragment";
        default: assert(!"Invalid program type");
    }

    return "";
}

static qboolean
GL_CompileProgram(GLenum program_type, GLuint handle, const char *text)
{
    qglBindProgram(program_type, handle);
    qglProgramString(program_type, GL_PROGRAM_FORMAT_ASCII_ARB, strlen(text), text);
    qglBindProgram(program_type, 0);

    GLuint error = glGetError();
    if (!error)
        return true;

    Con_DPrintf("%s program error code %d (0x%x)\n", ProgramTypeString(program_type), error, error);
    const char *error_message = (const char *)glGetString(GL_PROGRAM_ERROR_STRING_ARB);
    int error_position;
    glGetIntegerv(GL_PROGRAM_ERROR_POSITION_ARB, &error_position);

    Con_DPrintf("Error Message: %s\n", error_message);
    Con_DPrintf("Error Position: %d\n", error_position);
    Con_DPrintf("Text near error: %.20s\n", text + error_position);

    return false;
}

void
GL_InitVertexPrograms()
{
    if (!gl_vertex_program_enabled)
        return;

    qglGenPrograms(ARRAY_SIZE(vp.handles), vp.handles);

    qboolean success = true;
    success &= GL_CompileProgram(GL_VERTEX_PROGRAM_ARB, vp.alias_lerp, alias_lerp_vp_text);
    success &= GL_CompileProgram(GL_VERTEX_PROGRAM_ARB, vp.alias_nolerp, alias_nolerp_vp_text);
    success &= GL_CompileProgram(GL_VERTEX_PROGRAM_ARB, vp.warp, warp_vp_text);

    /* If some vertex programs failed to compile, disable the feature */
    if (!success) {
        Con_SafePrintf(
            "WARNING: Some vertex programs failed to compile.\n"
            "         Vertex programs will be disabled.\n"
            "         Enable developer mode for further info.\n"
        );
        gl_vertex_program_enabled = false;
    }
}


/*
 * Fragment Programs
 */
qboolean gl_fragment_program_enabled;

void
GL_ExtensionCheck_FragmentProgram()
{
    gl_fragment_program_enabled = false;
    if (COM_CheckParm("-noglfragmentprogram"))
        return;

    gl_fragment_program_enabled = GL_ExtensionCheck("GL_ARB_fragment_program") && GL_LoadProgramFunctions();
    if (gl_vertex_program_enabled)
        Con_Printf("***** GL Fragment Program Enabled!\n");
}

struct fragment_programs fp;

void
GL_InitFragmentPrograms()
{
    if (!gl_fragment_program_enabled)
        return;

    qglGenPrograms(ARRAY_SIZE(fp.handles), fp.handles);

    qboolean success = true;
    success &= GL_CompileProgram(GL_FRAGMENT_PROGRAM_ARB, fp.warp, warp_fp_text);
    success &= GL_CompileProgram(GL_FRAGMENT_PROGRAM_ARB, fp.warp_fog, warp_fog_fp_text);

    if (!success) {
        Con_SafePrintf(
            "WARNING: Some fragment programs failed to compile.\n"
            "         Fragment programs will be disabled.\n"
            "         Enable developer mode for further info.\n"
        );
        gl_fragment_program_enabled = false;
    }
}

/*
 * Prefer glDrawRangeElements, but we can fall back to glDrawElements
 */
void (APIENTRY *qglDrawRangeElements)(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices);

static void APIENTRY
qglDrawRangeElements_Compat(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices)
{
    glDrawElements(mode, count, type, indices);
}

void
GL_ExtensionCheck_RangeElements()
{
    qglDrawRangeElements = NULL;

    if (GL_VersionMinimum(1, 2)) {
        qglDrawRangeElements = GL_GetProcAddress("glDrawRangeElements");
    } else if (GL_ExtensionCheck("GL_EXT_draw_range_elements")) {
        qglDrawRangeElements = GL_GetProcAddress("glDrawRangeElementsEXT");
    }

    if (qglDrawRangeElements) {
        GLint max_vertices;
        GLint max_indices;

        glGetIntegerv(GL_MAX_ELEMENTS_VERTICES, &max_vertices);
        glGetIntegerv(GL_MAX_ELEMENTS_INDICES, &max_indices);

        /*
         * Setup material_max_verts so we don't exceed the perfomant
         * glDrawRangeElements maximums for the driver
         */
        int32_t driver_max_verts = qmin(MATERIAL_ABSOLUTE_MAX_VERTS, max_vertices);
        driver_max_verts = qmin(driver_max_verts, max_indices / 3);
        Con_DPrintf(" ** DrawRangeElements - max vertices: %d, max_indices %d\n", max_vertices, max_indices);
        Con_DPrintf(" ** Driver Max Verts - %d\n", driver_max_verts);

        /*
         * If we end up with something really low, probably better to fall
         * back to glDrawElements and let the driver sort out partitioning
         */
        if (driver_max_verts >= 256) {
            GL_SetMaxVerts(driver_max_verts);
            return;
        }
    }

    /* Fall back to regular old glDrawElements */
    GL_SetMaxVerts(MATERIAL_DEFAULT_MAX_VERTS);
    qglDrawRangeElements = qglDrawRangeElements_Compat;
}

qboolean gl_texture_compression_enabled;
void (APIENTRY *qglCompressedTexImage2D)(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *data);

static void APIENTRY qglCompressedTexImage2D_null(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *data) { assert(false); }

void
GL_ExtensionCheck_TextureCompression()
{
    gl_texture_compression_enabled = false;
    qglCompressedTexImage2D = qglCompressedTexImage2D_null;

    if (COM_CheckParm("-noglcompression"))
        return;

    qboolean api_available = false;
    qboolean formats_available = false;

    if (GL_VersionMinimum(1, 3) || GL_ExtensionCheck("GL_ARB_texture_compression")) {
        /* Compressed API functions should be available */
        api_available = true;
    }
    if (GL_ExtensionCheck("GL_EXT_texture_compression_s3tc")) {
        /* S3TC Extension implies the API and Formats are available */
        api_available = true;
        formats_available = true;
    }
    if (!api_available)
        return;

    qglCompressedTexImage2D = GL_GetProcAddress("glCompressedTexImage2D");
    if (!qglCompressedTexImage2D)
        return;

    if (!formats_available) {
        /* Query for the available compression formats */
        GLint num_formats = 0;
        GLint *formats;

        glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, &num_formats);
        if (!num_formats)
            return;
        formats = alloca(num_formats * sizeof(*formats));
        glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, formats);

        qboolean have_dxt1 = false;
        qboolean have_dxt5 = false;
        for (int i = 0; i < num_formats; i++) {
            if (formats[i] == GL_COMPRESSED_RGB_S3TC_DXT1_EXT)
                have_dxt1 = true;
            if (formats[i] == GL_COMPRESSED_RGBA_S3TC_DXT5_EXT)
                have_dxt5 = true;
        }

        if (have_dxt1 && have_dxt5)
            formats_available = true;
    }

    if (formats_available) {
        gl_texture_compression_enabled = true;
        Con_Printf("Texture compression enabled (dxt1/5)\n");
    }
}

qboolean gl_anisotropy_enabled;
float gl_anisotropy_max;

void
GL_ExtensionCheck_Anisotropy()
{
    gl_anisotropy_enabled = false;
    gl_anisotropy_max = 1.0f;

    if (!GL_ExtensionCheck("GL_EXT_texture_filter_anisotropic") && !GL_VersionMinimum(4, 6))
        return;

    /* Test to make sure we can set it */
    float test1, test2;
    GLuint texture;

    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY, 1.0f);
    glGetTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY, &test1);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY, 2.0f);
    glGetTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY, &test2);
    glDeleteTextures(1, &texture);

    gl_anisotropy_enabled = true;
    glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY, &gl_anisotropy_max);

    if (test1 == 1.0f && test2 == 2.0f) {
        Con_Printf("Anisotropic filtering enabled\n");
    } else {
        Con_Printf("Anisotropic filtering locked by driver.  Current setting is %f\n", test2);
    }
}
