function GetKilliconData(name, highlight)
	local icon = Killicons["_images"]["d_skull"]
	local group = "_images"
	
	for k,v in pairs(Killicons) do
		if v[name] then
			icon = v[name]
			group = k
			break
		end
	end
	
	local path
	
	if string.sub(group, 1, 1)=="!" then
		path = "HUD/"..string.sub(group, 2)
	else
		path = (highlight and ("HUD/dneg"..group)) or ("HUD/d"..group)
	end
	
	if highlight then
		return icon, Color(245, 229, 196, 200), path
	else
		return icon, Color(46, 43, 42, 220), path
	end
end

KilliconTranslate = {
-- HL2
weapon_pistol = "d_hl_pistol",
weapon_357 = "d_hl_357",
weapon_crossbow = "d_hl_crossbow",
crossbow_bolt = "d_hl_crossbow",
crossbow_bolt_deflect = "d_deflect_crossbowbolt",
weapon_smg1 = "d_hl_smg",
weapon_shotgun = "d_hl_shotgun",
weapon_ar2 = "d_hl_ar2",
weapon_crowbar = "d_hl_crowbar",
weapon_stunstick = "d_hl_stunstick",
weapon_rpg = "d_hl_rpg",
weapon_annabelle = "d_sniperrifle",
rpg_missile = "d_hl_rpg",
rpg_missile_deflect = "d_deflect_rpg",
weapon_frag = "d_hl_frag",
npc_grenade_frag = "d_hl_frag",
npc_grenade_frag_deflect = "d_deflect_frag",
prop_combine_ball = "d_hl_combine_ball",
prop_combine_ball_deflect = "d_deflect_combineball",
grenade_ar2 = "d_hl_ar2_grenade",
grenade_ar2_deflect = "d_deflect_ar2grenade",
grenade_spit = "d_hl_acidball",
grenade_spit_deflect = "d_deflect_acidball",
hunter_flechette = "d_hl_flechette",

npc_zombie = "d_hl_zombie",
npc_zombie_torso = "d_hl_zombie",
npc_fastzombie = "d_hl_zombie",
npc_fastzombie_torso = "d_hl_zombie",
npc_poisonzombie = "d_hl_zombie",
npc_zombine = "d_hl_zombie",

npc_headcrab = "d_hl_headcrab",
npc_headcrab_fast = "d_hl_headcrab",

npc_antlion = "d_hl_antlion",
npc_antlion_worker = "d_hl_antlion",
npc_antlion_worker_explosion = "d_hl_antworker_explosion",
npc_antlionguard = "d_hl_antlionguard",

npc_hunter = "d_hl_hunter_charge",
npc_hunter_pound = "d_hl_hunter_pound",
npc_hunter_skewer = "d_hl_hunter_skewer",

npc_vortigaunt_beam = "d_hl_vortigaunt_beam",
npc_vortigaunt = "d_hl_vortigaunt",

npc_helicopter = "d_hl_airboat_gun",
npc_combinegunship = "d_hl_airboat_gun",
npc_combinedropship = "d_hl_airboat_gun",
npc_strider_minigun = "d_hl_strider_minigun",
concussiveblast = "d_hl_strider_beam",
npc_strider = "d_hl_strider_skewer",

npc_rollermine = "d_hl_rollermine",
npc_manhack = "d_hl_manhack",
npc_turret_floor = "d_hl_floorturret",

have_an_error = "d_have_an_error",

-- Scout
tf_weapon_scattergun = "d_scattergun",
tf_weapon_pistol_scout = "d_pistol_scout",
tf_weapon_bat = "d_bat",

-- Heavy
tf_weapon_minigun = "d_minigun",
tf_weapon_shotgun_hwg = "d_shotgun_hwg",
tf_weapon_fists = "d_fists",

-- Demoman
tf_projectile_pipe = "d_tf_projectile_pipe",
tf_projectile_pipe_remote = "d_tf_projectile_pipe_remote",
tf_projectile_pipe_defender = "d_sticky_resistance",
tf_projectile_pipe_round = "d_tf_projectile_pipe_remote",
tf_weapon_bottle = "d_bottle",
tf_weapon_sword = "d_sword",
tf_wearable_item_demoshield = "d_demoshield",

-- Soldier
tf_projectile_rocket = "d_tf_projectile_rocket",
tf_projectile_rocket_direct = "d_rocketlauncher_directhit",
tf_weapon_shotgun_soldier = "d_shotgun_soldier",
tf_weapon_shovel = "d_shovel",

-- Engineer
tf_weapon_shotgun_primary = "d_shotgun_primary",
tf_weapon_pistol = "d_pistol",
tf_weapon_wrench = "d_wrench",
obj_sentrygun = "d_obj_sentrygun",
obj_sentrygun2 = "d_obj_sentrygun2",
obj_sentrygun3 = "d_obj_sentrygun3",
tf_projectile_sentryrocket = "d_obj_sentrygun3",

-- Pyro
tf_flame = "d_flamethrower",
tf_weapon_shotgun_pyro = "d_shotgun_pyro",
tf_weapon_fireaxe = "d_fireaxe",
tf_projectile_flare = "d_flaregun",

-- Medic
tf_projectile_syringe = "d_syringegun_medic",
tf_projectile_blutsauger = "d_blutsauger",
tf_weapon_bonesaw = "d_bonesaw",

-- Sniper
tf_weapon_sniperrifle = "d_sniperrifle",
tf_weapon_sniperrifle_headshot = "d_headshot",
tf_weapon_smg = "d_smg",
tf_weapon_club = "d_club",
tf_projectile_arrow = "d_huntsman",
tf_projectile_arrow_headshot = "d_huntsman_headshot",
tf_projectile_arrow_burning = "d_huntsman_burning",
tf_projectile_arrow_flyingburn = "d_huntsman_flyingburn",

-- Spy
tf_weapon_revolver = "d_revolver",
tf_weapon_knife = "d_knife",
tf_weapon_knife_backstab = "d_backstab",
tf_weapon_ambassador_headshot = "d_ambassador_headshot",

-- Other
entityflame = "d_firedeath",
tf_entityflame = "d_firedeath",
tf_entitybleed = "d_bleed_kill",
env_explosion = "d_explosion",
env_physexplosion = "d_explosion",
combine_mine = "d_hl_combine_mine",
prop_physics = "d_hl_physics",
}

