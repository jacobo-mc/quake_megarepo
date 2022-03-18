
void  ()ice_melt =  {
   self.scale -= 0.10000;
   if ( (self.scale < 0.10000) ) {

      remove (self);
   } else {

      self.think = ice_melt;

   }
   self.nextthink = (time + 0.10000);
};


void  ()ice_think =  {
   if ( (self.velocity == '0.00000 0.00000 0.00000') ) {

      self.touch = SUB_Null;
      self.think = ice_melt;
      self.nextthink = (time + 2.00000);
   } else {

      self.think = ice_think;
      self.nextthink = (time + 0.10000);

   }
};


void  ()ice_hit =  {
   if ( (random () < 0.20000) ) {

      particleexplosion (self.origin, 14.00000, 20.00000, 5.00000);
      remove (self);

   }
};


void  ()todust =  {
   particleexplosion (self.origin, self.aflag, 20.00000, 5.00000);
   remove (self);
};


void  ()pebble_hit =  {
   self.wait = (self.wait + 1.00000);
   sound (self, CHAN_BODY, "misc/rubble.wav", 1.00000, ATTN_NORM);
   if ( ((self.wait >= 3.00000) || (random () < 0.10000)) ) {

      todust ();
   } else {

      self.think = todust;
      self.nextthink = (time + 2.00000);

   }
};


void  ()ash_hit =  {
   sound (self, CHAN_BODY, "misc/rubble.wav", 1.00000, ATTN_NORM);
   self.wait = (self.wait + 1.00000);
   if ( ((self.wait >= 3.00000) || (random () < 0.20000)) ) {

      todust ();
   } else {

      self.think = todust;
      self.nextthink = (time + 1.00000);

   }
};


void  (vector org,vector dir,vector spin,string type,float ownerscale)throw_shard =  {
   newmis = spawn ();
   newmis.movetype = MOVETYPE_BOUNCE;
   newmis.solid = SOLID_TRIGGER;
   newmis.velocity = dir;
   newmis.avelocity = spin;
   newmis.scale = ((random () + 0.25000) * ownerscale);
   newmis.classname = "type";
   setmodel (newmis, "models/shard.mdl");
   if ( (type == "ice") ) {

      if ( (self.classname == "snowball") ) {

         newmis.scale *= 0.30000;

      }
      newmis.skin = 0.00000;
      newmis.frame = 0.00000;
      newmis.touch = ice_hit;
      newmis.think = ice_think;
      newmis.nextthink = (time + 1.00000);
      newmis.drawflags = (DRF_TRANSLUCENT + MLS_ABSLIGHT);
      newmis.abslight = 0.50000;
   } else {

      if ( (type == "pebbles") ) {

         newmis.skin = 1.00000;
         newmis.frame = rint (((random () * 1.00000) + 1.00000));
         newmis.touch = pebble_hit;
         newmis.speed = 16.00000;
         newmis.aflag = 10.00000;
      } else {

         if ( (type == "ashes") ) {

            newmis.skin = 2.00000;
            newmis.frame = rint (((random () * 1.00000) + 1.00000));
            newmis.touch = ash_hit;
            newmis.speed = 1.00000;
            newmis.aflag = 10.00000;

         }

      }

   }
   setsize (newmis, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
   setorigin (newmis, org);
};


void  ()shatter =  {
local vector dir = '0.00000 0.00000 0.00000';
local vector spin = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local float numshards = 0.00000;
local float maxshards = 0.00000;
local float rng = 0.00000;
local string type;
   if ( (self.scale == 0.00000) ) {

      self.scale = 1.00000;

   }
   if ( (self.classname == "snowball") ) {

      maxshards = ((random () * 2.00000) + 2.00000);
   } else {

      maxshards = ((random () * 3.00000) + 7.00000);

   }
   org = ((self.absmin + self.absmax) * 0.50000);
   if ( (self.deathtype == "ice shatter") ) {

      sound (self, CHAN_AUTO, "misc/fshatter.wav", 1.00000, ATTN_NORM);
      particleexplosion (org, 14.00000, 100.00000, 50.00000);
      rng = 600.00000;
      type = "ice";
   } else {

      if ( (self.deathtype == "stone crumble") ) {

         sound (self, CHAN_AUTO, "misc/sshatter.wav", 1.00000, ATTN_NORM);
         particleexplosion (org, 10.00000, 60.00000, 50.00000);
         rng = 450.00000;
         type = "pebbles";
      } else {

         if ( (self.deathtype == "burnt crumble") ) {

            sound (self, CHAN_AUTO, "misc/bshatter.wav", 1.00000, ATTN_NORM);
            particleexplosion (org, 1.00000, 60.00000, 50.00000);
            rng = 200.00000;
            type = "ashes";

         }

      }

   }
   while ( (numshards < maxshards) ) {

      dir_x = ((random () * rng) - 300.00000);
      dir_y = ((random () * rng) - (rng * 0.50000));
      dir_z = ((random () * rng) - (rng * 0.50000));
      spin_x = ((random () * 600.00000) - 300.00000);
      spin_y = ((random () * 600.00000) - 300.00000);
      spin_z = ((random () * 600.00000) - 300.00000);
      throw_shard (org, dir, spin, type, self.scale);
      numshards += 1.00000;

   }
   if ( (self.classname == "player") ) {

      return ;
   } else {

      remove (self);

   }
};

