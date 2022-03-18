
void  ()soul_touch =  {
   if ( !(other.flags2 & FL_ALIVE) ) {

      return ;

   }
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
   if ( ((other.classname == "player") && (other.playerclass == CLASS_NECROMANCER)) ) {

      sound (self, CHAN_VOICE, "items/artpkup.wav", 1.00000, ATTN_NORM);
      other.health = (other.health + self.health);
      other.bluemana = (other.bluemana + self.bluemana);
      other.greenmana = (other.greenmana + self.greenmana);
      remove (self);
   } else {

      if ( ((other.classname == "player") && (other.playerclass != CLASS_NECROMANCER)) ) {

         T_Damage (other, self, self, 1.00000);

      }

   }
};


void  ()soul_move =  {
local vector vel = '0.00000 0.00000 0.00000';
local float life = 0.00000;
   self.velocity_z = (self.velocity_z + self.hoverz);
   if ( (self.velocity_z > 16.00000) ) {

      self.hoverz = -1.00000;
   } else {

      if ( (self.velocity_z < -16.00000) ) {

         self.hoverz = 1.00000;

      }

   }
   vel_x = (crandom () * 720.00000);
   vel_y = (crandom () * 720.00000);
   vel_z = (crandom () * 720.00000);
   particle2 (self.origin, (vel * 0.00200), (vel * 0.00200), 120.00000, PARTICLETYPE_C_EXPLODE, self.health);
   vel_x = (crandom () * -720.00000);
   vel_y = (crandom () * -720.00000);
   vel_z = (crandom () * -720.00000);
   particle2 (self.origin, (vel * 0.00200), (vel * 0.00200), 120.00000, PARTICLETYPE_C_EXPLODE, self.health);
   self.health = (self.health - 0.10000);
   self.think = soul_move;
   self.nextthink = (time + 0.10000);
   if ( (self.health <= 0.00000) ) {

      sound (self, CHAN_VOICE, "misc/null.wav", 1.00000, ATTN_NORM);
      remove (self);

   }
};


void  ()makesound =  {
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
};


void  ()soul_sphere =  {
   self.owner = self;
   self.solid = SOLID_TRIGGER;
   self.movetype = MOVETYPE_FLY;
   setorigin (self, (self.origin + '0.00000 0.00000 16.00000'));
   precache_model ("models/s_light.spr");
   setmodel (self, "models/s_light.spr");
   setsize (self, self.mins, self.maxs);
   self.touch = soul_touch;
   self.think = soul_move;
   self.nextthink = (time + 0.10000);
   self.hoverz = 1.00000;
   self.velocity_z = self.hoverz;
   self.flags = 0.00000;
   self.lifespan = 15.00000;
   self.health = self.lifespan;
   precache_sound ("raven/soul.wav");
   self.noise = "raven/soul.wav";
   sound (self, CHAN_VOICE, self.noise, 1.00000, ATTN_NORM);
};


void  ()spawnsoul_sphere =  {
local entity new;
   new = spawn ();
   new.owner = new;
   new.solid = SOLID_TRIGGER;
   new.movetype = MOVETYPE_FLY;
   droptofloor ();
   setorigin (new, (self.origin + '0.00000 0.00000 16.00000'));
   setmodel (new, "models/s_light.spr");
   setsize (new, new.mins, new.maxs);
   new.touch = soul_touch;
   new.think = soul_move;
   new.nextthink = (time + 0.10000);
   new.hoverz = 1.00000;
   new.velocity_z = new.hoverz;
   new.flags = 0.00000;
   new.lifespan = 15.00000;
   new.health = ((new.lifespan * 10.00000) * 0.20000);
   new.noise = "raven/soul.wav";
   sound (new, CHAN_VOICE, new.noise, 1.00000, ATTN_NORM);
};

