
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.Explosive = true

if CLIENT then

function ENT:Draw()
	self:DrawModel()
end

end

if SERVER then

AddCSLuaFile( "shared.lua" )

ENT.Model = "models/weapons/w_models/w_capsule_capsulelauncher.mdl"
ENT.Model2 = "models/weapons/w_models/w_stickybomb2.mdl"

ENT.ExplosionSound = Sound("Weapon_Grenade_Pipebomb.Explode")
ENT.BounceSound = Sound("Weapon_Grenade_Pipebomb.Bounce")

ENT.BaseDamage = 90
ENT.DamageRandomize = 0.3
ENT.MaxDamageRampUp = 0
ENT.MaxDamageFalloff = 0
ENT.DamageModifier = 1

--ENT.BaseSpeed = 1100
ENT.ExplosionRadiusInit = 180

ENT.CritDamageMultiplier = 3

ENT.Mass = 10

local BlastForceMultiplier = 16
local BlastForceToVelocityMultiplier = (0.015 / BlastForceMultiplier)

function ENT:Critical()
	return self.critical
end

function ENT:CalculateDamage(ownerpos)
	return tf_util.CalculateDamage(self, self:GetPos(), ownerpos)
end

function ENT:GetRocketJumpForce(owner, dmginfo)
	local ang = dmginfo:GetDamageForce():Angle()
	local force = dmginfo:GetDamageForce():Length() * BlastForceToVelocityMultiplier
	ang.p = math.Clamp(ang.p, -70, -89)
	
	return ang:Forward() * force
end

function ENT:Reflect(pl, weapon, dir)
	
end

function ENT:Initialize()
	if self.GrenadeMode==-1 then
		self:SetModel(self.Model)
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetNotSolid(true)
		self:DoExplosion()
		return
	elseif self.GrenadeMode==1 then
		self.BouncesLeft = 2
		self:SetModel(self.Model2)
		self:PhysicsInitSphere(8, "metal_bouncy")
	else
		self.BouncesLeft = 1
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_CUSTOM)
	self:SetHealth(1)
	
	if self.GrenadeMode==1 then
		self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	else
		self:SetMoveCollide(MOVECOLLIDE_FLY_SLIDE)
	end
	
	if GAMEMODE:EntityTeam(self:GetOwner()) == TEAM_BLU then
		if self.GrenadeMode==1 then
			self:SetMaterial("models/weapons/w_stickybomb/w_stickybomb2_blue")
		else
			self:SetSkin(1)
		end
	end
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		if self.GrenadeMode==1 then
			self.Bounciness = 1
			phys:SetMass(self.Mass * 2)
		else
			phys:SetMass(self.Mass)
		end
		--phys:EnableDrag(false)
	end
	
	self.ai_sound = ents.Create("ai_sound")
	self.ai_sound:SetPos(self:GetPos())
	self.ai_sound:SetKeyValue("volume", "80")
	self.ai_sound:SetKeyValue("duration", "8")
	self.ai_sound:SetKeyValue("soundtype", "8")
	self.ai_sound:SetParent(self)
	self.ai_sound:Spawn()
	self.ai_sound:Activate()
	self.ai_sound:Fire("EmitAISound", "", 0.3)
	
	self.NextExplode = CurTime() + 2.3
	
	local effect = ParticleSuffix(GAMEMODE:EntityTeam(self:GetOwner()))
	
	self.particle_timer = ents.Create("info_particle_system")
	self.particle_timer:SetPos(self:GetPos())
	self.particle_timer:SetParent(self)
	self.particle_timer:SetKeyValue("effect_name","pipebomb_timer_" .. effect)
	self.particle_timer:SetKeyValue("start_active", "1")
	self.particle_timer:Spawn()
	self.particle_timer:Activate()
	
	self.particle_trail = ents.Create("info_particle_system")
	self.particle_trail:SetPos(self:GetPos())
	self.particle_trail:SetParent(self)
	self.particle_trail:SetKeyValue("effect_name","pipebombtrail_" .. effect)
	self.particle_trail:SetKeyValue("start_active", "1")
	self.particle_trail:Spawn()
	self.particle_trail:Activate()
	
	if self.critical then
		self.particle_crit = ents.Create("info_particle_system")
		self.particle_crit:SetPos(self:GetPos())
		self.particle_crit:SetParent(self)
		self.particle_crit:SetKeyValue("effect_name","critical_pipe_" .. effect)
		self.particle_crit:SetKeyValue("start_active", "1")
		self.particle_crit:Spawn()
		self.particle_crit:Activate()
	end
end

function ENT:OnRemove()
	if self.ai_sound then self.ai_sound:Remove() end
	if self.particle_timer and self.particle_timer:IsValid() then self.particle_timer:Remove() end
	if self.particle_trail and self.particle_trail:IsValid() then self.particle_trail:Remove() end
	if self.particle_crit and self.particle_crit:IsValid() then self.particle_crit:Remove() end
end

function ENT:Think()
	if self.NextExplode and CurTime()>=self.NextExplode then
		self:DoExplosion()
		self.NextExplode = nil
	end
end

function ENT:DoExplosion()
	self.PhysicsCollide = nil
	
	self:EmitSound(self.ExplosionSound, 100, 100)
	
	local flags = 0
	
	if self:WaterLevel()>0 then
		flags = bit.bor(flags, 1)
	end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetAngles(self:GetAngles())
		effectdata:SetAttachment(flags)
	util.Effect("tf_explosion", effectdata, true, true)
	
	local owner = self:GetOwner()
	if not owner or not owner:IsValid() then owner = self end
	
	local range, damage
	
	if self.GrenadeMode==-1 then
		range = self.ExplosionRadiusInit
	elseif self.BouncesLeft<=0 then
		range = self.ExplosionRadiusInit
		self.BaseDamage = 41
		self.OwnerDamage = 1
	else
		range = self.ExplosionRadiusInit * 0.5
		self.BaseDamage = 98
		self.OwnerDamage = 0.6
	end
	
	--self.ResultDamage = self.BaseDamage
	
	--util.BlastDamage(self, owner, self:GetPos(), range, self.BaseDamage)
	util.BlastDamage(self, owner, self:GetPos(), range, 100)
	
	self:SetNoDraw(true)
	self:SetNotSolid(true)
	self:Fire("kill", "", 0.01)
end

function ENT:Break()
	if self.Dead then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("tf_stickybomb_destroyed", effectdata)
	
	self.Dead = true
	self:SetNotSolid(true)
	self:SetNoDraw(true)
	self:Fire("kill", "", 0.01)
end

function ENT:PhysicsCollide(data, physobj)
	if data.HitEntity and data.HitEntity:IsValid() and (data.HitEntity:IsNPC() or data.HitEntity:IsPlayer()) and data.HitEntity:Health()>0 then
		if self.BouncesLeft>0 then
			return nil
		end
	else
		if self.DetonateMode == 2 then
			self:Break()
			return
		end
		
		if data.Speed > 50 and data.DeltaTime > 0.2 then
			self:EmitSound(self.BounceSound, 100, 100)
		end
		
		self.BouncesLeft = self.BouncesLeft - 1
		
		if self.Bounciness then
			local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
			local NewVelocity = physobj:GetVelocity()
			NewVelocity:Normalize()
			
			LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
			
			local TargetVelocity = NewVelocity * LastSpeed * self.Bounciness
			
			physobj:SetVelocity( TargetVelocity )
		end
	end
end

end
