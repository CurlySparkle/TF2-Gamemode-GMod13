
local meta = FindMetaTable( "Entity" )
if not meta then return end 

--[[
RegisterNetworkedTable("TFPlayerData", {
	PlayerState = "Int",
})
]]

if not meta.SetTriggerOLD then
	meta.SetTriggerOLD = meta.SetTrigger
end
function meta:SetTrigger(b)
	self:SetTriggerOLD(b)
	self.__IsTrigger = b
end

-- NPCs are considered as players in this gamemode
function meta:IsTFPlayer()
	return self:IsPlayer() or self:IsNPC()
end

-- Entity name is the name attributed to an entity by the gamemode
function meta:EntityName()
	return GAMEMODE:EntityName(self)
end

-- Entity team is the team attributed to an entity by the gamemode (this is important for placing NPCs into the correct team)
function meta:EntityTeam()
	return GAMEMODE:EntityTeam(self)
end

function meta:SetEntityTeam(t)
	if self.SetTeam then
		self:SetTeam(t)
	else
		self:SetNWInt("Team",t or 0)
	end
	
	if self:IsTFPlayer() then
		GAMEMODE:UpdateEntityRelationship(self)
	end
end

function meta:EntityID()
	return GAMEMODE:EntityID(self)
end

function meta:HasNPCData()
	if NPCData[self:GetClass()] then return true end
	return false
end

function meta:GetNPCData()
	return NPCData[self:GetClass()] or {}
end

function meta:CallNPCEvent(event, ...)
	local d = self:GetNPCData()
	local f = d[event]
	
	if f and type(f)=="function" then
		return f(self, ...)
	end
end

function meta:HasNPCFlag(f)
	local d = self:GetNPCData()
	return d.flags and bit.band(d.flags, f)>0
end

-- Health related overrides
if not meta.GetMaxHealthOLD then
	meta.GetMaxHealthOLD = meta.GetMaxHealth
end
function meta:GetMaxHealth()
	local h,t
	if self:IsPlayer() then
		h = self:GetNWInt("PlayerMaxHealthOverride")
		if h>0 then
			return h
		else
			t = self:GetPlayerClassTable()
			if t and t.Health then
				return t.Health
			else
				return 100
			end
		end
	else
		if CLIENT then
			h = self:GetNWInt("MaxHealth")
			if h > 0 then return h end
		end
		
		t = self:GetNPCData()
		if t.health then
			if type(t.health)=="table" then
				return t.health[string.lower(self:GetModel())] or t.health[0]
			else
				return t.health
			end
		elseif SERVER then
			h = self:GetMaxHealthOLD()
			return (h>0 and h) or 1
		end
		
		return 1
	end
end

if not meta.SetMaxHealthOLD then
	meta.SetMaxHealthOLD = meta.SetMaxHealth
end
function meta:SetMaxHealth(h)
	if self:IsPlayer() then
		self:SetNWInt("PlayerMaxHealthOverride",h)
		if h <= 0 then -- nope
			self:Kill()
		end
	else
		self:SetNWInt("MaxHealth",h)
	end
	self:SetMaxHealthOLD(h)
end

function meta:ResetMaxHealth()
	local h
	self:SetNWInt("PlayerMaxHealthOverride", 0)
	h = self:GetMaxHealth()
	self:SetMaxHealthOLD(h)
	self:SetNWInt("MaxHealth",h)
end

if not meta.HealthOLD then
	meta.HealthOLD = meta.Health
end
function meta:Health()
	if self:IsPlayer() then
		if not IsValid(self) then
			ErrorNoHalt(Format("WARNING: %s:Health: self is not a valid entity!"))
			tf_util.SaveFullDebugInfo()
			return 0
		end
		return self:HealthOLD()
	else
		if SERVER then
			return self:HealthOLD()
		else
			return self:GetNWInt("Health")
		end
	end
end

function meta:ResetHealth()
	self:SetHealth(self:GetMaxHealth())
end

function meta:GetMaxOverheal()
	local h = math.floor(self:GetMaxHealth() * 0.1) * 5
	
	return h
end

