void  (float explodetype)BecomeExplosion;

void  ()TouchGlyph =  {
local float damg = 0.00000;
   WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
   WriteByte (MSG_BROADCAST, TE_EXPLOSION);
   WriteCoord (MSG_BROADCAST, self.origin_x);
   WriteCoord (MSG_BROADCAST, self.origin_y);
   WriteCoord (MSG_BROADCAST, self.origin_z);
   BecomeExplosion (FALSE);
   damg = (GLYPH_BASE_DAMAGE + (random () * GLYPH_ADD_DAMAGE));
   self.owner = self;
   if ( other.health ) {

      T_Damage (other, self, self.owner, damg);

   }
   T_RadiusDamage (self, self.owner, damg, other);
   T_RadiusManaDamage (self, self.owner, damg, other);
   remove (self);
};


void  ()DecrementGlyph =  {
   if ( (self.lifetime > time) ) {

      self.nextthink = (time + 1.00000);
      return ;
   } else {

      TouchGlyph ();

   }
};


void  ()Use_Glyph =  {
local entity glyph;
   glyph = spawn ();
   glyph.owner = self;
   CreateEntity (glyph, "models/glyph.mdl", VEC_ORIGIN, VEC_ORIGIN, SOLID_BBOX, MOVETYPE_FLYMISSILE, 0.00000, DAMAGE_NO);
   glyph.touch = TouchGlyph;
   glyph.classname = "running_glyph";
   setorigin (glyph, self.origin);
   glyph.think = DecrementGlyph;
   glyph.nextthink = (time + 1.00000);
   glyph.lifetime = (time + 10.00000);
};

