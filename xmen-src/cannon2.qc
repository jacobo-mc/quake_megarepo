// Cannonball's Special attack code

$frame xatta6 xatta7 xatta8 xatta9 xatta10 xatta11 xatta12 xatta13
$frame xatta14 xatta15 xatta16 xatta17 xatta18 xatta19 xatta20 xatta21
$frame xatta22 xatta23

$frame fly1 fly2 fly3

void() cannon_xatta16;
void() cannon_xatta18;

void() CannonFlyTouch =
{
   self.velocity = '0 0 0';

   if (other != self.enemy) {     // abort attack
      sound(self, CHAN_BODY, "generic/crash1.wav", 1, ATTN_NORM);
      self.x_flags = self.x_flags | X_CANNONFLYABORT;

//      cannon_xatta19();
      return;
   }

   cannon_xatta16();
};

void() CannonFlyThink =
{
   if (self.x_flags & X_CANNONFLYABORT) {
      cannon_xatta18();
      return;
   }

   ai_face();

   if (!ai_forward(20)) {
      if (self.oldorigin != '0 0 0')
         setorigin(self, self.oldorigin);

      other = world;

      if (infront(self.enemy) && (vlen(self.enemy.origin - self.origin) < 80))
         other = self.enemy;

      CannonFlyTouch();
   }
   else {
      self.oldorigin = self.origin;
   }

   if (self.last_flame_sound < (time - 0.75)) {
      if (self.last_weapon_channel != CHAN_WEAPON) {
        sound (self, CHAN_WEAPON, "cannon/flyloop.wav", 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_WEAPON;
      } else {
        sound (self, CHAN_BODY, "cannon/flyloop.wav", 1, ATTN_NORM);
        self.last_weapon_channel = CHAN_BODY;
      }

      self.last_flame_sound = time;
   }

   ai_face();

   self.nextthink = time + 0.05;
};

void() cannon_xatta7  = [   $xatta7,    cannon_xatta8  ]
{
   setmodel(self, "progs/cannon2.mdl");
   self.flags = self.flags | FL_GODMODE;
   ai_forward(3);
};
void() cannon_xatta8  = [   $xatta8,    cannon_xatta9  ] {ai_forward(6); ai_face();};
void() cannon_xatta9  = [   $xatta9,    cannon_xatta10 ] {ai_forward(9); ai_face();};
void() cannon_xatta10 = [   $xatta10,   cannon_xatta11 ] {ai_forward(12); ai_face();};
void() cannon_xatta11 = [   $xatta11,   cannon_xatta12 ] {ai_forward(15); ai_face();};
void() cannon_xatta12 = [   $xatta12,   cannon_xatta13 ]
{
   ai_forward(18);
   self.oldorigin = '0 0 0';
   self.x_flags = self.x_flags - (self.x_flags & X_CANNONFLYABORT);
};
void() cannon_xatta13 = [   $xatta13,   cannon_xatta14 ] {CannonFlyThink();};
void() cannon_xatta14 = [   $xatta14,   cannon_xatta15 ] {CannonFlyThink();};
void() cannon_xatta15 = [   $xatta15,   cannon_xatta13 ] {CannonFlyThink();};
void() cannon_xatta16 = [   $xatta16,   cannon_xatta17 ] {ai_forward(15); sound (self, CHAN_ITEM, "generic/swing1.wav", 1, ATTN_NORM);};
void() cannon_xatta17 = [   $xatta17,   cannon_xatta18 ] {ai_forward(10);};
void() cannon_xatta18 = [   $xatta18,   cannon_xatta19 ]
{
   local vector   vect;

   if (self.x_flags & X_CANNONFLYABORT) {
      self.x_flags = self.x_flags - X_CANNONFLYABORT;
      return;
   }

   self.last_special = time;

   // do some damage
   T_Damage(self.enemy, self, self, 30);

   sound (self, CHAN_WEAPON, "generic/punch2.wav", 1, ATTN_NORM);

   vect = normalize(self.enemy.origin - self.origin);
   self.enemy.velocity = vect * 300;
   self.enemy.velocity_z = 300;
   self.enemy.punchangle_x = -15;
};
void() cannon_xatta19 = [   $xatta19,   cannon_xatta20 ] {self.angles_x = 0; self.angles_z = 0;};
void() cannon_xatta20 = [   $xatta20,   cannon_xatta21 ] {};
void() cannon_xatta21 = [   $xatta21,   cannon_xatta22 ] {};
void() cannon_xatta22 = [   $xatta22,   cannon_xatta23 ] {};
void() cannon_xatta23 = [   $xatta23,   cannon_xatta24 ] {};
