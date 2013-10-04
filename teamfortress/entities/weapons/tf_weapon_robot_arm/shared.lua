if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName			= "The Gunslinger"
SWEP.Slot				= 2
SWEP.GlobalCustomHUD = {HudAccountPanel = true}
end

SWEP.Base				= "tf_weapon_melee_base"

SWEP.ViewModel			= "models/weapons/c_models/c_engineer_arms.mdl"
SWEP.WorldModel			= ""
SWEP.Crosshair = "tf_crosshair3"

SWEP.DropPrimaryWeaponInstead = true

SWEP.Swing = Sound("Weapon_Gunslinger.Swing")
SWEP.SwingCrit = Sound("Weapon_Gunslinger.Swing")
SWEP.HitFlesh = Sound("Weapon_Wrench.HitFlesh")
SWEP.HitWorld = Sound("Weapon_Wrench.HitWorld")
SWEP.HitBuildingSuccess = Sound("Weapon_Wrench.HitBuilding_Success")
SWEP.HitBuildingFailure = Sound("Weapon_Wrench.HitBuilding_Failure")

SWEP.BaseDamage = 65
SWEP.DamageRandomize = 0.1
SWEP.MaxDamageRampUp = 0
SWEP.MaxDamageFalloff = 0

SWEP.Primary.Delay          = 0.8

SWEP.HoldType = "ITEM2"

SWEP.NoHitSound = true
SWEP.UpgradeSpeed = 25
SWEP.HasThirdpersonCritAnimation = true

SWEP.AltIdleAnimationProbability = 0.1

function SWEP:SetupDataTables()
	self:CallBaseFunction("SetupDataTables")
	self:DTVar("Int", 1, "Combo")
end

function SWEP:SetupCModelActivities(item, noreplace)
	self:CallBaseFunction("SetupCModelActivities", item, noreplace)
	
	if item then
		local hold = string.upper(item.anim_slot or item.item_slot)
		
		self.VM_HITCENTER		= _E["ACT_"..hold.."_VM_HITCENTER"] or ACT_VM_HITCENTER
		self.VM_SWINGHARD		= _E["ACT_"..hold.."_VM_SWINGHARD"] or ACT_VM_SWINGHARD
	end
end

function SWEP:OnMeleeAttack(tr)
	if SERVER then
		local hit = false
		
		if IsValid(tr.Entity) and tr.Entity:IsTFPlayer() then
			hit = true
		end
		
		if hit then
			self.HasHit = true
		else
			self.dt.Combo = 0
		end
	end
end

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

	if SERVER then
		if self.HasHit then
			self.dt.Combo = self.dt.Combo + 1
			self.HasHit = false
		end
		
		if self.dt.Combo > 2 then
			self.dt.Combo = 0
		end
	end
end

function SWEP:Critical(ent,dmginfo)
	if self.dt.Combo >= 2 then
		return true
	end
	
	return self:CallBaseFunction("Critical", ent, dmginfo)
end

function SWEP:PredictCriticalHit()
	if self.dt.Combo >= 2 then
		self.NameOverride = "robot_arm_combo_kill"
		return true
	else
		self.NameOverride = nil
	end
end

function SWEP:Think()
	if not game.SinglePlayer() or SERVER then
		if self.NextIdle and CurTime()>=self.NextIdle then
			if self.PlayingIdle2Animation then
				self.PlayingIdle2Animation = false
			elseif math.Rand(0,1) <= self.AltIdleAnimationProbability and not self.PlayingIdle2Animation then
				self:SendWeaponAnim(self.VM_IDLE_2)
				self.NextIdle = CurTime() + self:SequenceDuration()
				self.PlayingIdle2Animation = true
			end
		end
	end
	
	if SERVER and not self.Owner:KeyDown(IN_ATTACK) then
		self.dt.Combo = 0
	end
	
	self:CallBaseFunction("Think")
end
