/*
 * $Header: /H3/game/hcode/chunk.hc 71    9/04/97 3:50p Mgummelt $
 */
void ThrowSolidHead (float dm);

void ChunkRemove (void)
{
	chunk_cnt-=1;
	SUB_Remove ();
}

vector ChunkVelocity (void)
{
	local vector v;

	v_x = 300 * crandom();
	v_y = 300 * crandom();
	v_z = random(100,400);

	v = v * 0.7;

	return v;
}

void ThrowSingleChunk (string chunkname,vector location,float life_time,float skinnum)
{
	entity chunk;

	if (chunk_cnt < CHUNK_MAX)
	{
		chunk=spawn_temp();
		setmodel (chunk, chunkname);
		chunk.frame = 0;

		setsize (chunk, '0 0 0', '0 0 0');
		chunk.movetype = MOVETYPE_BOUNCE;
		chunk.solid = SOLID_NOT;
		chunk.takedamage = DAMAGE_NO;
		chunk.velocity = ChunkVelocity();
		chunk.think = ChunkRemove;
		chunk.flags(-)FL_ONGROUND;
		chunk.origin = location;
	
		chunk.avelocity_x = random(10);
		chunk.avelocity_y = random(10);
		chunk.avelocity_z = random(30);
		chunk.skin = skinnum;
		chunk.ltime = time;
		thinktime chunk : life_time;
		chunk_cnt+=1;
	}
}


void MeatChunks (vector org,vector dir,float chunk_count)
{
float final;
entity chunk;

	while(chunk_count)
	{
		chunk=spawn_temp();
		chunk_count-=1;
		final = random();

		if (final < 0.33)
			setmodel (chunk, "models/flesh1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/flesh2.mdl");
		else
			setmodel (chunk, "models/flesh3.mdl");
		setsize (chunk, '0 0 0', '0 0 0');
//		chunk.skin=1;
		chunk.movetype = MOVETYPE_BOUNCE;
		chunk.solid = SOLID_NOT;
		if(dir=='0 0 0')
			chunk.velocity = ChunkVelocity();
		else
			chunk.velocity=dir;//+randomv('-200 -200 -200','200 200 200');
		chunk.think = ChunkRemove;
		chunk.avelocity_x = random(1200);
		chunk.avelocity_y = random(1200);
		chunk.avelocity_z = random(1200);

		chunk.scale = .45;

		chunk.ltime = time;
		thinktime chunk : random(2);
		setorigin (chunk, org);
	}
}

