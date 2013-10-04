CLASS.Name = "Heavy"
CLASS.Speed = 77
CLASS.Health = 300

if CLIENT then
	CLASS.CharacterImage = {
		surface.GetTextureID("hud/class_heavyred"),
		surface.GetTextureID("hud/class_heavyblue")
	}
	CLASS.ScoreboardImage = {
		surface.GetTextureID("hud/leaderboard_class_heavy"),
		surface.GetTextureID("hud/leaderboard_class_heavy_d")
	}
end

CLASS.Loadout = {"tf_weapon_minigun", "tf_weapon_shotgun_hwg", "tf_weapon_fists"}
CLASS.DefaultLoadout = {"TF_WEAPON_MINIGUN","TF_WEAPON_SHOTGUN_HWG","TF_WEAPON_FISTS"}
CLASS.ModelName = "heavy"

-- Prevents T posing when being moved while crouching with the minigun winded up
CLASS.NoDeployedCrouchwalk = true

CLASS.Gibs = {
	[GIB_LEFTLEG]		= GIBS_HEAVY_START,
	[GIB_RIGHTLEG]		= GIBS_HEAVY_START+1,
	[GIB_RIGHTARM]		= GIBS_HEAVY_START+4,
	[GIB_TORSO]			= GIBS_HEAVY_START+5,
	[GIB_TORSO2]		= GIBS_HEAVY_START+3,
	[GIB_EQUIPMENT1]	= GIBS_HEAVY_START+2,
	[GIB_EQUIPMENT2]	= GIBS_HEAVY_START+2,
	[GIB_HEAD]			= GIBS_HEAVY_START+6,
	[GIB_ORGAN]			= GIBS_ORGANS_START,
}

CLASS.Sounds = {
	paincrticialdeath = {
		Sound("vo/heavy_paincrticialdeath01.wav"),
		Sound("vo/heavy_paincrticialdeath02.wav"),
		Sound("vo/heavy_paincrticialdeath03.wav"),
	},
	painsevere = {
		Sound("vo/heavy_painsevere01.wav"),
		Sound("vo/heavy_painsevere02.wav"),
		Sound("vo/heavy_painsevere03.wav"),
	},
	painsharp = {
		Sound("vo/heavy_painsharp01.wav"),
		Sound("vo/heavy_painsharp02.wav"),
		Sound("vo/heavy_painsharp03.wav"),
		Sound("vo/heavy_painsharp04.wav"),
		Sound("vo/heavy_painsharp05.wav"),
	},
}

CLASS.AmmoMax = {
	[TF_PRIMARY]	= 200,		-- primary
	[TF_SECONDARY]	= 32,		-- secondary
	[TF_METAL]		= 100,		-- metal
	[TF_GRENADES1]	= 0,		-- grenades1
	[TF_GRENADES2]	= 0,		-- grenades2
}

if SERVER then

-- damn this shit must be deprecated since the day gran started liking dicks
function CLASS:Initialize()
	self.minigunfiretime = 0
end

function CLASS:PlayCustomGesture(anim, state)
	local actname
	if anim==10004 then
		actname = "ACT_MP_ATTACK_"..(WeaponGestureTranslateTable[state] or "STAND").."_PREFIRE"
	elseif anim==10005 then
		actname = "ACT_MP_ATTACK_"..(WeaponGestureTranslateTable[state] or "STAND").."_POSTFIRE"
	end
	
	if actname then
		act2 = getfenv()[actname]
		Msg("Gesture : "..actname.." : "..tostring(act2).."\n")
		self:RestartGesture(act2)
		return true
	end
end

function CLASS:OverrideActivity(anim, state)
	if self:GetNWBool("MinigunReady") then
		local actname = ""
		
		local wstate = WeaponGestureTranslateTable[state] or "STAND"
		if wstate=="STAND" then
			actname = "ACT_MP_DEPLOYED_"
		else
			actname = "ACT_MP_"..wstate.."_DEPLOYED_"
		end
		
		if state=="STAND" or wstate=="CROUCH" then
			actname = actname.."IDLE"
		else
			actname = actname.."PRIMARY"
		end
		
		return getfenv()[actname]
	end
end

end
--[[
if CLIENT then

function CLASS:ModifyMaxAnimSpeed(speed)
	if self:GetNWBool("MinigunReady") then
		return 12
	else
		local w = self:GetActiveWeapon()
		if w and w:IsValid() and w:GetClass()=="tf_weapon_minigun" then
			return 30
		end
	end
	return speed
end

end
]]
