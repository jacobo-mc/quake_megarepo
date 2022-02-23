void() xmen_monster_test =
{
   if (cvar("coop") == 1)
   {
      self.classname = "xmen_wolverine";
      xmen_wolverine();
   }
   else if (cvar("coop") == 2)
   {
      self.classname = "xmen_storm";
      xmen_storm();
   }
   else if (cvar("coop") == 3)
   {
      self.classname = "xmen_cyclops";
      xmen_cyclops();
   }
   else if (cvar("coop") == 4)
   {
      self.classname = "xmen_psylocke";
      xmen_psylocke();
   }
   else if (cvar("coop") == 5)
   {
      self.classname = "xmen_angel";
      xmen_angel();
   }
   else if (cvar("coop") == 6)
   {
      self.classname = "xmen_beast";
      xmen_beast();
   }
   else if (cvar("coop") == 7)
   {
      self.classname = "xmen_gambit";
      xmen_gambit();
   }
   else if (cvar("coop") == 8) {
      self.map = "brown";
      self.classname = "xmen_iceman";
      xmen_iceman();
   }
   else if (cvar("coop") == 9)
   {
      self.classname = "xmen_bishop";
      xmen_bishop();
   }
   else if (cvar("coop") == 10)
   {
      self.classname = "xmen_rogue";
      xmen_rogue();
   }
   else if (cvar("coop") == 11)
   {
      self.classname = "xmen_cannonball";
      xmen_cannonball();
   }
   else if (cvar("coop") == 12)
   {
      self.classname = "xmen_phoenix";
      xmen_phoenix();
   }
};