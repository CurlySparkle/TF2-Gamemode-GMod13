local function MedigunEffectName(i, t)
	if i==1 then
		if t==2 then
			return "medicgun_beam_blue"
		else
			return "medicgun_beam_red"
		end
	elseif i>1 then
		if t==2 then
			return "medicgun_beam_blue_invun"
		else
			return "medicgun_beam_red_invun"
		end
	end
end

function SWEP:SetupDataTables()
	self:CallBaseFunction("SetupDataTables")
	
	self:DTVar("Entity", 0, "BeamEntity")
	self:DTVar("Entity", 1, "TargetEntity")
end

if SERVER then
AddCSLuaFile( "shared.lua" )
	
function SWEP:SetMedigunEffect(i, target)
	if self.LastEffect==i then return end
	
	if IsValid(self.dt.BeamEntity) then
		self.dt.BeamEntity:Remove()
		self.dt.BeamEntity = NULL
	end
	if IsValid(self.InfoTarget) then
		self.InfoTarget:Remove()
		self.InfoTarget = NULL
	end
	
	if i>0 and IsValid(target) then
		local t = GAMEMODE:EntityTeam(self.Owner)
		local effect = MedigunEffectName(i, t)
		
		local tar = ents.Create("info_dummy")
		tar:SetPos(target:GetPos() + Vector(0,0,30))
		tar:Spawn()
		tar:SetParent(target)
		tar:SetName(tostring(tar))
		
		self.InfoTarget = tar
		
		local beam = ents.Create("info_particle_system")
		beam:SetPos(self:GetPos())
		beam:SetParent(self)
		beam:SetKeyValue("effect_name",effect)
		beam:SetKeyValue("cpoint1", tar:GetName())
		beam:SetKeyValue("start_active", "1")
		beam:Spawn()
		beam:Activate()
		
		self.dt.TargetEntity = target
		self.dt.BeamEntity = beam
	else
		self.dt.TargetEntity = NULL
	end
	
	self.LastEffect = i
end

function SWEP:SetMedigunMuzzleEffect(i)
	if self.LastEffect2==i then return end
	
	umsg.Start("SetMedigunMuzzleEffect")
		umsg.Entity(self)
		umsg.Char(i)
	umsg.End()
	
	self.LastEffect2 = i
end

end

if CLIENT then

SWEP.PrintName			= "Medigun"
SWEP.Slot				= 1
SWEP.CustomHUD = {HudMedicCharge = true}

--[[
function SWEP:SetMedigunEffect(p, t)
	if IsValid(p) and IsValid(t) then
		self.MedigunBeam = p
		if self.Owner==LocalPlayer() then
			HudHealingTargetID:SetTargetEntity(t)
			HudHealingTargetID:SetVisible(true)
		end
	else
		self.MedigunBeam = nil
		if self.Owner==LocalPlayer() then
			HudHealingTargetID:SetVisible(false)
		end
	end
end
]]

function SWEP:SetMedigunMuzzleEffect(i)
	if not (IsValid(self.Owner) and IsValid(self.Owner:GetViewModel())) then
		return
	end
	
	if self.LastEffect2==i then return end
	
	local effect
	local t = GAMEMODE:EntityTeam(self.Owner)
	
	if i==1 then
		if t==2 then
			effect = "medicgun_invulnstatus_fullcharge_blue"
		else
			effect = "medicgun_invulnstatus_fullcharge_red"
		end
	end
	
	self.Owner:GetViewModel():StopParticles()
	self:StopParticles()
	
	if self.Owner==LocalPlayer() and IsValid(self.Owner:GetViewModel()) and self.DrawingViewModel then
		local vm = self.Owner:GetViewModel()
		if IsValid(self.CModel) then
			vm = self.CModel
		end
		
		if effect then
			ParticleEffectAttach(effect, PATTACH_POINT_FOLLOW, vm, vm:LookupAttachment("muzzle"))
		end
	else
		if effect then
			ParticleEffectAttach(effect, PATTACH_POINT_FOLLOW, self, self:LookupAttachment("muzzle"))
		end
	end
	
	self.LastEffect2 = i
end

usermessage.Hook("SetMedigunMuzzleEffect", function(msg)
	local w = msg:ReadEntity()
	local i = msg:ReadChar()
	
	if IsValid(w) and w.SetMedigunMuzzleEffect then
		w:SetMedigunMuzzleEffect(i)
	end
end)

function SWEP:ModelDrawn(view)
	if IsValid(self.dt.BeamEntity) then
		local wep, att
		if view then
			wep = (IsValid(self.CModel) and self.CModel) or self.Owner:GetViewModel()
		else
			wep = self
		end
		att = wep:LookupAttachment("muzzle")
		att = wep:GetAttachment(att)
		if not att then return end
		
		self.dt.BeamEntity:SetPos(att.Pos)
		self.dt.BeamEntity:SetAngles(att.Ang)
	end
