-- Real class name: tf_weapon_bet_rocketlauncher (see shd_items.lua)

if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then

SWEP.PrintName			= "The Original"
SWEP.Slot				= 0
SWEP.HasCModel = true

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/c_models/c_soldier_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.MuzzleEffect = "muzzle_pipelauncher"

SWEP.ShootSound = Sound("Weapon_QuakeRPG.Single")
SWEP.ShootCritSound = Sound("Weapon_QuakeRPG.SingleCrit")
SWEP.CustomExplosionSound = Sound("Weapon_QuakeRPG.Reload")
SWEP.Primary.Reload = Sound("Weapon_QuakeRPG.Reload")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.8

SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "PRIMARY"

SWEP.ProjectileShootOffset = Vector(30, 0, -6)

SWEP.Properties = {}

SWEP.VM_DRAW = ACT_VM_DRAW_QRL
SWEP.VM_IDLE = ACT_VM_IDLE_QRL
ACT_VM_PULLBACK = ACT_VM_PULLBACK_QRL
SWEP.VM_PRIMARYATTACK = ACT_VM_PRIMARYATTACK_QRL
SWEP.VM_RELOAD = ACT_VM_RELOAD_QRL
SWEP.VM_RELOAD_START = ACT_VM_RELOAD_START_QRL
SWEP.VM_RELOAD_FINISH = ACT_VM_RELOAD_FINISH_QRL

function SWEP:ShootProjectile()
	if SERVER then
		local rocket = ents.Create("tf_projectile_rocket")
		rocket:SetPos(self:ProjectileShootPos())
		local ang = self.Owner:EyeAngles()
		
		if self.WeaponMode == 1 then
			local charge = (CurTime() - self.ChargeStartTime) / self.ChargeTime
			rocket.Gravity = Lerp(1 - charge, self.MinGravity, self.MaxGravity)
			rocket.BaseSpeed = Lerp(charge, self.MinForce, self.MaxForce)
			ang.p = ang.p + Lerp(1 - charge, self.MinAddPitch, self.MaxAddPitch)
		end
		
		rocket:SetAngles(ang)
		
		if self:Critical() then
			rocket.critical = true
		end
		
		for k,v in pairs(self.Properties) do
			rocket[k] = v
		end
		
		rocket:SetOwner(self.Owner)
		self:InitProjectileAttributes(rocket)
		
		rocket:Spawn()
		rocket:Activate()
	end
	
	self:ShootEffects()
end