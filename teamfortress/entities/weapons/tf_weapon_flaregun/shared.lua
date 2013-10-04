if SERVER then
	AddCSLuaFile( "shared.lua" )
	
end

if CLIENT then

SWEP.PrintName			= "The Flare Gun"
SWEP.HasCModel = true
SWEP.Slot				= 1

end

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/c_models/c_pyro_arms.mdl"
SWEP.WorldModel			= "models/weapons/c_models/c_flaregun_pyro/c_flaregun_pyro.mdl"
SWEP.Crosshair = "tf_crosshair1"

SWEP.MuzzleEffect = ""

SWEP.ShootSound = Sound("weapons/flaregun_shoot.wav")
SWEP.ShootCritSound = Sound("TFWeapon_FlareGun.SingleCrit")
SWEP.ReloadSound = Sound("Weapon_FlareGun.WorldReload")

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= SWEP.Primary.ClipSize
SWEP.Primary.Ammo			= TF_SECONDARY
SWEP.Primary.Delay          = 2.02

SWEP.IsRapidFire = false
SWEP.ReloadSingle = false

SWEP.HoldType = "ITEM1"

SWEP.ProjectileShootOffset = Vector(0, 8, -5)

SWEP.VM_DRAW = ACT_ITEM1_VM_DRAW
SWEP.VM_IDLE = ACT_ITEM1_VM_IDLE
SWEP.VM_PRIMARYATTACK = ACT_ITEM1_VM_PRIMARYATTACK
SWEP.VM_RELOAD = ACT_ITEM1_VM_RELOAD

function SWEP:PrimaryAttack()
	if self.NextIdle then return end
	
	if not self:CanPrimaryAttack() then
		return
	end
	
	self:SendWeaponAnim(self.VM_PRIMARYATTACK)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	self:ShootProjectile()
	
	self.NextIdle = CurTime()+self:SequenceDuration()
	
	self:TakePrimaryAmmo(1)
	
	self:RollCritical()
end

function SWEP:ShootProjectile()
	if SERVER then
		-- lol syringe
		
		local syringe = ents.Create("tf_projectile_flare")
		local ang = self.Owner:EyeAngles()
		
		syringe:SetPos(self:ProjectileShootPos())
		syringe:SetAngles(ang)
		syringe.Inflictor = self
		if self:Critical() then
			syringe.critical = true
		end
		syringe:SetOwner(self.Owner)
		self:InitProjectileAttributes(syringe)
		
		syringe.NameOverride = self:GetItemData().item_iconname
		syringe:Spawn()
	end
	
	self:ShootEffects()
end

function SWEP:Think()
	if self.NextIdle and CurTime()>=self.NextIdle then
		self:SendWeaponAnim(self.VM_IDLE)
		self.NextIdle = nil
	end
end

local WeaponBodygroups = {
	shell = 1,
}

function SWEP:FireAnimationEvent(pos, ang, event, options)
	if event == 37 then
		local bodygroup, set = string.match(options, "(.-)%s+(%d+)")
		bodygroup = WeaponBodygroups[bodygroup or ""]
		set = tonumber(set)
		
		if bodygroup and set and IsValid(self.CModel) then
			self.CModel:SetBodygroup(bodygroup, set)
		end
	end
end