end

end

PrecacheParticleSystem("medicgun_beam_red")
PrecacheParticleSystem("medicgun_beam_red_invun")
PrecacheParticleSystem("medicgun_beam_blue")
PrecacheParticleSystem("medicgun_beam_blue_invun")
PrecacheParticleSystem("medicgun_invulnstatus_fullcharge_red")
PrecacheParticleSystem("medicgun_invulnstatus_fullcharge_blue")

SWEP.Base				= "tf_weapon_gun_base"

SWEP.ViewModel			= "models/weapons/v_models/v_medigun_medic.mdl"
SWEP.WorldModel			= "models/weapons/w_models/w_medigun.mdl"
SWEP.Crosshair = "tf_crosshair5"

SWEP.MuzzleEffect = "pyro_blast"

SWEP.ShootSound = Sound("WeaponMedigun.Healing")
SWEP.ShootSound2 = Sound("WeaponMedigun.NoTarget")
SWEP.ChargedSound = Sound("WeaponMedigun.Charged")

SWEP.Primary.Automatic = true
SWEP.Primary.Ammo			= "none"

SWEP.IsRapidFire = true
SWEP.ReloadSingle = false

SWEP.HoldType = "SECONDARY"

SWEP.ProjectileShootOffset = Vector(3, 8, -5)
SWEP.Range = 500

SWEP.MinHealRate = 24
SWEP.MaxHealRate = 72
SWEP.MinLastDamageTime = 10
SWEP.MaxLastDamageTime = 15

SWEP.UberchargeRate = 2.5

function SWEP:CreateSounds()
	self.ShootSoundLoop = CreateSound(self, self.ShootSound)
	self.ChargedLoop = CreateSound(self, self.ChargedSound)
	self.SoundsCreated = true
end

function SWEP:SetHealTarget(e)
	self.Target = e
	if SERVER then
		self:SetMedigunEffect(1, e)
		if IsValid(e) then
			GAMEMODE:AddGlobalAssistant(e, self.Owner, 1, ASSIST_HEAL)
		end
	end
end

function SWEP:ClearHealTarget()
	local e = self.Target
	self.Target = nil
	if SERVER then
		self:SetMedigunEffect(0)
		if IsValid(e) then
			GAMEMODE:RemoveGlobalAssistant(e, self.Owner, ASSIST_HEAL)
		end
	end
end

local function medigun_trace_condition(tr, wep)
	return
		IsValid(tr.Entity) and
		tr.Entity:IsTFPlayer() and
		tr.Entity:EntityTeam()==wep.Owner:EntityTeam() and
		tr.Entity:Health()>0 and
		not tr.Entity:HasNPCFlag(NPC_CANNOTHEAL)
end

function SWEP:PrimaryAttack()
	if not self.Firing then
		local start = self.Owner:GetShootPos()
		local endpos = start + self.Owner:GetAimVector() * self.Range
		local tr = tf_util.MixedTrace({
			start = start,
			endpos = endpos,
			filter = self.Owner,
			mins = Vector(-5, -5, -5),
			maxs = Vector(5, 5, 5),
		}, medigun_trace_condition, self)
		
		if medigun_trace_condition(tr, self) then
			self.Firing = true
			self:SetHealTarget(tr.Entity)
			
			self:SendWeaponAnim(ACT_MP_ATTACK_STAND_PREFIRE)
			self.Owner:SetAnimation(PLAYER_PREFIRE)
			self.ShootSoundLoop:Play()
			self.NextIdle = nil
			self.NextIdle2 = CurTime() + self:SequenceDuration()
		elseif not self.NextDeniedSound or CurTime()>self.NextDeniedSound then
			self:EmitSound(self.ShootSound2)
			self.NextDeniedSound = CurTime() + 0.5
		end
	end
end

function SWEP:Reload()
end

function SWEP:StopFiring()
	if IsValid(self.Target) and self.Target:IsPlayer() and self.Target:Alive() then
		self.Target:Speak("TLK_HEALTARGET_STOPPEDHEALING")
	end
	
	self.Firing = false
	self:ClearHealTarget()
	
	self.ShootSoundLoop:Stop()
	self:SendWeaponAnim(ACT_MP_ATTACK_STAND_POSTFIRE)
	self.Owner:SetAnimation(PLAYER_POSTFIRE)
	self.NextIdle = CurTime() + self:SequenceDuration()
end

