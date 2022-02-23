// type = 1 for big characters like Beast and Bishop, 2 for normal/smaller characters
void(float type) MalePainSound =
{
   local float rnd;

   if (type == 1) {
      rnd = random() * 5;

      if (rnd < 1)
         sound(self, CHAN_BODY, "voice/male/pain1.wav", 1, ATTN_NORM);
      else if (rnd < 2)
         sound(self, CHAN_BODY, "voice/male/pain2.wav", 1, ATTN_NORM);
      else if (rnd < 3)
         sound(self, CHAN_BODY, "voice/male/pain3.wav", 1, ATTN_NORM);
      else if (rnd < 4)
         sound(self, CHAN_BODY, "voice/male/pain4.wav", 1, ATTN_NORM);
      else
         sound(self, CHAN_BODY, "voice/male/pain5.wav", 1, ATTN_NORM);

   }
   else if (type == 2) {
      rnd = random() * 2;

      if (rnd < 1)
         sound(self, CHAN_BODY, "voice/male/pain6.wav", 1, ATTN_NORM);
      else
         sound(self, CHAN_BODY, "voice/male/pain7.wav", 1, ATTN_NORM);

   }
};

// type = 1 for big characters like Beast and Bishop, 2 for normal/smaller characters
void(float type) MaleDeathSound =
{
   local float rnd;

   if (type == 1) {
      rnd = random() * 3;

      if (rnd < 1)
         sound(self, CHAN_BODY, "voice/male/diescrm1.wav", 1, ATTN_NORM);
      else if (rnd < 2)
         sound(self, CHAN_BODY, "voice/male/diescrm2.wav", 1, ATTN_NORM);
      else if (rnd < 3)
         sound(self, CHAN_BODY, "voice/male/diescrm3.wav", 1, ATTN_NORM);

   }
   else if (type == 2) {
      rnd = random() * 3;

      if (rnd < 1)
         sound(self, CHAN_BODY, "voice/male/diescrm4.wav", 1, ATTN_NORM);
      else if (rnd < 2)
         sound(self, CHAN_BODY, "voice/male/diescrm5.wav", 1, ATTN_NORM);
      else if (rnd < 3)
         sound(self, CHAN_BODY, "voice/male/diescrm6.wav", 1, ATTN_NORM);

   }
};

// type = 1 for big characters like Beast and Bishop, 2 for normal/smaller characters
void(float type) MaleSightSound =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
/*
   local float rnd;

return;	// disable all ICU sounds

   if (type == 1) {
      rnd = random() * 2;

      if (rnd < 1)
         sound(self, CHAN_BODY, "voice/male/growl.wav", 1, ATTN_NORM);
      else if (rnd < 2)
         sound(self, CHAN_BODY, "voice/male/grrr.wav", 1, ATTN_NORM);

   }
   else if (type == 2) {
      rnd = random() * 6;

      if (rnd < 1)
         sound(self, CHAN_BODY, "voice/male/intruder.wav", 1, ATTN_NORM);
      else if (rnd < 2)
         sound(self, CHAN_BODY, "voice/male/stop01.wav", 1, ATTN_NORM);
      else if (rnd < 3)
         sound(self, CHAN_BODY, "voice/male/uh-a.wav", 1, ATTN_NORM);
      else if (rnd < 4)
         sound(self, CHAN_BODY, "voice/male/what.wav", 1, ATTN_NORM);
      else if (rnd < 5)
         sound(self, CHAN_BODY, "voice/male/what_the.wav", 1, ATTN_NORM);
      else if (rnd < 6)
         sound(self, CHAN_BODY, "voice/male/youthere.wav", 1, ATTN_NORM);

   }
*/
};

void() FemalePainSound =
{
   local float rnd;

   rnd = random() * 6;

   if (rnd < 1)
      sound(self, CHAN_BODY, "voice/female/scream1.wav", 1, ATTN_NORM);
   else if (rnd < 2)
      sound(self, CHAN_BODY, "voice/female/scream2.wav", 1, ATTN_NORM);
   else if (rnd < 3)
      sound(self, CHAN_BODY, "voice/female/scream3.wav", 1, ATTN_NORM);
   else if (rnd < 4)
      sound(self, CHAN_BODY, "voice/female/no1.wav", 1, ATTN_NORM);
   else if (rnd < 5)
      sound(self, CHAN_BODY, "voice/female/scream4.wav", 1, ATTN_NORM);
   else if (rnd < 6)
      sound(self, CHAN_BODY, "voice/female/scream5.wav", 1, ATTN_NORM);
};

void() FemaleDeathSound =
{
   local float rnd;

   rnd = random() * 3;

   if (rnd < 1)
      sound(self, CHAN_BODY, "voice/female/diescrm1.wav", 1, ATTN_NORM);
   else if (rnd < 2)
      sound(self, CHAN_BODY, "voice/female/diescrm2.wav", 1, ATTN_NORM);
   else if (rnd < 3)
      sound(self, CHAN_BODY, "voice/female/diescrm3.wav", 1, ATTN_NORM);
   else if (rnd < 4)
      sound(self, CHAN_BODY, "voice/female/diescrm4.wav", 1, ATTN_NORM);
   else if (rnd < 5)
      sound(self, CHAN_BODY, "voice/female/diescrm5.wav", 1, ATTN_NORM);
};

void() FemaleSightSound =
{
   // 20060704 LordHavoc: hushed a compiler warning by commenting out this code
/*
   local float rnd;

return;	// disable all ICU sounds

   rnd = random() * 4;

   if (rnd < 1)
      sound(self, CHAN_BODY, "voice/female/hey.wav", 1, ATTN_NORM);
   else if (rnd < 2)
      sound(self, CHAN_BODY, "voice/female/hey_you.wav", 1, ATTN_NORM);
   else if (rnd < 3)
      sound(self, CHAN_BODY, "voice/female/stop.wav", 1, ATTN_NORM);
   else if (rnd < 4)
      sound(self, CHAN_BODY, "voice/female/wait.wav", 1, ATTN_NORM);
*/
};