function meta:GiveHealth(c, is_fraction, allow_overheal)
	if c==0 then return 0 end
	
	if is_fraction then
		c = math.ceil(c * self:GetMaxHealth())
	end
	
	local h = self:Health() + c
	if c>0 then
		local max = self:GetMaxHealth()
		if allow_overheal then
			max = max + self:GetMaxOverheal()
		end
		
		if h > max then
			c = math.max(0, c - (h - max))
		end
		
		if c > 0 then
			self:SetHealth(self:Health() + c)
		end
		
		return c
	else
		if h < 1 then
			if self:IsPlayer() then
				self:Kill()
			else
				self:SetHealth(1)
				self:TakeDamage(100)
			end
			
			return c
		end
		self:SetHealth(h)
		return c
	end
		
	return 0
end

-- Team related functions
function meta:IsFriendly(target)
	local t1, t2 = self:EntityTeam(), target:EntityTeam()
	
	return (self:HasNPCFlag(NPC_ALWAYSFRIENDLY) or
			target:HasNPCFlag(NPC_ALWAYSFRIENDLY) or
			(t1==TEAM_RED or t1==TEAM_BLU) and t1==t2)
end

function meta:CanDamage(target)
	return self==target or not self:IsFriendly(target)
end

function meta:IsValidEnemy(target)
	return self:IsTFPlayer()
		and (target:Health()>0 or target:GetMaxHealth()==0)
		and not self:IsFriendly(target)
end

-- Death flags

DF_FIRE		= 1		-- death from fire, drop a burning ragdoll
DF_HEADSHOT	= 2		-- death by headshot, play the headshot death pose
DF_BACKSTAB	= 4		-- death by backstab, play the backstab death pose
DF_DECAP	= 8		-- death from decapitation, drop a headless ragdoll and a head gib
DF_GOLDEN	= 16	-- death from the Golden Wrench, drop a golden ragdoll
DF_SILENCED	= 32	-- death from Your Eternal Reward, suppress death sound and cloak ragdoll

function meta:AddDeathFlag(f)
	--[[local dt = self:GetDataTableEntity()
	if IsValid(dt) then
		dt.dt.DeathFlags = dt.dt.DeathFlags | f
	else
		self:SetNWInt("DeathFlags", self:GetNWInt("DeathFlags") | f)
	end]]
	self.DeathFlags = bit.bor((self.DeathFlags or 0), f)
	if SERVER then
		umsg.Start("SetDeathFlags")
			umsg.Entity(self)
			umsg.Short(self.DeathFlags)
		umsg.End()
	end
end

function meta:RemoveDeathFlag(f)
	--[[local dt = self:GetDataTableEntity()
	if IsValid(dt) then
		dt.dt.DeathFlags = dt.dt.DeathFlags & (65535 - f)
	else
		self:SetNWInt("DeathFlags", self:GetNWInt("DeathFlags") & (65535 - f))
	end]]
	self.DeathFlags = bit.band((self.DeathFlags or 0), (65535 - f))
	if SERVER then
		umsg.Start("SetDeathFlags")
			umsg.Entity(self)
			umsg.Short(self.DeathFlags)
		umsg.End()
	end
end

function meta:ResetDeathFlags()
	--[[local dt = self:GetDataTableEntity()
	if IsValid(dt) then
		dt.dt.DeathFlags = 0
	else
		self:SetNWInt("DeathFlags", 0)
	end]]
	self.DeathFlags = 0
	if SERVER then
		umsg.Start("SetDeathFlags")
			umsg.Entity(self)
			umsg.Short(self.DeathFlags)
		umsg.End()
	end
end

function meta:HasDeathFlag(f)
	--[[local dt = self:GetDataTableEntity()
	if IsValid(dt) then
		return (dt.dt.DeathFlags & f) ~= 0
	else
		return (self:GetNWInt("DeathFlags") & f) ~= 0
	end]]
	if not self.DeathFlags then return false end
	
	return bit.band(self.DeathFlags, f) ~= 0
end

if CLIENT then

usermessage.Hook("SetDeathFlags", function(msg)
	local self = msg:ReadEntity()
	local flags = msg:ReadShort()
	
	if IsValid(self) then
		self.DeathFlags = flags
	end
end)

end

-- Explosion related flags

function meta:IsExplosive()
	return self.Explosive
end

function meta:SetThrownByExplosion(b)
	self.ThrownByExplosion = b
end

function meta:IsThrownByExplosion()
	return self.ThrownByExplosion == true
end

-- NPC flags

function meta:IsBuilding()
	return self:HasNPCFlag(NPC_MECH)
end

function meta:CanReceiveCrits()
	if not self:IsTFPlayer() then
		return false
	end
	return not self:HasNPCFlag(NPC_NOCRITS)
