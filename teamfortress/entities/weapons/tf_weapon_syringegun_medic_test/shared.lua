if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Syringe Gun (test 1)"
SWEP.Slot				= 0

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_syringegun_medic.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_syringegun.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_syringe"

--SWEP.ShootSound = Sound("Weapon_SyringeGun.Single")
SWEP.ShootSound = ")weapons/syringegun_shoot.wav"
SWEP.ShootSoundLevel = 94
SWEP.ShootSoundPitch = 80
SWEP.ShootCritSound = Sound("Weapon_SyringeGun.SingleCrit")

SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.4

SWEP.BulletSpread = 0

SWEP.IsRapidFire = true
SWEP.ReloadSingle = false

SWEP.HoldType = "PRIMARY"

SWEP.ProjectileShootOffset = Vector(0, 8, -5)

function SWEP:ShootProjectile()
	if SERVER then
		local syringe = ents.Create("tf_projectile_syringe")
		local ang = self.Owner:EyeAngles()
		local vec = ang:Forward()
		
		syringe:SetPos(self:ProjectileShootPos())
		syringe:SetAngles(vec:Angle())
		if self:Critical() then
			syringe.critical = true
		end
		syringe.Force = self.Force
		syringe:SetOwner(self.Owner)
		syringe:SetProjectileType(3)
		syringe:Spawn()
	end
	
	self:ShootEffects()
end