function SWEP:Think()
	if CLIENT then
		if self.Owner==LocalPlayer() then
			if self.dt.TargetEntity ~= self.LastTargetEntity then
				if IsValid(self.dt.BeamEntity) and IsValid(self.dt.TargetEntity) then
					HudHealingTargetID:SetTargetEntity(self.dt.TargetEntity)
					HudHealingTargetID:SetVisible(true)
				else
					HudHealingTargetID:SetVisible(false)
				end
				self.LastTargetEntity = self.dt.TargetEntity
			end
		end
	end
	
	if not self.SoundsCreated then
		self:CreateSounds()
	end
	
	if self.NextIdle and CurTime()>=self.NextIdle then
		self:SendWeaponAnim(self.VM_IDLE)
		self.NextIdle = nil
		self.NextIdle2 = nil
	end
	
	if self.NextIdle2 and CurTime()>=self.NextIdle2 then
		self:SendWeaponAnim(self.VM_PRIMARYATTACK)
		self.NextIdle = nil
		self.NextIdle2 = nil
	end
	
	if self.Firing and SERVER then
		if not self.Owner:KeyDown(IN_ATTACK) or not IsValid(self.Target) or self.Target:Health()<=0 then
			self:StopFiring()
			return
		elseif not self.NextRangeCheck or CurTime()>self.NextRangeCheck then
			self.NextRangeCheck = CurTime() + 0.2
			if self.Owner:GetShootPos():Distance(self.Target:GetPos())>self.Range then
				self:StopFiring()
				return
			end
		end
		
		if IsValid(self.Target) then
			local maxhealth = self.Target:GetMaxHealth()
			local maxoverheal = self.Target:GetMaxOverheal()
			
			if self.OverhealMultiplier then
				maxoverheal = math.Round(maxoverheal * self.OverhealMultiplier)
			end
			
			if not self.NextHeal or CurTime()>self.NextHeal then
				if self.NextHeal then
					local err = (CurTime() - self.NextHeal) / self.LastHealRate
					self.HealErrorCumul = (self.HealErrorCumul or 0) + err
					
					local add = math.floor(self.HealErrorCumul)
					self.HealErrorCumul = self.HealErrorCumul - add
					
					--[[if self.Target:Health()<maxhealth + maxoverheal then
						self.Target:SetHealth(self.Target:Health() + 1 + add)
						self.Healing = (self.Healing or 0) + 1 + add
					end]]
					GAMEMODE:HealPlayer(self.Owner, self.Target, 1 + add, false, true)
				end
				
				local rate
				if self.Target.LastDamaged then
					rate = math.TimeFraction(self.MinLastDamageTime, self.MaxLastDamageTime, CurTime()-self.Target.LastDamaged)
					rate = Lerp(math.Clamp(rate,0,1), self.MinHealRate, self.MaxHealRate)
				else
					rate = self.MaxHealRate
				end
				
				if self.HealRateMultiplier then
					rate = rate * self.HealRateMultiplier
				end
				
				if self.Target.TempAttributes and self.Target.TempAttributes.HealthFromHealersMultiplier then
					rate = rate * self.Target.TempAttributes.HealthFromHealersMultiplier
				end
				
				self.LastHealRate = rate
				self.NextHeal = CurTime() + 1 / rate
			end
			
			if not self.NextCharge or CurTime()>self.NextCharge then
				if self.NextCharge then
					local err = (CurTime() - self.NextCharge) / self.LastChargeRate
					self.ChargeErrorCumul = (self.ChargeErrorCumul or 0) + err
					
					local add = math.floor(self.ChargeErrorCumul)
					self.ChargeErrorCumul = self.ChargeErrorCumul - add
					
					local ch = self.Owner:GetNWInt("Ubercharge")
					if ch<100 then
						ch = math.Clamp(ch + 1 + add, 0, 100)
						self.Owner:SetNWInt("Ubercharge", ch)
						if ch>=100 then
							self.Owner:Speak("TLK_PLAYER_CHARGEREADY")
							self.ChargedLoop:Play()
							self:SetMedigunMuzzleEffect(1)
						end
					end
				end
				
				local rate = self.UberchargeRate
				if self.Target:Health()>maxhealth then
					rate = rate * 0.5
				end
				
				if self.UberchargeRateMultiplier then
					rate = rate * self.UberchargeRateMultiplier
				end
				
				self.LastChargeRate = rate
				self.NextCharge = CurTime() + 1 / rate
			end
		end
	end
end

function SWEP:Deploy()
	if not self.SoundsCreated then
		self:CreateSounds()
	end
	
	if self.Owner:GetNWInt("Ubercharge")>=100 then
		self.ChargedLoop:Play()
		if SERVER then
			self:SetMedigunMuzzleEffect(1)
		end
	end
	
	return self:CallBaseFunction("Deploy")
end

function SWEP:Holster()
	if self.ShootSoundLoop and self.ChargedLoop then
		self.ShootSoundLoop:Stop()
		self.ChargedLoop:Stop()
	end
	
	self.Firing = false
	
	if SERVER then
		self:ClearHealTarget()
		self:SetMedigunMuzzleEffect(0)
	else
		if self.Owner == LocalPlayer() then
			HudHealingTargetID:SetVisible(false)
			self.LastTargetEntity = nil
		end
	end
	
	return self:CallBaseFunction("Holster")
end

function SWEP:OnRemove()
	self:Holster()
end
