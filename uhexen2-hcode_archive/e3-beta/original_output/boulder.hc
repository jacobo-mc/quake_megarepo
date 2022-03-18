void  ()boulder_find_path;

void  (entity targ)boulder_moveto_target =  {
   SUB_CalcMove (targ.origin, 50.00000, boulder_find_path);
   if ( !targ.target ) {

      remove (self);
   } else {

      self.target = targ.target;

   }
};


void  ()boulder_next =  {
local entity targ;
   dprint ("finding path\n");
   targ = find (world, targetname, self.target);
   if ( !targ ) {

      remove (self);

   }
   boulder_moveto_target (targ);
};


void  ()boulder_find_path =  {
local entity targ;
   dprint ("finding path\n");
   targ = find (world, targetname, self.target);
   if ( !targ ) {

      remove (self);

   }
   self.target = targ.target;
   self.nextthink = (self.ltime + 0.10000);
   self.think = boulder_next;
};


vector  ()BoulderChunkVelocity =  {
local vector v = '0.00000 0.00000 0.00000';
   v_x = (200.00000 * crandom ());
   v_y = (200.00000 * crandom ());
   v_z = (200.00000 + (100.00000 * random ()));
   v = (v * 0.70000);
   return ( v );
};


void  (vector space)BoulderCreateSpriteChunks =  {
local entity sprite;
   sprite = spawn ();
   space_x = (space_x * random ());
   space_y = (space_y * random ());
   space_z = (space_z * random ());
   setorigin (sprite, (self.absmin + space));
   setmodel (sprite, "gfx/stone.spr");
   setsize (sprite, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   sprite.movetype = MOVETYPE_BOUNCE;
   sprite.solid = SOLID_NOT;
   sprite.velocity = BoulderChunkVelocity ();
   sprite.think = SUB_Remove;
   sprite.ltime = time;
   sprite.nextthink = ((time + 1.00000) + (random () * 1.00000));
};


void  (vector space)BoulderCreateModelChunks =  {
local entity chunk;
local float final = 0.00000;
   chunk = spawn ();
   space_x = (space_x * random ());
   space_y = (space_y * random ());
   space_z = (space_z * random ());
   setorigin (chunk, (self.absmin + space));
   setmodel (chunk, "models/gib1.mdl");
   setsize (chunk, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   chunk.movetype = MOVETYPE_BOUNCE;
   chunk.solid = SOLID_NOT;
   chunk.velocity = BoulderChunkVelocity ();
   chunk.think = SUB_Remove;
   chunk.avelocity_x = (random () * 1200.00000);
   chunk.avelocity_y = (random () * 1200.00000);
   chunk.avelocity_z = (random () * 1200.00000);
   chunk.ltime = time;
   chunk.nextthink = ((time + 1.00000) + random ());
};


void  ()boulder_die =  {
local vector space = '0.00000 0.00000 0.00000';
local float holdcount = 0.00000;
local float spritecount = 0.00000;
local float chunkcount = 0.00000;
   space = (self.absmax - self.absmin);
   holdcount = ((space_x + space_y) + space_z);
   spritecount = (holdcount / 8.00000);
   chunkcount = (holdcount / 16.00000);
   sound (self, CHAN_VOICE, "raven/wallbrk.wav", 1.00000, ATTN_NORM);
   while ( (spritecount > 0.00000) ) {

      spritecount = (spritecount - 1.00000);

   }
   while ( (chunkcount > 0.00000) ) {

      BoulderCreateModelChunks (space);
      chunkcount = (chunkcount - 1.00000);

   }
   remove (self);
};


void  ()boulder_crush =  {
   dprint ("Crusha!\n");
   T_Damage (other, self, self, 50.00000);
};


void  ()boulder_use =  {
   self.velocity_x = (100.00000 * random ());
   self.velocity_y = (100.00000 * random ());
   self.velocity_z = 400.00000;
   self.avelocity_x = (random () * 1200.00000);
   self.avelocity_y = (random () * 1200.00000);
   self.avelocity_z = (random () * 1200.00000);
   self.movetype = MOVETYPE_BOUNCE;
};


void  ()trap_boulder =  {
local entity boulder;
   boulder = spawn ();
   precache_model ("models/boulder.mdl");
   setmodel (self, "models/boulder.mdl");
   self.health = 75.00000;
   self.max_health = self.health;
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_BOUNCE;
   self.th_die = boulder_die;
   self.blocked = boulder_crush;
   self.takedamage = DAMAGE_YES;
   self.think = boulder_find_path;
   self.nextthink = (self.ltime + 0.10000);
};

