
local tf_targe_enhanced_charge = CreateConVar("tf_targe_enhanced_charge", 1, {FCVAR_CHEAT})

ENT.Type 			= "anim"
ENT.Base 			= "tf_wearable_item"

ENT.MeleeRange = 50

ENT.ForceMultiplier = 10000
ENT.CritForceMultiplier = 10000
ENT.ForceAddPitch = 20
ENT.CritForceAddPitch = 0

ENT.DefaultBaseDamage = 0
ENT.DamagePerHead = 10
--ENT.MaxHeads = 5

ENT.BaseDamage = 0
ENT.DamageRandomize = 0
ENT.MaxDamageRampUp = 0
ENT.MaxDamageFalloff = 0

ENT.HitPlayerSound = Sound("DemoCharge.HitFlesh")
ENT.HitPlayerRangeSound = Sound("DemoCharge.HitFleshRange")
ENT.HitWorldSound = Sound("DemoCharge.HitWorld")

ENT.CritStartSound = Sound("DemoCharge.ChargeCritOn")
ENT.CritStopSound = Sound("DemoCharge.ChargeCritOff")

ENT.DefaultChargeDuration = 9999
ENT.ChargeCooldownDuration = 0

ENT.ChargeSteerConstraint = 0.7

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:DTVar("Bool", 0, "Charging")
	self:DTVar("Bool", 1, "Ready")
	self:DTVar("Float", 0, "NextEndCharge")
	self:DTVar("Float", 1, "AdditiveChargeDuration")
	self:DTVar("Float", 2, "ChargeCooldownMultiplier")
end

if CLIENT then

ENT.GlobalCustomHUD = {HudDemomanCharge = true}

function ENT:InitializeCModel(weapon)
	local vm = self.Owner:GetViewModel()
	
	if IsValid(vm) then
		self.CModel = ClientsideModel(self.Model)
		if not IsValid(self.CModel) then return end
		
		self.CModel:SetPos(vm:GetPos())
		self.CModel:SetAngles(vm:GetAngles())
		self.CModel:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL))
		self.CModel:SetParent(vm)
		self.CModel:SetNoDraw(true)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if not self.Initialized then
		self.Initialized = true
		if IsValid(self.Owner) then
			self.Owner.TargeEntity = self
			if self.Owner == LocalPlayer() then
				HudDemomanPipes:SetProgress(1)
				HudDemomanPipes:SetChargeStatus(0)
			end
		end
	end
	
	if self.Owner == LocalPlayer() then
		if self.dt.Charging then
			if not self.ChargeDuration then
				self.ChargeDuration = self.DefaultChargeDuration + self.dt.AdditiveChargeDuration
			end
			
			local p = (self.dt.NextEndCharge - CurTime()) / self.ChargeDuration
			local p0 = p * (self.DefaultChargeDuration / self.ChargeDuration)
			
			if p0 < 0.33 then
				HudDemomanPipes:SetChargeStatus(3)
			elseif p0 < 0.66 then
				HudDemomanPipes:SetChargeStatus(2)
			else
				HudDemomanPipes:SetChargeStatus(1)
			end
			
			HudDemomanPipes:SetProgress(p)
		else
			HudDemomanPipes:SetChargeStatus(0)
			if self.dt.Ready then
				HudDemomanPipes:SetProgress(1)
			else
				self.ChargeDuration = nil
				
				local cooldown = self.ChargeCooldownDuration * self.dt.ChargeCooldownMultiplier
				local p = 1 - (self.dt.NextEndCharge - CurTime()) / cooldown
				HudDemomanPipes:SetProgress(p)
			end
		end
	end
end

hook.Add("PlayerBindPress", "TargeChargeBindPress", function(pl, cmd, down)
	local t = LocalPlayer().TargeEntity
	if IsValid(t) and t.dt and t.dt.Charging then
		if string.find(cmd, "+jump") then
			return true
		elseif string.find(cmd, "+duck") then
			return true
		end
	end
end)

