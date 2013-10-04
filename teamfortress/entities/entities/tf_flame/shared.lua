-- Flare

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.IsTFWeapon = true

ENT.Size = 5

function ENT:InitEffects()
end

if CLIENT then

function ENT:Initialize()
	self:InitEffects()
end

local function DrawBox(pos, mins, maxs, F, R, U)
	local bld = (pos + mins.x*F + mins.y*R + mins.z*U):ToScreen()
	local brd = (pos + mins.x*F + maxs.y*R + mins.z*U):ToScreen()
	local frd = (pos + maxs.x*F + maxs.y*R + mins.z*U):ToScreen()
	local fld = (pos + maxs.x*F + mins.y*R + mins.z*U):ToScreen()
	local blu = (pos + mins.x*F + mins.y*R + maxs.z*U):ToScreen()
	local bru = (pos + mins.x*F + maxs.y*R + maxs.z*U):ToScreen()
	local fru = (pos + maxs.x*F + maxs.y*R + maxs.z*U):ToScreen()
	local flu = (pos + maxs.x*F + mins.y*R + maxs.z*U):ToScreen()
	
	surface.DrawLine(bld.x, bld.y, brd.x, brd.y)
	surface.DrawLine(brd.x, brd.y, frd.x, frd.y)
	surface.DrawLine(frd.x, frd.y, fld.x, fld.y)
	surface.DrawLine(fld.x, fld.y, bld.x, bld.y)
	
	surface.DrawLine(blu.x, blu.y, bru.x, bru.y)
	surface.DrawLine(bru.x, bru.y, fru.x, fru.y)
	surface.DrawLine(fru.x, fru.y, flu.x, flu.y)
	surface.DrawLine(flu.x, flu.y, blu.x, blu.y)
	
	surface.DrawLine(blu.x, blu.y, bld.x, bld.y)
	surface.DrawLine(bru.x, bru.y, brd.x, brd.y)
	surface.DrawLine(flu.x, flu.y, fld.x, fld.y)
	surface.DrawLine(fru.x, fru.y, frd.x, frd.y)
end

function ENT:Draw()
	render.SetViewPort(0, 0, ScrW(), ScrH())
	cam.Start2D()
		cam.IgnoreZ(true)
		surface.SetDrawColor(50, 60, 255, 255)
		DrawBox(self:GetPos(), Vector(-self.Size,-self.Size,-self.Size), Vector(self.Size,self.Size,self.Size), Vector(1,0,0), Vector(0,1,0), Vector(0,0,1))
		cam.IgnoreZ(false)
	cam.End2D()
end

end

if SERVER then

AddCSLuaFile( "shared.lua" )

ENT.HitSound = Sound("Weapon_FlameThrower.FireHit")

ENT.MaxDamage = 7
ENT.MinDamage = 2
ENT.DamageRandomize = 0.1
ENT.CritDamageMultiplier = 3

ENT.Force = 1200
ENT.DragCoefficient = 3
ENT.Buoyancy = 50
ENT.ThinkTime = 0.2

ENT.BaseLifeTime = 1

ENT.BackCritAngle = 120

tf_debug_flamethrower = CreateConVar("tf_debug_flamethrower", 0, {FCVAR_CHEAT})

function ENT:Critical(ent)
	if self.critical then
		return true
	end
	
	if self.CritsFromBehind then
		local back_cos = math.cos(math.rad(self.BackCritAngle * 0.5))
		local v1 = ent:GetPos() - self:GetPos()
		local v2 = ent:GetAngles():Forward()
		
		v1.z = 0
		v2.z = 0
		v1:Normalize()
		v2:Normalize()
		
		return v1:Dot(v2) > back_cos
	end
	
	return false
end

function ENT:CalculateDamage(ownerpos)
	local dmg = Lerp((self.NextDie - CurTime()) / self.LifeTime, self.MinDamage, self.MaxDamage)
	return dmg * (1+math.Rand(-self.DamageRandomize, self.DamageRandomize))
end

function ENT:Initialize()
	local min = Vector(-self.Size, -self.Size, -self.Size)
	local max = Vector( self.Size,  self.Size,  self.Size)
	
	if tf_debug_flamethrower:GetBool() then
		self:DrawShadow(false)
	else
		self:SetNoDraw(true)
	end
	
	self:SetNotSolid(true)
	
	self:SetMoveType(MOVETYPE_FLY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_CUSTOM)
	self:SetCollisionBounds(min, max)
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)
	
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	
	self:SetLocalVelocity(self:GetForward() * self.Force)
	
	self.LifeTime = self.BaseLifeTime
	self.NextDie = CurTime() + self.LifeTime
end

function ENT:Think()
	if CurTime()>=self.NextDie then
		self:Remove()
		return false
	end
	
	local vel = self:GetVelocity()
	-- More like AddVelocity, this adds a vector, it doesn't actually set it
	self:SetVelocity(-self.DragCoefficient * self.ThinkTime * vel + Vector(0,0,self.Buoyancy * self.ThinkTime))
	
	self:NextThink(CurTime() + 0.2)
	return true
end

function ENT:Hit(ent)
	self.Touch = nil
	
	if self:IsWorld() then return end
	
	local owner = self:GetOwner()
	if not owner or not owner:IsValid() then owner = self end
	
	if ent:IsTFPlayer() or (ent:GetClass()=="prop_physics") then
		if not ent.FlameBurnSound then
			ent.FlameBurnSound = CreateSound(ent, self.HitSound)
		end
		
		if not ent.NextStopBurnSound or CurTime()>ent.NextStopBurnSound then
			ent.FlameBurnSound:Play()
		end
		ent.NextStopBurnSound = CurTime() + 0.2
	end
	
	local damage = self:CalculateDamage()
	
	local dmginfo = DamageInfo()
		dmginfo:SetAttacker(owner)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(damage)
		if ent:IsTFPlayer() then
			dmginfo:SetDamageType(DMG_GENERIC)
		else
			dmginfo:SetDamageType(DMG_BURN)
		end
		dmginfo:SetDamagePosition(self:GetPos())
		dmginfo:SetDamageForce(self:GetVelocity())
	ent:TakeDamageInfo(dmginfo)
	
	if ent:IsFlammable() then
		GAMEMODE:IgniteEntity(ent, self, owner, 10)
	end
	
	self:Fire("kill", "", 0.01)
end

function ENT:Touch(ent)
	if not ent:IsTrigger() and ent~=self:GetOwner() and gamemode.Call("ShouldCollide",self,ent) then
		self:Hit(ent)
	end
end

hook.Add("Think", "FlameBurnSoundThink", function()
	for _,v in pairs(ents.GetAll()) do
		if v.FlameBurnSound and (not v.NextStopBurnSound or CurTime()>v.NextStopBurnSound) then
			v.NextStopBurnSound = nil
			v.FlameBurnSound:Stop()
		end
	end
end)

hook.Add("EntityRemoved", "FlameBurnSoundRemove", function(ent)
	if ent.FlameBurnSound then
		ent.FlameBurnSound:Stop()
		ent.FlameBurnSound = nil
	end
end)

end
