if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "Wrench"
SWEP.Slot				= 2
SWEP.GlobalCustomHUD = {HudAccountPanel = true}
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/v_models/v_wrench_engineer.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_wrench.mdl"
SWEP.Crosshair = "tf_crosshair3"

SWEP.Swing = Sound("Weapon_Wrench.Miss")
SWEP.SwingCrit = Sound("Weapon_Wrench.MissCrit")
SWEP.HitFlesh = Sound("Weapon_Wrench.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Wrench.HitWorld")
SWEP.HitBuildingSuccess = Sound("Weapon_Wrench.HitBuilding_Success")
SWEP.HitBuildingFailure = Sound("Weapon_Wrench.HitBuilding_Failure")

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Delay          = 0.8

SWEP.HoldType = "MELEE"

SWEP.NoHitSound = true
SWEP.UpgradeSpeed = 25

function SWEP:OnMeleeHit(tr)
	if tr.Entity and tr.Entity:IsValid() then
		if tr.Entity:IsBuilding() then
			local ent = tr.Entity
			
			if ent.IsTFBuilding and ent:IsFriendly(self.Owner) then
				if SERVER then
					local m = ent:AddMetal(self.Owner, self.Owner:GetAmmoCount(TF_METAL))
					if m > 0 then
						self:EmitSound(self.HitBuildingSuccess)
						self.Owner:RemoveAmmo(m, TF_METAL)
						umsg.Start("PlayerMetalBonus", self.Owner)
							umsg.Short(-m)
						umsg.End()
					elseif ent:GetState() == 1 then
						self:EmitSound(self.HitBuildingSuccess)
					else
						self:EmitSound(self.HitBuildingFailure)
					end
				end
			else
				self:EmitSound(self.HitWorld)
			end
		elseif tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
			self:EmitSound(self.HitFlesh)
		else
			self:EmitSound(self.HitWorld)
		end
	elseif tr.HitWorld then
		self:EmitSound(self.HitWorld)
	end
end
