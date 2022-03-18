void CheckAbilities ()
{
	if(self.playerclass == CLASS_ASSASSIN && self.model=="models/assassin.mdl")
	{
	float trans_limit;
		if(self.level<3)
			return;
		trans_limit=10 - self.level;
		if(trans_limit<1)
			trans_limit=1;
		if(self.velocity=='0 0 0')
		{
			if(self.still_time==-1)
				self.still_time=time + 10 - self.level;
			if(self.still_time<time)
			{
				msg_entity=self;
				WriteByte(MSG_ONE, SVC_SET_VIEW_FLAGS);
				WriteByte(MSG_ONE,DRF_TRANSLUCENT);
				self.drawflags(+)DRF_TRANSLUCENT|MLS_ABSLIGHT;
				if(self.abslight==1)
					self.abslight=0.5;
				else if(self.abslight>0.005*(8-trans_limit))
					self.abslight-=0.005*(8-trans_limit);
			}
		}
		else
		{
			self.still_time=-1;
			if(self.abslight<1)
				self.abslight+=0.005*trans_limit;
			else
			{
				self.drawflags(-)MLS_ABSLIGHT|DRF_TRANSLUCENT;
				msg_entity=self;
				WriteByte(MSG_ONE, SVC_CLEAR_VIEW_FLAGS);
				WriteByte(MSG_ONE,DRF_TRANSLUCENT);
			}
		}
	}
}
