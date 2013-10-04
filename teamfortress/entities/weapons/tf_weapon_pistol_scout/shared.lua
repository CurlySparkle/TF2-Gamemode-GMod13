if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Pistol"
SWEP.Slot				= 1
end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_pistol_scout.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_pistol.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = "muzzle_pistol"
--SWEP.BetaMuzzle = "tf_muzzleflash_beta"
SWEP.MuzzleOffset = Vector(20, 4, -2)

SWEP.ShootSound = Sound("weapons/pistol_shoot.wav")
SWEP.ShootCritSound = Sound("Weapon_Pistol.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_Pistol.WorldReload")

SWEP.TracerEffect = "bullet_pistol_tracer01"
PrecacheParticleSystem("bullet_pistol_tracer01_red")
PrecacheParticleSystem("bullet_pistol_tracer01_red_crit")
PrecacheParticleSystem("bullet_pistol_tracer01_blue")
PrecacheParticleSystem("bullet_pistol_tracer01_blue_crit")
PrecacheParticleSystem("muzzle_pistol")

SWEP.BaseDamage = 15
SWEP.DamageRandomize = 0
SWEP.MaxDamageRampUp = 0.5
SWEP.MaxDamageFalloff = 0.5

SWEP.BulletsPerShot = 1
SWEP.BulletSpread = 0.04

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 0.17

SWEP.HoldType = "SECONDARY"

SWEP.IsRapidFire = true