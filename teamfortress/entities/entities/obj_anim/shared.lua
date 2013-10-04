--[[
notes

build_point_0 = sapper attachment
laser_origin = wrangler laser attachment

direction = teleporter direction pose param

]]


ENT.Base = "base_entity"
ENT.Type = "anim"  

function ENT:SetupDataTables()
	self:DTVar("Entity", 0, "Builder")
	self:DTVar("Float", 0, "Scale")
	self:DTVar("Int", 0, "BuildGroup")
	self:DTVar("Int", 1, "BuildMode")
end

function ENT:SetBuildingScale(s)
	self.dt.Scale = s
end

function ENT:GetBuilder()
	return self.dt.Builder
end

function ENT:SetBuilder(pl)
	self.dt.Builder = pl
end

function ENT:GetBuildGroup()
	return self.dt.BuildGroup
end

function ENT:GetBuildMode()
	return self.dt.BuildMode
end

function ENT:SetBuildGroup(g)
	self.dt.BuildGroup = g
end

function ENT:SetBuildMode(m)
	self.dt.BuildMode = m
end

function ENT:GetBuildingData()
	local group, mode = self.dt.BuildGroup, self.dt.BuildMode
	if self.LastBuildGroup ~= group or self.LastBuildMode ~= mode then
		self.LastBuildGroup = group
		self.LastBuildMode = mode
		self.LastBuildData = tf_objects.Get(group, mode)
	end
	
	return self.LastBuildData or {}
end