hook.Add("CreateMove", "TargeChargeCreateMove", function(cmd)
	local t = LocalPlayer().TargeEntity
	if IsValid(t) and t.dt and t.dt.Charging then
		local ang = cmd:GetViewAngles()
		if LocalPlayer().SavedTargeAngle then
			local oldyaw = LocalPlayer().SavedTargeAngle.y
			
			ang.y = oldyaw + math.Clamp(math.AngleDifference(ang.y, oldyaw), -t.ChargeSteerConstraint, t.ChargeSteerConstraint)
			cmd:SetViewAngles(ang)
		end
		LocalPlayer().SavedTargeAngle = ang
	else
		LocalPlayer().SavedTargeAngle = nil
	end
end)

end

if SERVER then

AddCSLuaFile("shared.lua")

function ENT:CanChargeThrough(ent)
	if ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" then
		return (ent:GetPhysicsObject():IsValid() and ent:GetPhysicsObject():IsMoveable() and ent:GetPhysicsObject():GetMass() < 200) or
				(ent:GetMaxHealth() > 1)
	elseif ent:GetClass() == "prop_dynamic" or ent:GetClass() == "prop_dynamic_override" then
		return ent:GetMaxHealth() > 1
	elseif ent:GetClass() == "func_breakable" then
		return true
	end
	
	return false
end

