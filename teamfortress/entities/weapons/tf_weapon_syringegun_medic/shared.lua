if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "Syringe Gun"
SWEP.Slot				= 0

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_syringegun_medic.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_syringegun.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_syringe"
PrecacheParticleSystem("muzzle_syringe")

SWEP.ShootSound = Sound("Weapon_SyringeGun.Single")
SWEP.ShootCritSound = Sound("Weapon_SyringeGun.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_SyringeGun.WorldReload")

SWEP.Primary.ClipSize		= 40
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_PRIMARY
SWEP.Primary.Delay          = 0.1

SWEP.BulletSpread = 0.02

SWEP.IsRapidFire = true
SWEP.ReloadSingle = false

SWEP.HoldType = "PRIMARY"

SWEP.ProjectileShootOffset = Vector(40, 8, -5)

function SWEP:ShootProjectile()
	if SERVER then
		local syringe = ents.Create("tf_projectile_syringe")
		local ang = self.Owner:EyeAngles()
		local vec = ang:Forward() + math.Rand(-self.BulletSpread,self.BulletSpread) * ang:Right() + math.Rand(-self.BulletSpread,self.BulletSpread) * ang:Up()
		
		syringe:SetPos(self:ProjectileShootPos())
		syringe:SetAngles(vec:Angle())
		if self:Critical() then
			syringe.critical = true
		end
		syringe:SetOwner(self.Owner)
		--syringe:SetProjectileType(1)
		
		self:InitProjectileAttributes(syringe)
		
		syringe:Spawn()
	end
	
	self:ShootEffects()
end
