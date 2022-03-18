
void  ()ForceFieldDie =  {
   self.owner.flags2 -= FL_SHIELDED;
   remove (self);
};


void  ()ForceFieldPain =  {
   if ( (self.pain_finished > time) ) {

      return ;

   }
   sound (self, CHAN_AUTO, "misc/pulse.wav", 1.00000, ATTN_NORM);
   stuffcmd (self.owner, "bf\n");
   self.pain_finished = (time + 1.00000);
   if ( (self.drawflags & MLS_POWERMODE) ) {

      self.drawflags = (MLS_ABSLIGHT + DRF_TRANSLUCENT);
      self.abslight = 1.00000;

   }
};


void  ()ForceFieldThink =  {
   if ( (self.pain_finished < time) ) {

      if ( (self.drawflags & MLS_ABSLIGHT) ) {

         self.drawflags = (MLS_POWERMODE + DRF_TRANSLUCENT);
         self.abslight = 0.50000;

      }

   }
   self.angles = self.owner.angles;
   self.frame = self.owner.frame;
   setorigin (self, self.owner.origin);
   if ( (self.wait < time) ) {

      ForceFieldDie ();
   } else {

      if ( (self.wait < (time + 4.00000)) ) {

         if ( (self.air_finished < time) ) {

            self.air_finished = (time + 1.00000);
            sound (self, CHAN_AUTO, "misc/pulse.wav", 1.00000, ATTN_NORM);
            stuffcmd (self.owner, "bf\n");
            centerprint (self.owner, "Force Field running out...\n");
            self.drawflags = (self.drawflags - 2.00000);
            self.drawflags = (self.drawflags + 1.00000);

         }

      }

   }
   self.think = ForceFieldThink;
   self.nextthink = (time + 0.10000);
};


void  ()MakeForceField =  {
   if ( (self.flags2 & FL_SHIELDED) ) {

      return ;

   }
   centerprint (self, "Force Field active\n");
   sound (self, CHAN_AUTO, "misc/pulse.wav", 1.00000, ATTN_NORM);
   stuffcmd (self, "bf\n");
   self.shield = spawn ();
   self.shield.owner = self;
   self.shield.movetype = MOVETYPE_NOCLIP;
   self.shield.solid = SOLID_NOT;
   self.shield.health = 200.00000;
   self.shield.th_die = ForceFieldDie;
   self.shield.th_pain = ForceFieldPain;
   self.flags2 += FL_SHIELDED;
   self.shield.wait = (time + 180.00000);
   setmodel (self.shield, self.model);
   self.shield.frame = self.frame;
   self.shield.drawflags = (DRF_TRANSLUCENT + MLS_POWERMODE);
   self.shield.scale = 1.30000;
   setsize (self.shield, '-24.00000 -24.00000 -12.00000', '24.00000 24.00000 80.00000');
   setorigin (self.shield, self.origin);
   self.shield.think = ForceFieldThink;
   self.shield.nextthink = time;
};

