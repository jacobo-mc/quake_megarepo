
void  ()medusa_possum_up =  {
   AdvanceFrame( 19.00000, 0.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( cycle_wrapped ) {

      self.think = self.th_run;

   }
};


void  ()medusa_playdead =  {
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   self.frame = 19.00000;
   self.think = medusa_playdead;
   self.nextthink = (time + 0.10000);
   ai_stand ();
};


void  ()medusa_die =  {
   AdvanceFrame( 0.00000, 19.00000);
   if ( (self.health <= -80.00000) ) {

      chunk_death ();
      return ;

   }
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( (self.frame == 19.00000) ) {

      MakeSolidCorpse ("remove");
   } else {

      if ( (self.frame == 0.00000) ) {

         sound (self, CHAN_VOICE, "medusa/death.wav", 1.00000, ATTN_NORM);

      }

   }
};


void  ()medusa_pain =  {
   AdvanceFrame( 78.00000, 88.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;
   } else {

      if ( (self.frame == 78.00000) ) {

         sound (self, CHAN_VOICE, "medusa/pain.wav", 1.00000, ATTN_NORM);

      }

   }
};


void  ()medusa_look_left =  {
   AdvanceFrame( 20.00000, 48.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( (self.frame <= 35.00000) ) {

      self.angle_ofs_y = ((self.frame - 20.00000) * 7.00000);
   } else {

      self.angle_ofs_y = ((48.00000 - self.frame) * 7.00000);

   }
   ai_walk (5.00000);
   if ( !FindTarget () ) {

      MedusaCheckAttack ();

   }
   if ( cycle_wrapped ) {

      self.think = self.oldthink;
      if ( (self.think != self.th_run) ) {

         if ( (random () < 0.20000) ) {

            self.think = medusa_look_left;

         }

      }

   }
};


void  ()medusa_look_right =  {
   AdvanceFrame( 49.00000, 77.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( (self.frame <= 64.00000) ) {

      self.angle_ofs_y = ((self.frame - 49.00000) * -7.00000);
   } else {

      self.angle_ofs_y = ((77.00000 - self.frame) * -7.00000);

   }
   ai_walk (5.00000);
   if ( !FindTarget () ) {

      MedusaCheckAttack ();

   }
   if ( cycle_wrapped ) {

      self.think = self.oldthink;
      if ( (self.think != self.th_run) ) {

         if ( (random () < 0.20000) ) {

            self.think = medusa_look_left;

         }

      }

   }
};


void  ()medusa_rattle_left =  {
   AdvanceFrame( 119.00000, 147.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;

   }
};


void  ()medusa_rattle_right =  {
   AdvanceFrame( 148.00000, 176.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;

   }
};


void  ()medusa_rattle =  {
   AdvanceFrame( 90.00000, 118.00000);
   if ( (self.model != "models/medusa.mdl") ) {

      setmodel (self, "models/medusa.mdl");
      setsize (self, '-16.00000 -16.00000 0.00000', '16.00000 16.00000 56.00000');

   }
   if ( cycle_wrapped ) {

      self.nextthink = time;
      self.think = self.th_run;

   }
};

