
local function minicrit_true() return true end

local AirblastFunc = {
	["grenade_spit"] = function(self, ent, dir)
		ent:SetLocalVelocity(dir * ent:GetVelocity():Length())
		ent:SetOwner(self.Owner)
		ent.AttackerOverride = self.Owner
		ent.NameOverride = "grenade_spit_deflect"
		ent.MiniCrit = minicrit_true
		return true
	end,
	["grenade_ar2"] = function(self, ent, dir)
		ent:SetLocalVelocity(dir * ent:GetVelocity():Length())
		ent:SetOwner(self.Owner)
		ent.AttackerOverride = self.Owner
		ent.NameOverride = "grenade_ar2_deflect"
		ent.MiniCrit = minicrit_true
		return true
	end,
	["crossbow_bolt"] = function(self, ent, dir)
		ent:SetLocalVelocity(dir * ent:GetVelocity():Length())
		ent:SetOwner(self.Owner)
		ent.AttackerOverride = self.Owner
		ent.NameOverride = "crossbow_bolt_deflect"
		ent.MiniCrit = minicrit_true
		return true
	end, 
	["npc_grenade_frag"] = function(self, ent, dir)
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return false end
		
		local vel = phys:GetVelocity()
		phys:AddVelocity(dir * math.Clamp(vel:Length(),1000,100000) - vel)
		
		ent:SetOwner(self.Owner)
		ent:SetPhysicsAttacker(self.Owner)
		ent.AttackerOverride = self.Owner
		ent.NameOverride = "npc_grenade_frag_deflect"
		ent.MiniCrit = minicrit_true
		return true
	end,
	["prop_combine_ball"] = function(self, ent, dir)
		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return false end
		
		local vel = phys:GetVelocity()
		phys:AddVelocity(dir * math.Clamp(vel:Length(),1000,100000) - vel)
		
		ent:SetOwner(self.Owner)
		ent:SetPhysicsAttacker(self.Owner)
		ent.AttackerOverride = self.Owner
		ent.NameOverride = "prop_combine_ball_deflect"
		
		if phys:HasGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG) then
			-- The combine ball was fired by a NPC, and simply dissolves stuff without damaging them
			-- Convert it into a player combine ball when it is airblasted
			phys:ClearGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			phys:AddGameFlag(FVPHYSICS_DMG_DISSOLVE)
			phys:AddGameFlag(FVPHYSICS_HEAVY_OBJECT)
		end
		return true
	end,
	["rpg_missile"] = function(self, ent, dir)
		ent:SetLocalVelocity(dir * 2000)
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(1000)
		dmginfo:SetDamageType(DMG_AIRBOAT)
		ent:TakeDamageInfo(dmginfo)
		ent:SetOwner(self.Owner)
		ent.AttackerOverride = self.Owner
		ent.NameOverride = "rpg_missile_deflect"
		ent.MiniCrit = minicrit_true
		return true
	end,
}

function SWEP:DoAirblast()
	local r = self.AirblastRadius
	local dir = self.Owner:GetAimVector()
	local dir2 = dir:Angle()
	dir2.p = math.Clamp(dir2.p - 45,-90,90)
	dir2 = dir2:Forward()
	
	local pos = self.Owner:GetShootPos() + r * 1.5 * dir
	local reflect
	
	for _,v in pairs(ents.FindInBox(pos-Vector(r,r,r),pos+Vector(r,r,r))) do
		c = v:GetClass()
		--print(v)
		if v:GetOwner()~=self.Owner then
			if v:IsTFPlayer() and self.Owner:IsValidEnemy(v) and v:ShouldReceiveDamageForce() then
				if v:GetMoveType()==MOVETYPE_VPHYSICS then
					for i=0,v:GetPhysicsObjectCount()-1 do
						v:GetPhysicsObjectNum(i):ApplyForceCenter(18000*dir)
					end
				else
					v:SetGroundEntity(NULL)
					v:SetLocalVelocity(dir2 * 400)
					v:SetThrownByExplosion(true)
					
					if v:IsPlayer() then
						umsg.Start("TFAirblastImpact", v)
						umsg.End()
					end
				end
			elseif v.Reflect then
				v:Reflect(self.Owner, self, dir)
				reflect = true
			elseif AirblastFunc[c] then
				if AirblastFunc[c](self, v, dir, dir2) then
					reflect = true
				end
			elseif v:GetMoveType()==MOVETYPE_VPHYSICS then
				for i=0,v:GetPhysicsObjectCount()-1 do
					v:GetPhysicsObjectNum(i):ApplyForceCenter(18000*dir)
				end
			end
		end
	end
	
	if reflect then
		self:EmitSound(self.AirblastDeflectSound)
	end
end
