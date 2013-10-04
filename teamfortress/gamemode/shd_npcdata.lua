NPC_MECH			= 1		-- Shows a gear icon under the health bar in the TargetID and freezecam
NPC_NOCRITS			= 2		-- Never receive critical damage, also immune to Jarate
NPC_NODMGFORCE		= 4		-- Not pushed away by blast damage
NPC_NOSPECIALMELEE	= 8		-- Always receive DMG_CLUB type damage on melee hits
NPC_INVULNERABLE	= 16	-- Completely immune to damage
NPC_ALWAYSFRIENDLY	= 32	-- Always considered as friendly by everyone, no matter which team it is on
NPC_FIREPROOF		= 64	-- Cannot be ignited
NPC_HASHEAD			= 128	-- Can be decapitated by the Eyelander
NPC_CANBLEED		= 256	-- Can bleed
NPC_CANNOTHEAL		= 512	-- Cannot be healed
NPC_NORELATIONSHIP	= 1024	-- Do not override relationships for that NPC

NPC_BUILDING		= bit.bor(NPC_MECH, NPC_NOCRITS, NPC_FIREPROOF, NPC_CANNOTHEAL)
NPC_FLYING			= NPC_NODMGFORCE
NPC_HUMAN			= bit.bor(NPC_HASHEAD, NPC_CANBLEED)

-- Virtual player types
VPLAYER_NONE		= 0		-- Cannot be assigned to a virtual player
VPLAYER_HEADCRAB	= 1		-- Headcrabs
VPLAYER_ZOMBIE		= 2		-- Zombies
VPLAYER_COMBINE		= 3		-- Combine soldiers
VPLAYER_REBEL		= 4		-- Rebels
VPLAYER_VORTIGAUNT	= 5		-- Vortigaunts

