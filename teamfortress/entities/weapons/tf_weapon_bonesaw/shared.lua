if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Bonesaw"
SWEP.Slot				= 2
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_bonesaw_medic.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_bonesaw.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Bonesaw.Miss")
SWEP.SwingCrit = Sound("Weapon_Bonesaw.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Bonesaw.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Bonesaw.HitWorld")

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay          = 0.8

SWEP.HoldType = "MELEE"

if CLIENT then

function SWEP:ViewModelDrawn()
	if IsValid(self.CModel) then
		self.CModel:SetPoseParameter("syringe_charge_level", self.Owner:GetNWInt("Ubercharge") * 0.01)
	end
	
	self:CallBaseFunction("ViewModelDrawn")
end

function SWEP:DrawWorldModel(from_postplayerdraw)
	if IsValid(self.WModel2) then
		self.WModel2:SetPoseParameter("syringe_charge_level", self.Owner:GetNWInt("Ubercharge") * 0.01)
	end
	
	self:CallBaseFunction("DrawWorldModel", from_postplayerdraw)
end

end

function SWEP:MeleeHitSound(tr)
	if self.CustomSound1 and tr.Entity:IsTFPlayer() and not tr.Entity:IsBuilding() then
		self:EmitSound(self.CustomSound1)
	else
		self:BaseCall(tr)
	end
end