function ENT:MeleeAttack()
	if not IsValid(self.Owner) then return end
	
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:EyeAngles()
	ang.p = 0
	local endpos = pos + ang:Forward() * self.MeleeRange
	
	local hitent, hitpos, dmginfo
	
	--self.Owner:LagCompensation(true)
	
	local tr = util.TraceLine {
		start = pos,
		endpos = endpos,
		filter = self.Owner
	}
	
	if not tr.Hit then
		local mins, maxs = Vector(-20, -20, -40), Vector(20, 20, 20)
		
		tr = util.TraceHull {
			start = pos,
			endpos = endpos,
			filter = self.Owner,
		
			mins = mins,
			maxs = maxs,
		}
	end
	
	--self.Owner:LagCompensation(false)
	
	if tr.Entity and tr.Entity:IsValid() then
		if self.Owner:IsFriendly(tr.Entity) or self.Owner:GetSolid() == SOLID_NONE then
			return
		end
		
		local ang = self.Owner:EyeAngles()
		local dir = ang:Forward()
		hitpos = tr.Entity:NearestPoint(self.Owner:GetShootPos()) - 2 * dir
		tr.HitPos = hitpos
		
		if self.Owner:CanDamage(tr.Entity) then
			local pitch, mul, dmgtype
			
			dmgtype = DMG_SLASH
			pitch, mul = self.ForceAddPitch, self.ForceMultiplier
			
			ang.p = math.Clamp(math.NormalizeAngle(ang.p - pitch), -90, 90)
			local force_dir = ang:Forward()
			
			--self.BaseDamage = self.DefaultBaseDamage + self.DamagePerHead * math.min(self.Owner:GetNWInt("Heads"), self.MaxHeads)
			self.BaseDamage = self.DefaultBaseDamage + self.DamagePerHead * self.Owner:GetNWInt("Heads")
			
			local dmg = tf_util.CalculateDamage(self, hitpos)
			
			dmginfo = DamageInfo()
				dmginfo:SetAttacker(self.Owner)
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(dmg)
				dmginfo:SetDamageType(dmgtype)
				dmginfo:SetDamagePosition(hitpos)
				dmginfo:SetDamageForce(dmg * force_dir * mul)
			tr.Entity:DispatchTraceAttack(dmginfo, hitpos, hitpos + 5*dir)
			
			local phys = tr.Entity:GetPhysicsObject()
			if phys and phys:IsValid() then
				tr.Entity:SetPhysicsAttacker(self.Owner)
			end
		end
		
		if tr.Entity:IsTFPlayer() and not tr.Entity:IsBuilding() then
			if self.ChargeState == 2 and (not self.NextRangeSound or CurTime() > self.NextRangeSound) then
				sound.Play(self.HitPlayerRangeSound, self.Owner:GetPos())
				self.NextRangeSound = CurTime() + 1
			else
				sound.Play(self.HitPlayerSound, self.Owner:GetPos())
			end
		else
			sound.Play(self.HitWorldSound, self.Owner:GetPos())
		end
	elseif tr.HitWorld then
		sound.Play(self.HitWorldSound, self.Owner:GetPos())
	else
		return
	end
	
	util.ScreenShake(self:GetPos(), 10, 5, 1, 512)
	
	if not tr.HitWorld then
		if self.Owner.TempAttributes.ChargeIsUnstoppable then
			return
		end
		
		if tf_targe_enhanced_charge:GetBool() and IsValid(tr.Entity) then
			print("charge hit", tr.Entity, tr.Entity:Health(), tr.Entity:GetMaxHealth(), self:CanChargeThrough(tr.Entity))
			if self:CanChargeThrough(tr.Entity) then
				return
			--[[elseif tr.Entity:GetClass() == "prop_door_rotating" then
				local p = ents.Create("prop_physics")
				p:SetModel(tr.Entity:GetModel())
				p:SetBodygroup(1, 1)
				p:SetSkin(tr.Entity:GetSkin())
				p:SetPos(tr.Entity:GetPos())
				p:SetAngles(tr.Entity:GetAngles())
				tr.Entity:Remove()
				p:Spawn()
				
				p:DispatchTraceAttack(dmginfo, hitpos, hitpos + 5*dir)
				
				local phys = p:GetPhysicsObject()
				if phys and phys:IsValid() then
					p:SetPhysicsAttacker(self.Owner)
				end
				
				return
			elseif tr.Entity:GetClass() == "prop_dynamic" and IsValid(tr.Entity:GetParent())
			and tr.Entity:GetParent():GetClass()=="func_door_rotating" then
				local door = tr.Entity:GetParent()
				
				local p = ents.Create("prop_physics")
				p:SetModel(door:GetModel())
				p:SetSkin(door:GetSkin())
				p:SetPos(door:GetPos())
				p:SetAngles(door:GetAngles())
				door:Remove()
				p:Spawn()
				
				p:DispatchTraceAttack(dmginfo, hitpos, hitpos + 5*dir)
				
				local phys = p:GetPhysicsObject()
				if phys and phys:IsValid() then
					p:SetPhysicsAttacker(self.Owner)
				end
				
				return]]
			end
		end
	end
	
	local vel = self.Owner:GetVelocity()
	local right = self.Owner:EyeAngles():Right()
	local side = vel:DotProduct(right)
	
	self.Owner:SetVelocity(-side * right)
	
	self:StopCharging()
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if IsValid(self.Owner) then
		self.Owner.TargeEntity = self
	end
	self.dt.Charging = false
	self.dt.Ready = true
	self.dt.ChargeCooldownMultiplier = 1
end

function ENT:StartCharging()
	if not self.ChargeDuration then
		self.dt.AdditiveChargeDuration = self.Owner.TempAttributes.AdditiveChargeDuration or 0
		self.dt.ChargeCooldownMultiplier = self.Owner.TempAttributes.ChargeCooldownMultiplier or 1
		self.ChargeDuration = self.DefaultChargeDuration + self.dt.AdditiveChargeDuration
	end
	
	self.dt.Ready = false
	self.dt.Charging = true
	self.dt.NextEndCharge = CurTime() + self.ChargeDuration
	self.SpeedBonus = 2.69
	self.Owner:ResetClassSpeed()
	self.Owner:SetJumpPower(0)
	
	if not self.ChargeSoundEnt then
		self.ChargeSoundEnt = CreateSound(self.Owner, "Heavy.BattleCry05")
	end
	
	if self.ChargeSoundEnt then
		self.ChargeSoundEnt:Play()
	end
end

