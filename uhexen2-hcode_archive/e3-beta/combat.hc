
float  (float targettype)MetalHitSound =  {
   if ( (targettype == THINGTYPE_FLESH) ) {

      sound (self, CHAN_WEAPON, "weapons/met2flsh.wav", 1.00000, ATTN_NORM);
      return ( TRUE );
   } else {

      if ( (targettype == THINGTYPE_WOOD) ) {

         sound (self, CHAN_WEAPON, "weapons/met2wd.wav", 1.00000, ATTN_NORM);
         return ( TRUE );
      } else {

         if ( (targettype == THINGTYPE_METAL) ) {

            sound (self, CHAN_WEAPON, "weapons/met2met.wav", 1.00000, ATTN_NORM);
            return ( TRUE );
         } else {

            if ( ((targettype == THINGTYPE_BROWNSTONE) || (targettype == THINGTYPE_GREYSTONE)) ) {

               sound (self, CHAN_WEAPON, "weapons/met2stn.wav", 1.00000, ATTN_NORM);
               return ( TRUE );

            }

         }

      }

   }
   return ( FALSE );
};


void  (float damage_base,float damage_mod,float attack_radius)FireMelee =  {
local vector source = '0.00000 0.00000 0.00000';
local vector org = '0.00000 0.00000 0.00000';
local float damg = 0.00000;
   makevectors (self.v_angle);
   source = (self.origin + self.proj_ofs);
   traceline (source, (source + (v_forward * 64.00000)), FALSE, self);
   if ( (trace_fraction == 1.00000) ) {

      return ;

   }
   org = (trace_endpos + (v_forward * 4.00000));
   if ( trace_ent.takedamage ) {

      damg = (damage_base + (random () * damage_mod));
      SpawnPuff (org, '0.00000 0.00000 0.00000', 20.00000, trace_ent);
      T_Damage (trace_ent, self, self, 20.00000);
      if ( (trace_ent.thingtype == THINGTYPE_FLESH) ) {

         sound (self, CHAN_WEAPON, "weapons/slash.wav", 1.00000, ATTN_NORM);
      } else {

         sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1.00000, ATTN_NORM);

      }
   } else {

      sound (self, CHAN_WEAPON, "weapons/hitwall.wav", 1.00000, ATTN_NORM);
      WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
      WriteByte (MSG_BROADCAST, TE_GUNSHOT);
      WriteCoord (MSG_BROADCAST, org_x);
      WriteCoord (MSG_BROADCAST, org_y);
      WriteCoord (MSG_BROADCAST, org_z);

   }
};

