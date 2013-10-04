if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Grenade Launcher (test 1)"
SWEP.Slot				= 0

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_grenadelauncher_demo.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_grenadelauncher.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.MuzzleEffect = "muzzle_grenadelauncher"

SWEP.ShootSound = Sound("Weapon_GrenadeLauncher.Single")
SWEP.ShootCritSound = Sound("Weapon_GrenadeLauncher.SingleCrit")

SWEP.Primary.ClipSize		= 4
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.6

SWEP.IsRapidFire = false
SWEP.ReloadSingle = true

SWEP.HoldType = "SECONDARY"

SWEP.ProjectileShootOffset = Vector(0, 7.3322, -8.1759)
SWEP.Force = 1065
SWEP.AddPitch = -4

SWEP.Properties = {}

function SWEP:ShootProjectile()
	if SERVER then
		local grenade = ents.Create("tf_projectile_pipe")
		grenade:SetPos(self:ProjectileShootPos())
		grenade:SetAngles(self.Owner:EyeAngles())
		
		if self:Critical() then
			grenade.critical = true
		end
		
		grenade.Round = true
		for k,v in pairs(self.Properties) do
			grenade[k] = v
		end
		
		grenade:SetOwner(self.Owner)
		
		grenade:Spawn()
		
		local vel = self.Owner:GetAimVector():Angle()
		vel.p = vel.p + self.AddPitch
		vel = vel:Forward() * self.Force * (grenade.Mass or 10)
		
		grenade:GetPhysicsObject():AddAngleVelocity(Vector(math.random(-2000,2000),math.random(-2000,2000),math.random(-2000,2000)))
		grenade:GetPhysicsObject():ApplyForceCenter(vel)
	end
	
	self:ShootEffects()
end