end

function meta:ShouldReceiveDefaultMeleeType()
	return self:HasNPCFlag(NPC_NOSPECIALMELEE)
end

function meta:ShouldReceiveDamageForce()
	return not self:HasNPCFlag(NPC_NODMGFORCE)
end

function meta:CanGiveHead()
	if self:IsPlayer() then return true end
	return self:HasNPCFlag(NPC_HASHEAD)
end

local FlammableMaterials = {
	[MAT_ANTLION] = true,
	[MAT_BLOODYFLESH] = true,
	[MAT_DIRT] = true,
	[MAT_FLESH] = true,
	[MAT_ALIENFLESH] = true,
	[MAT_PLASTIC] = true,
	[MAT_FOLIAGE] = true,
	[MAT_WOOD] = true,
}
function meta:IsFlammable()
	if self:IsTFPlayer() then
		return not self:HasNPCFlag(NPC_FIREPROOF)
	else
		return (FlammableMaterials[self:GetMaterialType()]==true)
	end
end

function meta:CanBleed()
	return self:IsTFPlayer() and (self:IsPlayer() or self:HasNPCFlag(NPC_CANBLEED))
end

function meta:GetAlternateHealth()
	return self:GetNPCData().alternatehealth or 0
end

function meta:GetScoreMultiplier()
	return self:GetNPCData().scoremultiplier or 1
end

function meta:IsLoser()
	return not IsValid(self:GetActiveWeapon()) or self:GetNWBool("Loser")==true
end

local TriggerEntities = {
	trigger_autosave = true,
	trigger_changelevel = true,
	trigger_gravity = true,
	trigger_hurt = true,
	trigger_impact = true,
	trigger_look = true,
	trigger_multiple = true,
	trigger_once = true,
	trigger_physics_trap = true,
	trigger_playermovement = true,
	trigger_proximity = true,
	trigger_push = true,
	trigger_remove = true,
	trigger_rpgfire = true,
	trigger_soundscape = true,
	trigger_teleport = true,
	trigger_transition = true,
	trigger_vphysics_motion = true,
	trigger_waterydeath = true,
	trigger_weapon_dissolve = true,
	trigger_weapon_strip = true,
	trigger_wind = true,
}
function meta:IsTrigger()
	if self.__IsTrigger or TriggerEntities[self:GetClass()] or string.find(self:GetClass(), "^trigger_") then
		self.__IsTrigger = true
		return true
	end
	return false
end

--[[
Bullet:

Vector Src
Entity Attacker
Vector Dir
Vector Spread
int Num

int Team
int Damage
float RampUp
float Falloff
bool Critical
float CritMultiplier
float DamageModifier
float DamageRandomize

float Force
int Tracer
string TracerName
function Callback(attacker,traceres,damageinfo)
]]

local ForceDamageClasses = {
	npc_combinegunship = true,
}

local function TFBulletCallback(attacker, trace, dmginfo)
	if CLIENT then return {effects=false} end
	
	local self = dmginfo:GetInflictor()
	local dmg = self.TempDamageInfo
	
	if dmg then
		if trace.Entity and trace.Entity:IsValid() then
			dmg.HitPos = trace.HitPos
			--local damage = tf_util.CalculateDamage(dmg)
			--local dir = (trace.HitPos - dmg.Src):GetNormal()
			
			-- Some NPCs such as the combine gunship completely ignore bullet damage, so let's force the gamemode to process this damage
			if ForceDamageClasses[trace.Entity:GetClass()] then
				trace.Entity:TakeDamageInfo(dmginfo)
				--gamemode.Call("EntityTakeDamage", trace.Entity, self, attacker, 1, dmginfo)
			end
			
			if (trace.Entity:IsPlayer() or trace.Entity:IsNPC()) and dmg.Critical then
				if attacker:EntityTeam()==TEAM_BLU then
					ParticleEffect("bullet_impact1_blue_crit", trace.HitPos, Angle(0,0,0))
				else
					ParticleEffect("bullet_impact1_red_crit", trace.HitPos, Angle(0,0,0))
				end
			end
		end
		
		if dmg.Tracer>0 and math.random(1,dmg.Tracer)==1 then
			local tracer = dmg.TracerName.."_"
			
			if attacker:EntityTeam()==TEAM_BLU then
				tracer = tracer.."blue"
			else
				tracer = tracer.."red"
			end
			
			if dmg.Critical then
				tracer = tracer.."_crit"
			end
			
			umsg.Start("DoBulletTracer")
				umsg.String(tracer)
				umsg.Vector(trace.HitPos)
				umsg.Entity(self)
			umsg.End()
		end
	end
	
	return {effects=false}
