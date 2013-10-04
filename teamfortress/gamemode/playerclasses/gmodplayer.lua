-- Regular GMod player, as if you were playing sandbox

if CLIENT then
	CLASS.ScoreboardImage = {
		surface.GetTextureID("vgui/modicon.vmt"),
	}
end

CLASS.Name = "GMod Player"
CLASS.Speed = 83
CLASS.Health = 100

CLASS.AdditionalAmmo = {
	Pistol = 256,
	SMG1 = 256,
	grenade = 5,
	Buckshot = 64,
	["357"] = 32,
	XBowBolt = 32,
	AR2AltFire = 6,
	AR2 = 100,
	SMG1_Grenade = 6,
}

CLASS.Loadout = {
	"weapon_crowbar",
	"weapon_pistol",
	"weapon_smg1",
	"weapon_frag",
	"weapon_physcannon",
	"weapon_crossbow",
	"weapon_shotgun",
	"weapon_357",
	"weapon_rpg",
	"weapon_ar2",
	
	"gmod_tool",
	"gmod_camera",
	"weapon_physgun",
}

CLASS.ModelName = "scout"

CLASS.IsHL2 = true

if SERVER then

function CLASS:Initialize()
	local cl_playermodel = self:GetInfo("cl_playermodel")
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
	util.PrecacheModel(modelname)
	self:SetModel(modelname)
	
	local cl_defaultweapon = self:GetInfo("cl_defaultweapon")

	if self:HasWeapon(cl_defaultweapon) then
		self:SelectWeapon(cl_defaultweapon) 
	end
end

end