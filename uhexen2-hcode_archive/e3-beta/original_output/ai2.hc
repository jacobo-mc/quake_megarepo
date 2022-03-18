
float  (entity targ,entity forent)visible2ent =  {
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
   if ( (((forent.solid == SOLID_BSP) || (forent.solid == SOLID_TRIGGER)) && (forent.origin == '0.00000 0.00000 0.00000')) ) {

      spot1 = ((forent.absmax + forent.absmin) * 0.50000);
   } else {

      spot1 = (forent.origin + forent.view_ofs);

   }
   if ( (((targ.solid == SOLID_BSP) || (targ.solid == SOLID_TRIGGER)) && (targ.origin == '0.00000 0.00000 0.00000')) ) {

      spot2 = ((targ.absmax + targ.absmin) * 0.50000);
   } else {

      spot2 = (targ.origin + targ.view_ofs);

   }
   traceline (spot1, spot2, TRUE, forent);
   if ( (trace_inopen && trace_inwater) ) {

      return ( FALSE );

   }
   if ( (trace_fraction == 1.00000) ) {

      return ( TRUE );

   }
   return ( FALSE );
};


float  (entity targ,entity from)infront_of_ent =  {
local vector vec = '0.00000 0.00000 0.00000';
local vector spot1 = '0.00000 0.00000 0.00000';
local vector spot2 = '0.00000 0.00000 0.00000';
local float accept = 0.00000;
local float dot = 0.00000;
   if ( (from.classname == "player") ) {

      makevectors (from.v_angle);
   } else {

      if ( (from.classname == "monster_medusa") ) {

         makevectors ((from.angles + from.angle_ofs));
      } else {

         makevectors (from.angles);

      }

   }
   if ( (((from.solid == SOLID_BSP) || (from.solid == SOLID_TRIGGER)) && (from.origin == '0.00000 0.00000 0.00000')) ) {

      spot1 = ((from.absmax + from.absmin) * 0.50000);
   } else {

      spot1 = (from.origin + from.view_ofs);

   }
   spot2 = ((targ.absmax + targ.absmin) * 0.50000);
   vec = normalize ((spot2 - spot1));
   dot = (vec * v_forward);
   accept = 0.30000;
   if ( (dot > accept) ) {

      return ( TRUE );

   }
   return ( FALSE );
};