function TranslateKilliconName(name)
	return KilliconTranslate[name] or "d_"..name
end

function RegisterKillicon(name, texture, data)
	if not Killicons[texture] then Killicons[texture] = {} end
	Killicons[texture][name] = data
end

Killicons = {

["!leaderboard_dominated"] = {
d_domination={
	x=0,
	y=0,
	w=64,
	h=64,
},
},

["_images"]={
d_obj_sentrygun={
	x=96,
	y=160,
	w=64,
	h=32,
},
d_obj_sentrygun2={
	x=256,
	y=0,
	w=96,
	h=32,
},
d_obj_sentrygun3={
	x=256,
	y=32,
	w=96,
	h=32,
},
d_bat={
	x=0,
	y=0,
	w=96,
	h=32,
},
d_pistol={
	x=0,
	y=32,
	w=96,
	h=32,
},
d_pistol_scout={
	x=0,
	y=32,
	w=96,
	h=32,
},
d_nailgun={
	x=0,
	y=64,
	w=64,
	h=32,
},
d_sniperrifle={
	x=16,
	y=96,
	w=32,
	h=32,
},
d_smg={
	x=0,
	y=128,
	w=96,
	h=32,
},
d_club={
	x=0,
	y=160,
	w=96,
	h=32,
},
d_shovel={
	x=0,
	y=192,
	w=96,
	h=32,
},
d_tf_projectile_rocket={
	x=0,
	y=224,
	w=96,
	h=32,
},
d_shotgun_primary={
	x=0,
	y=256,
	w=96,
	h=32,
},
d_shotgun_soldier={
	x=0,
	y=256,
	w=96,
	h=32,
},
d_shotgun_hwg={
	x=0,
	y=256,
	w=96,
	h=32,
},
d_shotgun_pyro={
	x=0,
	y=256,
	w=96,
	h=32,
},
d_tf_projectile_pipe={
	x=0,
	y=288,
	w=96,
	h=32,
},
d_bottle={
	x=0,
	y=320,
	w=96,
	h=32,
},
d_syringegun_medic={
	x=0,
	y=352,
	w=96,
	h=32,
},
d_minigun={
	x=0,
	y=384,
	w=96,
	h=32,
},
d_pipe={
	x=0,
	y=448,
	w=96,
	h=32,
},
d_flamethrower={
	x=0,
	y=416,
	w=96,
	h=32,
},
d_fists={
	x=191,
	y=446,
	w=64,
	h=32,
},
d_fireaxe={
	x=0,
	y=480,
	w=96,
	h=32,
},
d_bonesaw={
	x=96,
	y=128,
	w=96,
	h=32,
},
d_knife={
	x=96,
	y=0,
	w=96,
	h=32,
},
d_revolver={
	x=96,
	y=32,
	w=96,
	h=32,
},
d_flaregun={
	x=96,
	y=64,
	w=96,
	h=32,
},
d_wrench={
	x=96,
	y=96,
	w=96,
	h=32,
},
d_scattergun={
	x=96,
	y=192,
	w=96,
	h=32,
},
d_tf_projectile_pipe_remote={
	x=96,
	y=224,
	w=96,
	h=32,
},
d_vehicle={
	x=96,
	y=256,
	w=96,
	h=32,
},
d_skull={
	x=116,
	y=288,
	w=52,
	h=32,
},
d_explosion={
	x=116,
	y=320,
	w=52,
	h=32,
},
d_headshot={
	x=120,
	y=352,
	w=42,
	h=32,
},
d_backstab={
	x=116,
	y=384,
	w=48,
	h=32,
},
d_ubersaw={
	x=96,
	y=416,
	w=96,
	h=32,
},
d_axtinguisher={
	x=96,
	y=448,
	w=96,
	h=32,
},
d_taunt_pyro={
	x=96,
	y=480,
	w=96,
	h=32,
},
d_bluedefend={
	x=194,
	y=0,
	w=32,
	h=32,
},
d_bluecapture={
	x=194,
	y=32,
	w=32,
	h=32,
},
d_reddefend={
	x=226,
	y=0,
	w=32,
	h=32,
},
d_redcapture={
	x=226,
	y=32,
	w=32,
	h=32,
},
d_obj_attachment_sapper={
	x=0,
	y=64,
	w=96,
	h=32,
},
d_deflect_promode={
	x=194,
	y=64,
	w=64,
	h=32,
},
d_deflect_sticky={
	x=194,
	y=96,
	w=64,
	h=32,
},
d_deflect_rocket={
	x=194,
	y=128,
	w=64,
	h=32,
},
d_deflect_flare={
	x=194,
	y=160,
	w=64,
	h=32,
},
d_bat_wood={
	x=0,
	y=0,
	w=96,
	h=32,
},
d_ball={
	x=192,
	y=192,
	w=64,
	h=32,
},
d_taunt_heavy={
	x=191,
	y=479,
	w=64,
	h=32,
},
d_taunt_scout={
	x=192,
	y=224,
	w=64,
	h=64,
},
d_gloves={
	x=0,
	y=448,
	w=96,
	h=32,
},
d_crit={
	x=192,
	y=409,
	w=64,
	h=34,
},
d_ambassador={
	x=263,
	y=67,
	w=92,
	h=32,
},
d_huntsman={
	x=263,
	y=98,
	w=96,
	h=32,
},
d_huntsman_burning={
	x=263,
	y=190,
	w=68,
	h=33,
},
d_huntsman_flyingburn={
	x=263,
	y=223,
	w=103,
	h=32,
},
d_taunt_spy={
	x=263,
	y=129,
	w=92,
	h=32,
},
d_huntsman_headshot={
	x=192,
	y=289,
	w=64,
	h=32,
},
d_ambassador_headshot={
	x=192,
	y=322,
	w=64,
	h=32,
},
d_taunt_sniper={
	x=263,
	y=161,
	w=94,
	h=27,
},
d_saw_kill={
	x=192,
	y=359,
	w=64,
	h=32,
},
d_deflect_arrow={
	x=360,
	y=0,
	w=64,
	h=30,
},
d_firedeath={
	x=263,
	y=256,
	w=64,
	h=32,
},
d_pumpkindeath={
	x=263,
	y=358,
	w=96,
	h=32,
},
d_taunt_soldier={		
	x=323,
	y=446,
	w=64,
	h=32,
},
d_taunt_demoman={	
	x=323,
	y=479,
	w=64,
	h=32,
},
d_sword={		
	x=258,
	y=464,
	w=64,
	h=32,
},
d_demoshield={	
	x=258,
	y=398,
	w=64,
	h=32,
},
d_pickaxe={	
	x=258,
	y=431,
	w=64,
	h=32,
},
d_rocketlauncher_directhit={		
	x=368,
	y=263,
	w=92,
	h=32,
},
d_sticky_resistance={	
	x=323,
	y=413,
	w=64,
	h=32,
},
d_player_sentry={	
	x=388,
	y=446,
	w=64,
	h=32,
},
d_battleaxe={
	x=368,
	y=164,
	w=64,
	h=32,
},
d_tribalkukri={	
	x=368,
	y=65,
	w=92,
	h=32,
},
d_sledgehammer={	
	x=368,
	y=98,
	w=64,
	h=32,
},
d_paintrain={	
	x=368,
	y=131,
	w=64,
	h=32,
},
d_samrevolver={
	x=368,
	y=230,
	w=98,
	h=32,
},
d_natascha={
	x=368,
	y=297,
	w=98,
	h=32,
},
d_maxgun={
	x=368,
	y=330,
	w=98,
	h=32,
},
d_force_a_nature={
	x=368,
	y=363,
	w=128,
	h=32,
},

}, -- ["_images"]

["_images_v2"]={

d_wrench_golden={
	x=0,
	y=736,
	w=96,
	h=32,
},

d_building_carried_destroyed={
	x=0,
	y=768,
	w=96,
	h=32,
},
d_taunt_guitar_kill={
	x=0,
	y=704,
	w=96,
	h=32,
},
d_frontier_kill={
	x=256,
	y=96,
	w=128,
	h=32,
},
d_wrench_golden={
	x=0,
	y=736,
	w=96,
	h=32,
},
d_southern_comfort_kill={
	x=256,
	y=992,
	w=64,
	h=32,
},
d_bleed_kill={
	x=256,
	y=928,
	w=32,
	h=32,
},
d_wrangler_kill={
	x=256,
	y=960,
	w=32,
	h=32,
},
d_robot_arm_kill={
	x=0,
	y=800,
	w=96,
	h=32,
},
d_robot_arm_combo_kill={
	x=0,
	y=832,
	w=96,
	h=32,
},
d_robot_arm_blender_kill={
	x=0,
	y=864,
	w=96,
	h=32,
},
d_degreaser={
	x=0,
	y=896,
	w=96,
	h=32,
},
d_powerjack={
	x=0,
	y=928,
	w=96,
	h=32,
},
d_eternal_reward={
	x=0,
	y=960,
	w=96,
	h=32,
},
d_letranger={
	x=0,
	y=992,
	w=96,
	h=32,
},
d_short_stop={
	x=256,
	y=896,
	w=64,
	h=32,
},
d_holy_mackerel={
	x=96,
	y=992,
	w=96,
	h=32,
},
d_headtaker={
	x=256,
	y=128,
	w=128,
	h=32,
},

}, -- ["_images_v2"]

["_images_custom"]={
d_blutsauger={
	x=0,
	y=0,
	w=96,
	h=32,
},
d_crotchshot={
	x=24,
	y=96,
	w=42,
	h=32,
},

-- CUSTOM WEAPONS
d_firecannone={
	x=0,
	y=128,
	w=96,
	h=32,
},
d_leviathan={
	x=0,
	y=160,
	w=96,
	h=32,
},
d_bofors={
	x=0,
	y=192,
	w=96,
	h=32,
},
-- /CUSTOM WEAPONS

d_amputator={
	x=96,
	y=0,
	w=96,
	h=32,
},
d_back_scratcher={
	x=96,
	y=32,
	w=96,
	h=32,
},
d_boston_basher={
	x=96,
	y=64,
	w=96,
	h=32,
},
d_ullapool_caber_explosion={
	x=96,
	y=96,
	w=96,
	h=32,
},
d_ullapool_caber={
	x=96,
	y=128,
	w=96,
	h=32,
},
d_claidheamohmor={
	x=96,
	y=160,
	w=96,
	h=32,
},
d_lochnload={
	x=96,
	y=192,
	w=96,
	h=32,
},
d_steel_fists={
	x=96,
	y=224,
	w=78,
	h=32,
},
d_bear_claws={
	x=96,
	y=256,
	w=78,
	h=32,
},
d_candy_cane={
	x=96,
	y=288,
	w=96,
	h=32,
},
d_gatling={
	x=96,
	y=320,
	w=96,
	h=32,
},
d_wrench_jag={
	x=96,
	y=352,
	w=96,
	h=32,
},
d_crusaders_crossbow={
	x=96,
	y=384,
	w=96,
	h=32,
},
d_fryingpan={
	x=96,
	y=416,
	w=96,
	h=32,
},
}, -- ["_images_custom"]

["_images_hl2"]={
d_hl_crossbow={
	x=0,
	y=0,
	w=96,
	h=32,
},
d_hl_shotgun={
	x=0,
	y=32,
	w=96,
	h=32,
},
d_hl_ar2={
	x=0,
	y=64,
	w=96,
	h=32,
},
d_hl_frag={
	x=0,
	y=96,
	w=96,
	h=32,
},
d_hl_crowbar={
	x=0,
	y=128,
	w=96,
	h=32,
},
d_hl_pistol={
	x=0,
	y=160,
	w=96,
	h=32,
},
d_hl_357={
	x=0,
	y=192,
	w=96,
	h=32,
},
d_hl_smg={
	x=0,
	y=224,
	w=96,
	h=32,
},
d_hl_stunstick={
	x=0,
	y=256,
	w=96,
	h=32,
},
d_hl_physics={
	x=0,
	y=288,
	w=96,
	h=32,
},
d_hl_combine_ball={
	x=0,
	y=320,
	w=96,
	h=32,
},
d_hl_rpg={
	x=0,
	y=352,
	w=96,
	h=32,
},
d_hl_ar2_grenade={
	x=0,
	y=384,
	w=96,
	h=32,
},
d_deflect_frag={
	x=0,
	y=416,
	w=64,
	h=32,
},
d_deflect_ar2grenade={
	x=0,
	y=448,
	w=64,
	h=32,
},
d_deflect_rpg={
	x=0,
	y=480,
	w=64,
	h=32,
},
d_hl_zombie={
	x=96,
	y=0,
	w=96,
	h=32,
},
d_hl_antlion={
	x=96,
	y=32,
	w=96,
	h=32,
},
d_hl_headcrab={
	x=96,
	y=64,
	w=96,
	h=32,
},
d_hl_hunter_pound={
	x=96,
	y=96,
	w=96,
	h=32,
},
d_hl_hunter_skewer={
	x=96,
	y=128,
	w=96,
	h=32,
},
d_hl_antlionguard={
	x=96,
	y=160,
	w=96,
	h=32,
},
d_hl_hunter_charge={
	x=96,
	y=192,
	w=96,
	h=32,
},
d_hl_acidball={
	x=96,
	y=224,
	w=96,
	h=32,
},
d_hl_flechette={
	x=96,
	y=256,
	w=96,
	h=32,
},
d_hl_antworker_explosion={
	x=96,
	y=288,
	w=96,
	h=32,
},
d_hl_vortigaunt_beam={
	x=96,
	y=320,
	w=96,
	h=32,
},
d_hl_vortigaunt={
	x=96,
	y=352,
	w=96,
	h=32,
},
d_deflect_crossbowbolt={
	x=96,
	y=416,
	w=64,
	h=32,
},
d_deflect_combineball={
	x=96,
	y=448,
	w=64,
	h=32,
},
d_deflect_acidball={
	x=96,
	y=480,
	w=64,
	h=32,
},
d_hl_rollermine={
	x=192,
	y=0,
	w=96,
	h=32,
},
d_hl_manhack={
	x=192,
	y=32,
	w=96,
	h=32,
},
d_hl_floorturret={
	x=192,
	y=64,
	w=96,
	h=32,
},
d_hl_combine_mine={
	x=192,
	y=96,
	w=96,
	h=32,
},
d_hl_airboat_gun={
	x=192,
	y=128,
	w=96,
	h=32,
},
d_hl_strider_minigun={
	x=192,
	y=160,
	w=96,
	h=32,
},
d_hl_strider_beam={
	x=192,
	y=192,
	w=96,
	h=32,
},
d_hl_strider_skewer={
	x=192,
	y=224,
	w=96,
	h=32,
},
d_have_an_error={
	x=192,
	y=480,
	w=96,
	h=32,
},
} -- ["_images_hl2"]
} -- Killicons
