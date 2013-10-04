CLASS.Name = "Spy"
CLASS.Speed = 100
CLASS.Health = 125

if CLIENT then
	CLASS.CharacterImage = {
		surface.GetTextureID("hud/class_spyred"),
		surface.GetTextureID("hud/class_spyblue")
	}
	CLASS.ScoreboardImage = {
		surface.GetTextureID("hud/leaderboard_class_spy"),
		surface.GetTextureID("hud/leaderboard_class_spy_d")
	}
end

CLASS.Loadout = {"tf_weapon_revolver", "tf_weapon_sapper", "tf_weapon_knife", "tf_weapon_pda_spy"}
CLASS.DefaultLoadout = {"TF_WEAPON_REVOLVER", "TF_WEAPON_KNIFE", "TF_WEAPON_PDA_SPY", "TF_WEAPON_INVIS"}
CLASS.ModelName = "spy"

CLASS.Buildings = {"OBJ_ATTACHMENT_SAPPER"}

CLASS.Gibs = {
	[GIB_LEFTLEG]		= GIBS_SPY_START,
	[GIB_RIGHTLEG]		= GIBS_SPY_START+1,
	[GIB_LEFTARM]		= GIBS_SPY_START+2,
	[GIB_RIGHTARM]		= GIBS_SPY_START+3,
	[GIB_TORSO]			= GIBS_SPY_START+5,
	[GIB_TORSO2]		= GIBS_SPY_START+4,
	[GIB_HEAD]			= GIBS_SPY_START+6,
	[GIB_ORGAN]			= GIBS_ORGANS_START,
}

CLASS.Sounds = {
	paincrticialdeath = {
		Sound("vo/spy_paincrticialdeath01.wav"),
		Sound("vo/spy_paincrticialdeath02.wav"),
		Sound("vo/spy_paincrticialdeath03.wav"),
	},
	painsevere = {
		Sound("vo/spy_painsevere01.wav"),
		Sound("vo/spy_painsevere02.wav"),
		Sound("vo/spy_painsevere03.wav"),
		Sound("vo/spy_painsevere04.wav"),
		Sound("vo/spy_painsevere05.wav"),
	},
	painsharp = {
		Sound("vo/spy_painsharp01.wav"),
		Sound("vo/spy_painsharp02.wav"),
		Sound("vo/spy_painsharp03.wav"),
		Sound("vo/spy_painsharp04.wav"),
	},
}

CLASS.AmmoMax = {
	[TF_PRIMARY]	= 20,		-- primary
	[TF_SECONDARY]	= 24,		-- secondary
	[TF_METAL]		= 100,		-- metal
	[TF_GRENADES1]	= 0,		-- grenades1
	[TF_GRENADES2]	= 1,		-- grenades2
}