NPCData = {

-- Friendly actors
npc_dog = {
	team=TEAM_RED,
	flags=bit.bor(NPC_BUILDING, NPC_INVULNERABLE),
	vplayer=VPLAYER_NONE
},
npc_eli = {
	team=TEAM_RED,
	health=8,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},
npc_fisherman = {
	team=TEAM_RED,
	health=8,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},
npc_kleiner = {
	team=TEAM_RED,
	health=8,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},
npc_magnusson = {
	team=TEAM_RED,
	health=8,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},
npc_mossman = {
	team=TEAM_RED,
	health=8,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},

-- Vital player companions
npc_alyx = {
	team=TEAM_RED,
	health=80,
	accuracy=3,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},
npc_barney = {
	team=TEAM_RED,
	health=80,
	accuracy=3,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},
npc_monk = {
	team=TEAM_RED,
	health=100,
	accuracy=4,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},

-- Regular friendlies
npc_citizen = {
	team=TEAM_RED,
	health=110,
	accuracy=2,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_REBEL
},
npc_vortigaunt = {
	team=TEAM_RED,
	health=125,
	vplayer=VPLAYER_VORTIGAUNT
},

-- Enemy actors
npc_breen = {
	team=TEAM_BLU,
	health=8,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},

-- Regular enemies
npc_combine_s = {
	team=TEAM_BLU,
	health={
		[0]=100,
		["models/combine_super_soldier.mdl"]=150
	},
	accuracy={
		[0]=2,
		["models/combine_super_soldier.mdl"]=3
	},
	flags=NPC_HUMAN,
	vplayer=VPLAYER_COMBINE
},
npc_metropolice = {
	team=TEAM_BLU,
	health=75,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_METROCOP
},
npc_stalker = {
	team=TEAM_BLU,
	health=100,
	flags=NPC_HUMAN,
	vplayer=VPLAYER_NONE
},

-- Regular combine machines
npc_cscanner = {
	team=TEAM_BLU,
	health=50,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_clawscanner = {
	team=TEAM_BLU,
	health=75,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_manhack = {
	team=TEAM_BLU,
	health=40,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},

-- Indestructible combine machines
npc_combine_camera = {
	team=TEAM_BLU,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_rollermine  = {
	team=TEAM_BLU,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_turret_ceiling = {
	team=TEAM_BLU,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_turret_floor = {
	team=TEAM_BLU,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_turret_ground = {
	team=TEAM_BLU,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},

-- Synths/boss combine machines
npc_combinegunship = {
	team=TEAM_BLU,
	health=100,
	alternatehealth=80,
	flags=bit.bor(NPC_MECH, NPC_FIREPROOF, NPC_FLYING),
	vplayer=VPLAYER_NONE
},
npc_hunter = {
	team=TEAM_BLU,
	health=350,
	flags=bit.bor(NPC_MECH, NPC_NOSPECIALMELEE),
	vplayer=VPLAYER_NONE
},
npc_strider = {
	team=TEAM_BLU,
	health=350,
	alternatehealth=200,
	flags=bit.bor(NPC_MECH, NPC_FIREPROOF, NPC_FLYING),
	vplayer=VPLAYER_NONE
},
npc_helicopter = {
	team=TEAM_BLU,
	health=5600,
	flags=bit.bor(NPC_MECH, NPC_FIREPROOF, NPC_FLYING),
	vplayer=VPLAYER_NONE
},

-- Indestructible synths
npc_combinedropship = {
	team=TEAM_BLU,
	flags=bit.bor(NPC_BUILDING, NPC_FLYING),
	vplayer=VPLAYER_NONE
},

-- Special/unused combine NPCs
npc_apcdriver = {
	team=TEAM_BLU,
	vplayer=VPLAYER_NONE
},

combine_mine = {
	team=TEAM_BLU,
	flags=NPC_BUILDING,
	vplayer=VPLAYER_NONE
},
npc_crabsynth = {
	team=TEAM_BLU,
	flags=bit.bor(NPC_MECH, NPC_FIREPROOF),
	vplayer=VPLAYER_NONE
},
npc_mortarsynth = {
	team=TEAM_BLU,
	flags=bit.bor(NPC_MECH, NPC_FIREPROOF, NPC_FLYING),
	vplayer=VPLAYER_NONE
},
npc_sniper = {
	team=TEAM_BLU,
	vplayer=VPLAYER_COMBINE
},

-- Antlions
npc_antlion = {
	team=function()
		return ((GetGlobalBool("AntlionsAreAllied") or GAMEMODE.AntlionsAreAllied) and TEAM_RED) or TEAM_NEUTRAL
	end,
	health=60,
	
	BaseDamage = 20,
	DamageRandomize = 0.1,
	pre_damage = function(self, ent, hitgroup, dmginfo)
		dmginfo:SetDamage(tf_util.CalculateDamage(self:GetNPCData(), dmginfo:GetDamagePosition(), self:GetPos()))
	end,
	
	vplayer=VPLAYER_ANTLION
},
npc_antlion_worker = {
	team=TEAM_NEUTRAL,
	health=80,
	vplayer=VPLAYER_ANTWORKER
},
npc_antlionguard = {
	team=TEAM_NEUTRAL,
	health=1000,
	flags=bit.bor(NPC_NODMGFORCE, NPC_NOSPECIALMELEE),
	
	BaseDamage = 90,
	DamageRandomize = 0.15,
	pre_damage = function(self, ent, hitgroup, dmginfo)
		if self.LastPreDamage and CurTime() == self.LastPreDamage then
			dmginfo:SetDamage(0)
			return
		end
		self.LastPreDamage = CurTime()
		
		dmginfo:SetDamage(tf_util.CalculateDamage(self:GetNPCData(), dmginfo:GetDamagePosition(), self:GetPos()))
	end,
	crit_override = function(self, ent, hitgroup, dmginfo)
		local seq = self:GetSequence()
		if seq == 37 then	-- Antlion guard charges are guaranteed critical hits
			return true
		end
	end,
	vplayer=VPLAYER_ANTGUARD
},

-- Birds
npc_crow = {
	team=TEAM_NEUTRAL,
	vplayer=VPLAYER_NONE
},
npc_pigeon = {
	team=TEAM_NEUTRAL,
	vplayer=VPLAYER_NONE
},
npc_seagull = {
	team=TEAM_NEUTRAL,
	vplayer=VPLAYER_NONE
},

-- Headcrabs
npc_headcrab = {
	team=TEAM_NEUTRAL,
	health=20,
	vplayer=VPLAYER_HEADCRAB
},
npc_headcrab_fast = {
	team=TEAM_NEUTRAL,
	health=15,
	vplayer=VPLAYER_HEADCRAB
},
npc_headcrab_black = {
	team=TEAM_NEUTRAL,
	health=50,
	vplayer=VPLAYER_HEADCRAB
},
npc_headcrab_poison = {
	team=TEAM_NEUTRAL,
	health=50,
	vplayer=VPLAYER_HEADCRAB
},

-- Zombies
npc_fastzombie = {
	team=TEAM_NEUTRAL,
	health=75,
	vplayer=VPLAYER_ZOMBIE
},
npc_fastzombie_torso = {
	team=TEAM_NEUTRAL,
	health=50,
	vplayer=VPLAYER_ZOMBIE
},
npc_poisonzombie = {
	team=TEAM_NEUTRAL,
	health=250,
	damage={
		{nil	,{damage=45,random=0.1}},
	},
	vplayer=VPLAYER_ZOMBIE
},
npc_zombie = {
	team=TEAM_NEUTRAL,
	health=125,
	damage={
		{{sequence={7,8,9,10}}	,{damage=45,random=0.1}},
		{{sequence={11,12}}		,{damage=45,random=0.1,crit=true}},
	},
	vplayer=VPLAYER_ZOMBIE
},
npc_zombie_torso = {
	team=TEAM_NEUTRAL,
	health=75,
	damage={
		{nil	,{damage=30,random=0.1}},
	},
	vplayer=VPLAYER_ZOMBIE
},
npc_zombine = {
	team=TEAM_NEUTRAL,
	health=175,
	vplayer=VPLAYER_ZOMBIE
},

-- Special neutral NPCs
npc_barnacle = {
	team=TEAM_NEUTRAL,
	vplayer=VPLAYER_NONE,
	flags=NPC_NORELATIONSHIP,
},
npc_gman = {
	team=TEAM_NEUTRAL,
	health=8,
	flags=bit.bor(NPC_HUMAN,NPC_NORELATIONSHIP),
	vplayer=VPLAYER_NONE
},

-- Generic actors
cycler_actor = {
	team=TEAM_HIDDEN,
	flags=NPC_ALWAYSFRIENDLY,
	vplayer=VPLAYER_NONE
},
generic_actor = {
	team=TEAM_HIDDEN,
	flags=NPC_ALWAYSFRIENDLY,
	vplayer=VPLAYER_NONE
},

-- Generic targets
bullseye_strider_focus = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
monster_generic = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
npc_bullseye = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
npc_furniture = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
npc_enemyfinder = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
npc_ichthyosaur = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},

-- Unused
npc_missiledefense = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},

-- Non NPC entities
point_hurt = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
trigger_hurt = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
entityflame = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
tf_entityflame = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},
npc_grenade_frag = {
	team=TEAM_HIDDEN,
	vplayer=VPLAYER_NONE
},

-- TF2 buildings
obj_sentrygun = {
	flags=bit.bor(NPC_BUILDING, NPC_NODMGFORCE),
	vplayer=VPLAYER_NONE
},
obj_dispenser = {
	flags=bit.bor(NPC_BUILDING, NPC_NODMGFORCE),
	vplayer=VPLAYER_NONE
},
obj_teleporter = {
	flags=bit.bor(NPC_BUILDING, NPC_NODMGFORCE),
	vplayer=VPLAYER_NONE
},

}