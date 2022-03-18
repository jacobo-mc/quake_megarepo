float  (entity e,float healamount,float ignore)T_Heal;
float  (entity targ,entity inflictor)CanDamage;
void  (vector tdest,float tspeed,void() func)SUB_CalcMove;
void  (entity ent,vector tdest,float tspeed,void() func)SUB_CalcMoveEnt;
void  (vector destangle,float tspeed,void() func)SUB_CalcAngleMove;
void  ()SUB_CalcMoveDone;
void  ()SUB_CalcAngleMoveDone;
void  ()SUB_Null;
void  ()SUB_UseTargets;
void  ()SUB_Remove;
void  (entity ToEnt,entity FromEnt,float Amount)AwardExperience;
void  (entity e)stats_NewPlayer;

void  ()crandom =  {
   return ( (2.00000 * (random () - 0.50000)) );
};


float  (float base,float exponent)fexp =  {
local float exp_count = 0.00000;
   exponent = rint (exponent);
   if ( (exponent == 0.00000) ) {

      return ( 1.00000 );

   }
   if ( (exponent < 0.00000) ) {

      base = (1.00000 / base);
      exponent = fabs (exponent);

   }
   if ( (exponent == 1.00000) ) {

      return ( base );

   }
   exponent -= 1.00000;
   while ( (exp_count < exponent) ) {

      exp_count += 1.00000;
      base = (base * base);

   }
   return ( base );
};


float  (float mult)byte_me =  {
local float mult_count = 0.00000;
local float base = 0.00000;
   mult = rint (mult);
   dprint ("Base: ");
   dprint (ftos (mult));
   dprint ("\n");
   if ( (mult == 0.00000) ) {

      return ( 0.00000 );

   }
   if ( (mult == 1.00000) ) {

      return ( 1.00000 );

   }
   if ( (mult == -1.00000) ) {

      return ( -1.00000 );

   }
   if ( (mult < 0.00000) ) {

      base = -1.00000;
      mult = fabs (mult);
   } else {

      base = 1.00000;

   }
   mult -= 1.00000;
   while ( (mult_count < mult) ) {

      mult_count += 1.00000;
      base = (base * 2.00000);

   }
   return ( base );
};