end

function meta:FireTFBullets(b)
	self.TempDamageInfo = {
		BaseDamage = b.Damage,
		MaxDamageFalloff = b.Falloff,
		MaxDamageRampUp = b.RampUp,
		DamageModifier = b.DamageModifier,
		DamageRandomize = b.DamageRandomize,
		Src = b.Src,
		Critical = b.Critical,
		CritDamageMultiplier = b.CritMultiplier,
		Tracer = b.Tracer or 1,
		TracerName = b.TracerName or "bullet_tracer01",
		Force = b.Force or 1,
	}
	
	b.Damage = 1
	b.Tracer = 0
	b.TracerName = ""
	b.Callback = TFBulletCallback
	
	
	self:FireBullets(b)
end

if CLIENT then

local function DoBulletTracer(tracer, hitpos, weapon)
	if not IsValid(weapon) then return end
	
	local ent
	
	if weapon:IsWeapon() and weapon.Owner==LocalPlayer() and IsValid(LocalPlayer():GetViewModel()) and weapon.DrawingViewModel then
		if weapon.CModel then
			ent = weapon.CModel
		else
			ent = LocalPlayer():GetViewModel()
		end
	else
		ent = weapon
	end
	
	if not IsValid(ent) then
		return
	end
	
	local attachment = ent.MuzzleAttachmentOverride or "muzzle"
	
	local id = ent:LookupAttachment(attachment)
	local att = ent:GetAttachment(id)
	if not att then return end
	
	--print("DoBulletTracer", tracer, ent, ent:EntIndex(), id)
	util.ParticleTracerEx(tracer, att.Pos, hitpos, true, ent:EntIndex(), id)
end

usermessage.Hook("DoBulletTracer", function(msg)
	local tracer = msg:ReadString()
	local hitpos = msg:ReadVector()
	local weapon = msg:ReadEntity()
	
	timer.Simple(RealFrameTime(), function() DoBulletTracer(tracer, hitpos, weapon) end)
end)

end

local BloodEffectTable = {
	[BLOOD_COLOR_RED] = "blood_impact_red_01",
	[BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01",
	[BLOOD_COLOR_GREEN] = "blood_impact_green_01",
	[BLOOD_COLOR_MECH] = "blood_impact_synth_01",
	[BLOOD_COLOR_ANTLION] = "blood_impact_antlion_01",
	[BLOOD_COLOR_ZOMBIE] = "blood_impact_zombie_01",
	[BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_antlionworker_01",
}

function meta:DispatchBloodEffect(pos, ang)
	if not pos then
		pos = self:BodyTarget(self:GetPos())
	end
	
	if not ang then
		ang = self:GetAngles()
	end
	
	if BloodEffectTable[self:GetBloodColor()] then
		ParticleEffect(BloodEffectTable[self:GetBloodColor()], pos, ang, self)
	end
end

if CLIENT then

local function DoBuildBonePositions(self, numbones, numphys)
	if not self._BuildBoneHookTable then
		return
	end
	
	local b, err
	for name, func in pairs(self._BuildBoneHookTable) do
		b, err = pcall(func, self, numbones, numphys)
		if not b then
			ErrorNoHalt(Format("BuildBone Hook '%s' failed: %s\n", name, err or ""))
			self._BuildBoneHookTable[name] = nil
		end
	end
end

function meta:AddBuildBoneHook(name, func)
	if not self._BuildBoneHookTable then
		self._BuildBoneHookTable = {}
		--if self.BuildBonePositions then
			--ErrorNoHalt(Format("WARNING: AddBuildBoneHook will override current BuildBonePositions function on entity %s!", tostring(self)))
		--end
		self.BuildBonePositions = DoBuildBonePositions
	end
	
	self._BuildBoneHookTable[name] = func
end

function meta:RemoveBuildBoneHook(name)
	if not self._BuildBoneHookTable then
		return
	end
	
	self._BuildBoneHookTable[name] = nil
end

function meta:GetBuildBoneHookTable()
	return self._BuildBoneHookTable or {}
end

end
