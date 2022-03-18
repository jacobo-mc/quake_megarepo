// WSS audio library, latest update: 1.9.2010
#ifndef X86DATATYPE
typedef unsigned char		BYTE;
typedef unsigned short		WORD;
typedef unsigned long		DWORD;
typedef int BOOL;
#define X86DATATYPE

#endif

#ifndef FALSE
#define FALSE	0
#endif

#ifndef TRUE
#define TRUE	!FALSE
#endif


int w_sound_device_init(int device_no, int rate_no);
void w_sound_device_exit(void);

void w_clear_buffer(void);
DWORD w_get_buffer_size(void);

void w_set_device_master_volume(int volume);
void w_set_master_volume(int volume);
void w_reverse_stereo(int flag);
void w_set_sb_cursor_offset(int offset);

void w_set_watermark(float latency, DWORD samples_per_frame);
int w_get_watermark_status(void);

void w_reset_watermark(void);
void w_reset_watermark_ex(DWORD samplecount);
void w_reset_write_cursor(DWORD samplecount);

DWORD w_get_play_cursor(void);
DWORD w_get_write_cursor(void);
void  w_set_write_cursor(DWORD position);
DWORD w_calc_distance(DWORD cursor1, DWORD cursor2);
DWORD w_calc_position(DWORD cursor1, DWORD cursor2);

DWORD w_get_requested_sample_count(void);
DWORD w_get_latency(void);
DWORD w_adjust_latency_for_vsync(void);


DWORD w_get_nominal_sample_rate(void);
DWORD w_get_actual_sample_rate(void);
float w_calc_samples_per_vsync(void (*__vsync)(void), int vsync_count);

char *w_get_device_name(void);
char *w_get_error_message(void);


DWORD w_get_current_req(void);
DWORD w_get_next_req(void);

void w_lock_mixing_buffer(int currentsamplecount);
void w_unlock_mixing_buffer(void);
void w_mixing(short data[], DWORD length, int leftvol, int rightvol);
void w_mixing_stereo(short data[], DWORD length, int leftvol, int rightvol);
void w_mixing8(char data[], DWORD length, int leftvol, int rightvol);
void w_mixing_zero(void);

void w_enter_critial(void);
void w_exit_critial(void);

void vga_vsync(void);
