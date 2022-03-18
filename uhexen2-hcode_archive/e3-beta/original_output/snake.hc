
void  ()snake_touch =  {
   AdvanceFrame( 0.00000, 90.00000);
   self.health = self.health;
};


void  ()monster_snake =  {
   self.solid = SOLID_BBOX;
   self.movetype = MOVETYPE_NONE;
   self.frame += 1.00000;
   self.mintel = 2.00000;
   if ( !(self.spawnflags & NO_JUMP) ) {

      self.spawnflags += NO_JUMP;

   }
   precache_model2 ("models/snake.mdl");
   setmodel (self, "models/snake.mdl");
   setsize (self, '-80.00000 -80.00000 0.00000', '80.00000 80.00000 200.00000');
   self.health = 200.00000;
   self.touch = snake_touch;
};

