# Mapping tools
You will need:
- Ericw Tyrutils
- TrenchBroom or NetRadient

# Standard Mapping Procedures
If you are making a map for the game that you would like to submit, your map must be compiled using the following commands in order:
1. `qbsp map.map map.bsp`
2. `light -extra4 -dirt -dirtdebug -dirtdepth 128 map.bsp`
3. `vis map.bsp`

You map should also:
- Only use `slingbase/textures/sling.wad` as a texture source.
- Reference `slingbase/textures/sling.wad` in a relative fashion, which means to select "relative to map file" in TrenchBroom when adding a wad to a map.
- Be created and compiled in `slingbase/mapsource/` for organization.
- Never use any light entities.
- Never set any light flags such as `_sunlight`
- Never use any entities that require a Quake model (except for player spawns).
- Must have at least one intermission entity, and intermissions must be enabled (they are enabled by default).
- Your map is allowed to use teleporters, push entities, plats, doors, buttons, or any other entity that must be attached to a brush, and has a physical effect on the map.

Following these procedures will make your map eligible for submission.