void CreateModelChunks (vector space,float scalemod)
{
	entity chunk;
	float final;

	chunk = spawn_temp();

	space_x = space_x * random();
	space_y = space_y * random();
	space_z = space_z * random();

	setorigin (chunk, self.absmin + space);

	final = random();
	if ((self.thingtype==THINGTYPE_GLASS) || (self.thingtype==THINGTYPE_REDGLASS) || 
			(self.thingtype==THINGTYPE_CLEARGLASS) || (self.thingtype==THINGTYPE_WEBS))
	{
		if (final<0.20)
			setmodel (chunk, "models/shard1.mdl");
		else if (final<0.40)
			setmodel (chunk, "models/shard2.mdl");
		else if (final<0.60)
			setmodel (chunk, "models/shard3.mdl");
		else if (final<0.80)
			setmodel (chunk, "models/shard4.mdl");
		else 
			setmodel (chunk, "models/shard5.mdl");

		if (self.thingtype==THINGTYPE_CLEARGLASS)
		{
			chunk.skin=1;
			chunk.drawflags (+) DRF_TRANSLUCENT;
		}
		else if (self.thingtype==THINGTYPE_REDGLASS)
			chunk.skin=2;
		else if (self.thingtype==THINGTYPE_WEBS)
		{
			chunk.skin=3;
//			chunk.drawflags (+) DRF_TRANSLUCENT;
		}
	}
	else if (self.thingtype==THINGTYPE_WOOD)
	{
		if (final < 0.25)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/splnter3.mdl");
		else 
			setmodel (chunk, "models/splnter4.mdl");
	}
	else if (self.thingtype==THINGTYPE_METAL)
	{
		if (final < 0.25)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/metlchk3.mdl");
		else 
			setmodel (chunk, "models/metlchk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_FLESH)
	{
		if (final < 0.33)
			setmodel (chunk, "models/flesh1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/flesh2.mdl");
		else
			setmodel (chunk, "models/flesh3.mdl");
		if(self.classname=="hive")
			chunk.skin=1;
	}
	else if (self.thingtype == THINGTYPE_GREYSTONE)
	{
		if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.5)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else
			setmodel (chunk, "models/schunk4.mdl");
		chunk.skin = 0;
	}
	else if (self.thingtype==THINGTYPE_BROWNSTONE)
	{
		if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
		chunk.skin = 1;
	}
	else if (self.thingtype==THINGTYPE_CLAY)
	{
		if (final < 0.25)
			setmodel (chunk, "models/clshard1.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/clshard2.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/clshard3.mdl");
		else 
			setmodel (chunk, "models/clshard4.mdl");
	}
	else if (self.thingtype==THINGTYPE_LEAVES)
	{
		if (final < 0.33)
			setmodel (chunk, "models/leafchk1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/leafchk2.mdl");
		else 
			setmodel (chunk, "models/leafchk3.mdl");
	}
	else if (self.thingtype==THINGTYPE_HAY)
	{
		if (final < 0.33)
			setmodel (chunk, "models/hay1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/hay2.mdl");
		else 
			setmodel (chunk, "models/hay3.mdl");
	}
	else if (self.thingtype==THINGTYPE_CLOTH)
	{
		if (final < 0.33)
			setmodel (chunk, "models/clthchk1.mdl");
		else if (final < 0.66)
			setmodel (chunk, "models/clthchk2.mdl");
		else 
			setmodel (chunk, "models/clthchk3.mdl");
	}
	else if (self.thingtype==THINGTYPE_WOOD_LEAF)
	{
		if (final < 0.14)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.28)
			setmodel (chunk, "models/leafchk1.mdl");
		else if (final < 0.42)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.56)
			setmodel (chunk, "models/leafchk2.mdl");
		else if (final < 0.70)
			setmodel (chunk, "models/splnter3.mdl");
		else if (final < 0.84)
			setmodel (chunk, "models/leafchk3.mdl");
		else 
			setmodel (chunk, "models/splnter4.mdl");
	}
	else if (self.thingtype==THINGTYPE_WOOD_METAL)
	{
		if (final < 0.125)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.25)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.375)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.625)
			setmodel (chunk, "models/splnter3.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/metlchk3.mdl");
		else if (final < 0.875)
			setmodel (chunk, "models/splnter4.mdl");
		else 
			setmodel (chunk, "models/metlchk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_WOOD_STONE)
	{
		if (final < 0.125)
			setmodel (chunk, "models/splnter1.mdl");
		else if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.375)
			setmodel (chunk, "models/splnter2.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.625)
			setmodel (chunk, "models/splnter3.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else if (final < 0.875)
			setmodel (chunk, "models/splnter4.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_METAL_STONE)
	{
		if (final < 0.125)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.25)
			setmodel (chunk, "models/schunk1.mdl");
		else if (final < 0.375)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.50)
			setmodel (chunk, "models/schunk2.mdl");
		else if (final < 0.625)
			setmodel (chunk, "models/metlchk3.mdl");
		else if (final < 0.75)
			setmodel (chunk, "models/schunk3.mdl");
		else if (final < 0.875)
			setmodel (chunk, "models/metlchk4.mdl");
		else 
			setmodel (chunk, "models/schunk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_METAL_CLOTH)
	{
		if (final < 0.14)
			setmodel (chunk, "models/metlchk1.mdl");
		else if (final < 0.28)
			setmodel (chunk, "models/clthchk1.mdl");
		else if (final < 0.42)
			setmodel (chunk, "models/metlchk2.mdl");
		else if (final < 0.56)
			setmodel (chunk, "models/clthchk2.mdl");
		else if (final < 0.70)
			setmodel (chunk, "models/metlchk3.mdl");
		else if (final < 0.84)
			setmodel (chunk, "models/clthchk3.mdl");
		else 
			setmodel (chunk, "models/metlchk4.mdl");
	}
	else if (self.thingtype==THINGTYPE_ICE)
	{
		setmodel(chunk,"models/shard.mdl");
		chunk.skin=0;
		chunk.frame=random(2);
		chunk.drawflags(+)DRF_TRANSLUCENT|MLS_ABSLIGHT;
		chunk.abslight=0.5;
	}
	else
		return;

	setsize (chunk, '0 0 0', '0 0 0');
	chunk.movetype = MOVETYPE_BOUNCE;
	chunk.solid = SOLID_NOT;
	chunk.velocity = ChunkVelocity();
	chunk.think = ChunkRemove;
	chunk.avelocity_x = random(1200);
	chunk.avelocity_y = random(1200);
	chunk.avelocity_z = random(1200);

		chunk.scale = random(scalemod,scalemod + .1);

	chunk.ltime = time;
	thinktime chunk :  random(2);
}

void DropBackpack(void);  // in items.hc


// Put a little splat down if it will fit
void TinySplat (vector location)
{
	vector holdplane;
	entity splat;

	traceline (location + v_up*8 + v_right * 8 + v_forward * 8,location - v_up*32 + v_right * 8 + v_forward * 8, TRUE, self);
	holdplane = trace_plane_normal;
	if(trace_fraction==1)	// Nothing below victim
		return;

	traceline (location + v_up*8 - v_right * 8 + v_forward * 8,location - v_up*32 - v_right * 8 + v_forward * 8, TRUE, self);
	if ((holdplane != trace_plane_normal) || (trace_fraction==1))
		return;

	traceline (location + v_up*8 + v_right * 8 - v_forward * 8,location - v_up*32 + v_right * 8 - v_forward * 8, TRUE, self);
	if ((holdplane != trace_plane_normal) || (trace_fraction==1))
		return;

	traceline (location + v_up*8 - v_right * 8 - v_forward * 8,location - v_up*32 - v_right * 8 - v_forward * 8, TRUE, self);
	if ((holdplane != trace_plane_normal) || (trace_fraction==1))
		return;

	traceline (location + v_up*8 ,location - v_up*32 , TRUE, self);

    splat=spawn();
    splat.owner=self;
    splat.classname="bloodsplat";
    splat.movetype=MOVETYPE_NONE;
    splat.solid=SOLID_NOT;

	// Flat to the surface
	trace_plane_normal_x = trace_plane_normal_x * -1;
	trace_plane_normal_y = trace_plane_normal_y * -1;
	splat.angles = vectoangles(trace_plane_normal);

    setmodel(splat,"models/bldspot4.spr");  // 8 x 8 sprite
    setsize(splat,'0 0 0','0 0 0');
    setorigin(splat,trace_endpos + '0 0 2');

}

void BloodSplat(void)
{
	entity splat;
	vector holdangles;

	if (random() < .5)
	{
		holdangles_x = random(-30,-20);
		holdangles_y = random(30,20);
	}
	else
	{
		holdangles_x = random(30,20);
		holdangles_y = random(-30,-20);
	}

	holdangles_z = 16;
	TinySplat (self.origin + holdangles);

	if (random() < .5)
	{
		holdangles_x = random(-30,-10);
		holdangles_y = random(30,10);
	}
	else
	{
		holdangles_x = random(30,10);
		holdangles_y = random(-30,-10);
	}

	holdangles_z = 16;
	TinySplat (self.origin + holdangles);

	makevectors (self.angles);

	traceline (self.origin + v_up*8,self.origin - v_up*32, TRUE, self);

	if(trace_fraction==1)	// Nothing below victim
	{
		dprint("\n no floor ");
		return;
	}

    splat=spawn();
    splat.owner=self;
    splat.classname="bloodsplat";
    splat.movetype=MOVETYPE_NONE;
    splat.solid=SOLID_NOT;

	// Flat to the surface
	trace_plane_normal_x = trace_plane_normal_x * -1;
	trace_plane_normal_y = trace_plane_normal_y * -1;
	splat.angles = vectoangles(trace_plane_normal);

//  setmodel(splat,"models/bldspot1.spr");  // 30 x 30 sprite size
    setmodel(splat,"models/bldspot2.spr");  // 20 x 20 sprite size
//  setmodel(splat,"models/bldspot3.spr");  // 18 x 18 sprite size
//  setmodel(splat,"models/bldspot4.spr");  // 8 x 8 sprite size
    setsize(splat,'0 0 0','0 0 0');
    setorigin(splat,trace_endpos + '0 0 2');

}

void chunk_death (void)
{
	vector space;
	float spacecube,model_cnt,scalemod;
	string deathsound;

	DropBackpack();

//	BloodSplat();

	space = self.absmax - self.absmin;

	spacecube = space_x * space_y * space_z;

	model_cnt = spacecube / 8192;   // (16 * 16 * 16)

	if ((self.thingtype==THINGTYPE_GLASS) || (self.thingtype==THINGTYPE_CLEARGLASS) || (self.thingtype==THINGTYPE_REDGLASS))
		sound (self, CHAN_VOICE, "fx/glassbrk.wav", 1, ATTN_NORM);
	else if ((self.thingtype==THINGTYPE_WOOD) || (self.thingtype==THINGTYPE_WOOD_METAL))
		if(self.classname=="bolt")
			sound (self, CHAN_VOICE, "assassin/arrowbrk.wav", 1, ATTN_NORM);
		else	
			sound (self, CHAN_VOICE, "fx/woodbrk.wav", 1, ATTN_NORM);
	else if ((self.thingtype==THINGTYPE_GREYSTONE) || (self.thingtype==THINGTYPE_BROWNSTONE) || 
		(self.thingtype==THINGTYPE_WOOD_STONE) || (self.thingtype==THINGTYPE_METAL_STONE))
		sound (self, CHAN_VOICE, "fx/wallbrk.wav", 1, ATTN_NORM);
	else if ((self.thingtype==THINGTYPE_METAL) || (self.thingtype==THINGTYPE_METAL_CLOTH))
		sound (self, CHAN_VOICE, "fx/metalbrk.wav", 1, ATTN_NORM);
	else if ((self.thingtype==THINGTYPE_CLOTH) || (self.thingtype==THINGTYPE_REDGLASS))
		sound (self, CHAN_VOICE, "fx/clothbrk.wav", 1, ATTN_NORM);
	else if (self.thingtype==THINGTYPE_FLESH)
	{
		//Made temporary changes to make weapons look and sound
		//better, more blood and gory sounds.
		if(self.health<-80)
			deathsound="player/megagib.wav";
		else
			deathsound="player/gib1.wav";
		sound(self,CHAN_AUTO,deathsound,1,ATTN_NORM);
	}
	else if (self.thingtype==THINGTYPE_CLAY)
		sound (self, CHAN_VOICE, "fx/claybrk.wav", 1, ATTN_NORM);
	else if ((self.thingtype==THINGTYPE_LEAVES)  || (self.thingtype==THINGTYPE_WOOD_LEAF))
		sound (self, CHAN_VOICE, "fx/leafbrk.wav", 1, ATTN_NORM);
	else if (self.thingtype==THINGTYPE_ICE)
		sound (self, CHAN_VOICE, "misc/icestatx.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "fx/wallbrk.wav", 1, ATTN_NORM);

	// Scale        0 - 50,000   small 
	//		   50,000 - 500,000  medium
	//	      500,000            large
	//	    1,000,000 +          huge
	if (spacecube < 5000)
	{
		scalemod = .20;
		model_cnt = model_cnt * 3;	// Because so few pieces come out of a small object
	}
	else if (spacecube < 50000)
	{
		scalemod = .45;
		model_cnt = model_cnt * 3;	// Because so few pieces come out of a small object
	}
	else if (spacecube < 500000)
	{
		scalemod = .50;
	}
	else if (spacecube < 1000000)
	{
		scalemod = .75;
	}
	else
	{
		scalemod = 1;
	}

	if(model_cnt>CHUNK_MAX)
		model_cnt=CHUNK_MAX;

	while (model_cnt>0)
	{
		if (chunk_cnt < CHUNK_MAX)
		{
			CreateModelChunks(space,scalemod);
			chunk_cnt+=1;
		}

		model_cnt-=1;
	}

	if(self.classname=="monster_eidolon")
		return;

	SUB_UseTargets();

	if(self.headmodel!=""&&self.classname!="head")
		ThrowSolidHead (50);
	else
		remove(self);
}

