float ExperienceValues [44]   = { 1000.00000,
    2000.00000,    4000.00000,    8000.00000,    16000.00000,
    32000.00000,    64000.00000,    125000.00000,    250000.00000,
    375000.00000,    125000.00000,    750.00000,    1500.00000,
    3000.00000,    6000.00000,    13000.00000,    27500.00000,
    55000.00000,    11000.00000,    225000.00000,    340000.00000,
    115000.00000,    1250.00000,    2500.00000,    5000.00000,
    10000.00000,    20000.00000,    40000.00000,    60000.00000,
    90000.00000,    135000.00000,    165000.00000,    35000.00000,
    675.00000,    1250.00000,    2500.00000,    5000.00000,
    10000.00000,    20000.00000,    40000.00000,    70000.00000,
    110000.00000,    150000.00000,    40000.00000};
float hitpoint_table [20]   = { 65.00000,
    75.00000,    5.00000,    10.00000,    3.00000,
    65.00000,    75.00000,    5.00000,    10.00000,
    3.00000,    65.00000,    75.00000,    5.00000,
    10.00000,    3.00000,    65.00000,    75.00000,
    5.00000,    10.00000,    3.00000};
float strength_table [8]   = { 15.00000,
    18.00000,    12.00000,    15.00000,    6.00000,
    10.00000,    10.00000,    13.00000};
float intelligence_table [8]   = { 6.00000,
    10.00000,    10.00000,    13.00000,    15.00000,
    18.00000,    6.00000,    10.00000};
float wisdom_table [8]   = { 6.00000,
    10.00000,    15.00000,    18.00000,    10.00000,
    13.00000,    12.00000,    15.00000};
float dexterity_table [8]   = { 10.00000,
    13.00000,    6.00000,    10.00000,    8.00000,
    12.00000,    15.00000,    18.00000};

float  (float min,float max)stats_compute =  {
local float value = 0.00000;
   value = ((((max - min) + 1.00000) * random ()) + min);
   if ( (value > max) ) {

      value = max;

   }
   value = ceil (value);
   return ( value );
};


void  (entity e)stats_NewPlayer =  {
local float index = 0.00000;
   if ( e.strength ) {

      return ;

   }
   if ( ((e.playerclass < CLASS_PALADIN) || (e.playerclass > CLASS_ASSASSIN)) ) {

      sprint (e, "Invalid player class ");
      sprint (e.playerclass, ftos (e.playerclass));
      sprint (e, "\n");
      return ;

   }
   index = ((e.playerclass - 1.00000) * 5.00000);
   e.health = stats_compute ((hitpoint_table->index), (hitpoint_table->(index + 1.00000)));
   e.max_health = e.health;
   index = ((e.playerclass - 1.00000) * 2.00000);
   e.strength = stats_compute ((strength_table->index), (strength_table->(index + 1.00000)));
   e.intelligence = stats_compute ((intelligence_table->index), (intelligence_table->(index + 1.00000)));
   e.wisdom = stats_compute ((wisdom_table->index), (wisdom_table->(index + 1.00000)));
   e.dexterity = stats_compute ((dexterity_table->index), (dexterity_table->(index + 1.00000)));
   e.level = 1.00000;
   e.experience = 0.00000;
};


void  (float NewLevel)PlayerAdvanceLevel =  {
local string s2;
local float OldLevel = 0.00000;
local float Diff = 0.00000;
local float index = 0.00000;
local float HealthInc = 0.00000;
   OldLevel = self.level;
   self.level = NewLevel;
   Diff = (self.level - OldLevel);
   sprint (self, "You are now level ");
   s2 = ftos (self.level);
   sprint (self, s2);
   sprint (self, "!!!!!!!!!!!!!!\n");
   if ( (self.playerclass == CLASS_PALADIN) ) {

      sprint (self, "Paladin gained a level\n");
   } else {

      if ( (self.playerclass == CLASS_CRUSADER) ) {

         sprint (self, "Crusader gained a level\n");
      } else {

         if ( (self.playerclass == CLASS_NECROMANCER) ) {

            sprint (self, "Necromancer gained a level\n");
         } else {

            if ( (self.playerclass == CLASS_ASSASSIN) ) {

               sprint (self, "Assassin gained a level\n");

            }

         }

      }

   }
   if ( ((self.playerclass < CLASS_PALADIN) || (self.playerclass > CLASS_ASSASSIN)) ) {

      return ;

   }
   index = ((self.playerclass - 1.00000) * 5.00000);
   while ( (Diff > 0.00000) ) {

      OldLevel += 1.00000;
      Diff -= 1.00000;
      if ( (OldLevel <= MAX_LEVELS) ) {

         HealthInc = stats_compute ((hitpoint_table->(index + 2.00000)), (hitpoint_table->(index + 3.00000)));
      } else {

         HealthInc = (hitpoint_table->(index + 3.00000));

      }
      self.health += HealthInc;
      self.max_health += HealthInc;

   }
};


void  (entity WhichPlayer)FindLevel =  {
local float Chart = 0.00000;
local float Amount = 0.00000;
local float Position = 0.00000;
local float Level = 0.00000;
   if ( ((WhichPlayer.playerclass < CLASS_PALADIN) || (WhichPlayer.playerclass > CLASS_ASSASSIN)) ) {

      return ( WhichPlayer.level );

   }
   Chart = ((WhichPlayer.playerclass - 1.00000) * (MAX_LEVELS + 1.00000));
   Level = 0.00000;
   Position = 0.00000;
   while ( ((Position < MAX_LEVELS) && (Level == 0.00000)) ) {

      if ( (WhichPlayer.experience < (ExperienceValues->(Chart + Position))) ) {

         Level = (Position + 1.00000);

      }
      Position += 1.00000;

   }
   if ( !Level ) {

      Amount = (WhichPlayer.experience - (ExperienceValues->((Chart + MAX_LEVELS) - 1.00000)));
      Level = (ceil ((Amount / (ExperienceValues->(Chart + MAX_LEVELS)))) + MAX_LEVELS);

   }
   return ( Level );
};


void  (entity ToEnt,entity FromEnt,float Amount)AwardExperience =  {
local float AfterLevel = 0.00000;
local float IsPlayer = 0.00000;
local entity SaveSelf;
   if ( !Amount ) {

      return ;

   }
   IsPlayer = (ToEnt.classname == "player");
   if ( ((FromEnt != world) && (Amount == 0.00000)) ) {

      Amount = FromEnt.experience_value;

   }
   ToEnt.experience += Amount;
   if ( IsPlayer ) {

      AfterLevel = FindLevel (ToEnt);
      if ( (ToEnt.level != AfterLevel) ) {

         PlayerAdvanceLevel (AfterLevel);

      }

   }
};