function ENT:StopCharging()
	self.ChargeDuration = nil
	self.dt.Ready = false
	self.dt.Charging = false
	self.dt.NextEndCharge = CurTime() + self.ChargeCooldownDuration * self.dt.ChargeCooldownMultiplier
	self.SpeedBonus = nil
	self.Owner:ResetClassSpeed()
	
	if self.ChargeSoundEnt then
		self.ChargeSoundEnt:Stop()
		self.ChargeSoundEnt = nil
	end
	
	if self.ChargeState then
		if self.ChargeState == 2 then
			if self.CritStartSoundEnt then
				self.CritStartSoundEnt:Stop()
				self.CritStartSoundEnt = nil
				self.Owner:EmitSound(self.CritStopSound)
			end
		end
		
		self.NextEndCritBoost = CurTime() + 0.4
	end
end

function ENT:OnMeleeSwing()
	if self.dt.Charging then
		self:StopCharging()
	end
end

function ENT:Think()
	if not IsValid(self.Owner) then return end
	
	if self.dt.Charging then
		local vel = self.Owner:GetVelocity():LengthSqr()
		
		if self.Owner:Crouching() then
			self.Owner:ConCommand("-duck")
		end
		
		if not self.MaxSpeed or vel > self.MaxSpeed then
			self.MaxSpeed = vel
		end
		
		local cap = self.MaxSpeed * 0.8 * 0.8
		
		if vel < cap then
			--print("below minimum speed, performing trace check")
			self:MeleeAttack()
			if not self.dt.Charging then
				return
			end
		end
		
		if CurTime() > self.dt.NextEndCharge then
			self:StopCharging()
			return
		end
		
		local p = (self.dt.NextEndCharge - CurTime()) / self.ChargeDuration
		local p0 = p * (self.DefaultChargeDuration / self.ChargeDuration)
		
		if p0 < 0.33 and self.ChargeState == 1 then
			GAMEMODE:StartCritBoost(self.Owner, "melee")
			self.ChargeState = 2
			
			if not self.CritStartSoundEnt then
				self.CritStartSoundEnt = CreateSound(self, self.CritStartSound)
			end
			if self.CritStartSoundEnt then
				self.CritStartSoundEnt:Play()
			end
		elseif p0 < 0.66 and not self.ChargeState then
			GAMEMODE:StartMiniCritBoost(self.Owner, "melee")
			self.ChargeState = 1
		end
	elseif not self.dt.Ready then
		if CurTime() > self.dt.NextEndCharge then
			self.dt.Ready = true
			umsg.Start("PlayChargeReadySound", self.Owner)
			umsg.End()
		end
		
		self.MaxSpeed = nil
		self.ChargeState = nil
	end
	
	if self.NextEndCritBoost and CurTime() > self.NextEndCritBoost then
		GAMEMODE:StopCritBoost(self.Owner)
		self.NextEndCritBoost = nil
	end
	
	if self.Owner:KeyDown(IN_ATTACK2) and self.dt.Ready then
		if self.Owner:OnGround() then
			if self.Owner:Crouching() then
				self.Owner:ConCommand("-duck")
			end
			self:StartCharging()
		end
	end
	
	self:NextThink(CurTime())
	return true
end

end

hook.Add("Move", "TargeChargeMove", function(pl, move)
	local t = pl.TargeEntity
	if IsValid(t) and t.dt and t.dt.Charging then
		move:SetForwardSpeed(pl:GetRealClassSpeed())
		move:SetSideSpeed(0)
	end
end)

hook.Add("SetupMove", "TargeChargeSetupMove", function(pl, move)
	local t = pl.TargeEntity
	if IsValid(t) and t.dt and t.dt.Charging then
		-- This is already done clientside by CreateMove
		if SERVER then
			local ang = pl:EyeAngles()
			if pl.SavedTargeAngle then
				local oldyaw = pl.SavedTargeAngle.y
				
				ang.y = oldyaw + math.Clamp(math.AngleDifference(ang.y, oldyaw), -t.ChargeSteerConstraint, t.ChargeSteerConstraint)
				pl:SetEyeAngles(ang)
			end
			pl.SavedTargeAngle = ang
		end
		
		move:SetSideSpeed(0)
	else
		pl.SavedTargeAngle = nil
	end
end)
