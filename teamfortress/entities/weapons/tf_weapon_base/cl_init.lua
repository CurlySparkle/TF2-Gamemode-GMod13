include('shared.lua')


SWEP.PrintName			= "Scripted Weapon"

SWEP.Slot				= 0
SWEP.SlotPos			= 10
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true
SWEP.DrawWeaponInfoBox	= true
SWEP.BounceWeaponIcon   = true
SWEP.SwayScale			= 0.5
SWEP.BobScale			= 0.5

SWEP.RenderGroup 		= RENDERGROUP_OPAQUE

--[[
hook.Add("HUDPaint", "testlol", function()
	draw.Text{text="Current sequence = "..LocalPlayer():GetViewModel():GetSequence(),pos={10, 10}}
	draw.Text{text="Cycle = "..LocalPlayer():GetViewModel():GetCycle(),pos={10, 40}}
end)]]

hook.Add("Think", "TFCheckWeaponChanged", function()
	for _,v in pairs(player.GetAll()) do
		if v:GetActiveWeapon() ~= v.LastActiveWeapon then
			if IsValid(v.LastActiveWeapon) and v.LastActiveWeapon.ClearParticles then
				v.LastActiveWeapon:ClearParticles()
			end
			
			--MsgFN("Old weapon : %s", tostring(v.LastActiveWeapon))
			if IsValid(v.LastActiveWeapon) and v.LastActiveWeapon.NextDeployed and v.LastActiveWeapon.Holster then
				v.LastActiveWeapon:Holster()
			end
			v.LastActiveWeapon = v:GetActiveWeapon()
			if IsValid(v.LastActiveWeapon) and not v.LastActiveWeapon.NextDeployed and v.LastActiveWeapon.Deploy then
				v.LastActiveWeapon:Deploy()
			end
			--MsgFN("New weapon : %s", tostring(v.LastActiveWeapon))
			
			if IsValid(v.LastActiveWeapon) and v.LastActiveWeapon.ResetParticles then
				v.LastActiveWeapon:ResetParticles()
			end
		end
	end
end)

function SWEP:InitializeCModel()
	if not self.HasCModel then return end
	--Msg("InitializeCModel\n")
	local vm = self.Owner:GetViewModel()
	
	local wmodel = self.WorldModelOverride or self.WorldModel
	
	if IsValid(self.CModel) then
		self.CModel:SetModel(wmodel)
	elseif IsValid	(vm) then
		self.CModel = ClientsideModel(wmodel)
		if not IsValid(self.CModel) then return end
		
		self.CModel:SetPos(vm:GetPos())
		self.CModel:SetAngles(vm:GetAngles())
		self.CModel:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL))
		self.CModel:SetParent(vm)
		self.CModel:SetNoDraw(true)
	end
	
	if IsValid(self.CModel) then
		self.CModel.Player = self.Owner
		self.CModel.Weapon = self
		
		if self.MaterialOverride then
			self.CModel:SetMaterial(self.MaterialOverride)
		end
	end
end

function SWEP:InitializeWModel2()
	if not self.WorldModelOverride then return end
--Msg("InitializeWModel2\n")
	local wmodel = self.WorldModelOverride2 or self.WorldModelOverride or self.WorldModel
	
	if IsValid(self.WModel2) then
		self.WModel2:SetModel(wmodel)
	else
		self.WModel2 = ClientsideModel(wmodel)
		if not IsValid(self.WModel2) then return end
		
		self.WModel2:SetPos(self.Owner:GetPos())
		self.WModel2:SetAngles(self.Owner:GetAngles())
		self.WModel2:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL))
		self.WModel2:SetParent(self.Owner)
		self.WModel2:SetNoDraw(true)
		
		if wmodel == "models/weapons/w_models/w_shotgun.mdl" then
			self.WModel2:SetMaterial("models/weapons/w_shotgun_tf/w_shotgun_tf")
		end
	end
	
	if IsValid(self.WModel2) then
		self.WModel2.Player = self.Owner
		self.WModel2.Weapon = self
		
		if self.MaterialOverride then
			self.WModel2:SetMaterial(self.MaterialOverride)
		end
	end
end

function SWEP:InitializeAttachedModels()
--Msg("InitializeAttachedModels\n")
	if IsValid(self.AttachedWModel) then
		if self.AttachedWorldModel then
			self.AttachedWModel:SetModel(self.AttachedWorldModel)
		else
			self.AttachedWModel:Remove()
		end
	elseif self.AttachedWorldModel then
		local ent = (IsValid(self.WModel2) and self.WModel2) or self
		
		self.AttachedWModel = ClientsideModel(self.AttachedWorldModel)
		self.AttachedWModel:SetPos(ent:GetPos())
		self.AttachedWModel:SetAngles(ent:GetAngles())
		self.AttachedWModel:AddEffects(EF_BONEMERGE)
		self.AttachedWModel:SetParent(ent)
		self.AttachedWModel:SetNoDraw(true)
	end
	
	if IsValid(self.AttachedWModel) then
		self.AttachedWModel.Player = self.Owner
		self.AttachedWModel.Weapon = self
		
		if self.MaterialOverride then
			self.AttachedWModel:SetMaterial(self.MaterialOverride)
		end
	end
	
	if IsValid(self.AttachedVModel) then
		if self.AttachedViewModel then
			self.AttachedVModel:SetModel(self.AttachedViewModel)
		else
			self.AttachedVModel:Remove()
		end
	elseif self.AttachedViewModel then
		local ent = (IsValid(self.CModel) and self.CModel) or self.Owner:GetViewModel()
		
		if not IsValid(ent) then return end
		
		self.AttachedVModel = ClientsideModel(self.AttachedViewModel)
		self.AttachedVModel:SetPos(ent:GetPos())
		self.AttachedVModel:SetAngles(ent:GetAngles())
		self.AttachedVModel:AddEffects(EF_BONEMERGE)
		self.AttachedVModel:SetParent(ent)
		self.AttachedVModel:SetNoDraw(true)
	end
	
	if IsValid(self.AttachedVModel) then
		self.AttachedVModel.Player = self.Owner
		self.AttachedVModel.Weapon = self
		
		if self.MaterialOverride then
			self.AttachedVModel:SetMaterial(self.MaterialOverride)
		end
	end
end

-- Attached viewmodels seem to lose their parent when the player exits a vehicle, we'll force ViewModelDrawn to re-parent them to the player's viewmodel if the player has entered a vehicle
local LastVehicle = NULL
hook.Add("Think", "TFCheckPlayerInVehicle", function()
	local v = LocalPlayer():GetVehicle()
	
	if v ~= LastVehicle then
		if IsValid(v) then
			for _,w in pairs(LocalPlayer():GetWeapons()) do
				w.FixViewModel = true
			end
		end
		LastVehicle = v
	end
end)

function SWEP:RenderCModel()
	if IsValid(self.CModel) then
		self.CModel:DrawModel()
	end
	
	if IsValid(self.AttachedVModel) then
		self.AttachedVModel:DrawModel()
	end
end

function SWEP:RenderWModel()
	if IsValid(self.WModel2) then
		--self.WModel2:CreateShadow()
		self.WModel2:DrawModel()
	end
	
	if IsValid(self.AttachedWModel) then
		--self.AttachedWModel:CreateShadow()
		self.AttachedWModel:DrawModel()
	end
end

function SWEP:ViewModelDrawn()
	
	local vm = self.Owner:GetViewModel()
	vm.Player = self.Owner
	
	if not self.IsDeployed then
		local seq = vm:GetSequence()
		if vm:GetSequenceActivity(seq) == self.VM_DRAW then
			self.DeploySequence = seq
		end
		
		if self.Owner.TempAttributes and self.Owner.TempAttributes.DeployTimeMultiplier then
			vm:SetPlaybackRate(1 / self.Owner.TempAttributes.DeployTimeMultiplier)
		else
			vm:SetPlaybackRate(1)
		end
	else
		if self.DeploySequence ~= true and vm:GetSequence() ~= self.DeploySequence then
			vm:SetPlaybackRate(1)
			self.DeploySequence = true
		end
	end	
	
	if self.FixViewModel then
		if IsValid(self.CModel) then
			self.CModel:SetParent(vm)
		end
		self.FixViewModel = false
	end
	
	if self.ViewModelOverride --[[and self:GetModel()~=self.ViewModelOverride]] then
		self.ViewModel = self.ViewModelOverride
		self:SetModel(self.ViewModelOverride)
		vm:SetModel(self.ViewModelOverride)
	end
	
	if self.HasCModel and not IsValid(self.CModel) then
		return
	end
	
	self.DrawingViewModel = true
	if IsValid(self.CModel) then
		self.CModel:SetSkin(self.WeaponSkin or 0)
	end
	if IsValid(self.AttachedVModel) then
		self.AttachedVModel:SetSkin(self.WeaponSkin or 0)
	end
	self.Owner:GetViewModel():SetSkin(self.WeaponSkin or 0)
	
	if self.ViewModelFlip then
		render.CullMode(MATERIAL_CULLMODE_CW)
	end
	self:StartVisualOverrides()
	
	self:RenderCModel()
	
	self:EndVisualOverrides()
	if self.ViewModelFlip then
		render.CullMode(MATERIAL_CULLMODE_CCW)
	end
	
	self:ModelDrawn(true)
end

function SWEP:DrawWorldModel(from_postplayerdraw)
	--self:CheckUpdateItem()
	--self:SetNoDraw(true)
	
	-- this function is now called from PostPlayerDraw, don't do anything if it isn't
	if IsValid(self.WModel2) and not from_postplayerdraw then
		return
	end
	
	if not gamemode.Call("ShouldDrawWorldModel", self.Owner) then
		return
	end
	
	self:StartVisualOverrides()
	
	self.DrawingViewModel = false
	--if self.WorldModel and self.WorldModel~="" then
		if IsValid(self.WModel2) then
			self.WModel2:SetSkin(self.WeaponSkin or 0)
		end
		if IsValid(self.AttachedWModel) then
			self.AttachedWModel:SetSkin(self.WeaponSkin or 0)
		end
		--self:SetSkin(self.WeaponSkin or 0)
		
		self:RenderWModel()
	--end
	
	--[[
	for _,v in pairs(self.Owner:GetWeapons()) do
		if v~=self and v.PermanentWorldModel then
			v:DrawWorldModel(from_postplayerdraw)
		end
	end
	]]
	
	self:EndVisualOverrides()
	--render.SetBlend(0)	-- Rendering the world model also re-renders the player
	
	self:ModelDrawn(false)
end

-- Instead of using using DrawWorldModel to render the world model, do it here (at least it guarantees that it will be always drawn if the player is visible)
-- any potential problem with this?
hook.Add("PostPlayerDraw", "ForceDrawTFWorldModel", function(pl)
	if pl.RenderingWorldModel then
		render.SetBlend(1)
		return
	end
	
	if IsValid(pl:GetActiveWeapon()) and IsValid(pl:GetActiveWeapon().WModel2) then
		pl.RenderingWorldModel = true
		pl:GetActiveWeapon():DrawWorldModel(true)
		pl.RenderingWorldModel = false
	end
end)

-- Drawing the world model seems to redraw the player as well, this is quite annoying when a material is forced on the world model
-- as the player will be redrawn using that material as well
-- Just make players invisible if their world model is being rendered
hook.Add("PrePlayerDraw", "TFWorldModelHidePlayer", function(pl)
	if pl.RenderingWorldModel then
		render.SetBlend(0)
	end
end)

function SWEP:ModelDrawn(viewmode)
	
end

function SWEP:DoMuzzleFlash()
	local betaeffect = self.BetaMuzzle
	local ent
	
	if self.Owner==LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() then
		ent = self:GetViewModelEntity()
	else
		ent = self:GetWorldModelEntity()
	end
	
	self:ResetParticles()
	
	if betaeffect then
		local effectdata = EffectData()
			effectdata:SetEntity(ent)
		util.Effect(betaeffect, effectdata)
	else
		ParticleEffectAttach(self.MuzzleEffect, PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment("muzzle"))
	end
end

usermessage.Hook("DoMuzzleFlash", function(msg)
	local w = msg:ReadEntity()
	if IsValid(w) and w.DoMuzzleFlash then
		w:DoMuzzleFlash()
	end
end)

usermessage.Hook("CallTFWeaponFunction", function(msg)
	local w = msg:ReadEntity()
	local f = msg:ReadString()
	local p = msg:ReadString()
	
	if IsValid(w) and w[f] then
		w[f](w, p)
	end
end)

usermessage.Hook("PlayTFWeaponWorldReload", function(msg)
	local w = msg:ReadEntity()
	
	if IsValid(w) and w.ReloadSound and (w.Owner ~= LocalPlayer() or LocalPlayer():ShouldDrawLocalPlayer()) then
		w:EmitSound(w.ReloadSound)
	end
end)

hook.Add("EntityRemoved", "TFWeaponRemoved", function(ent)
	if ent.IsTFWeapon then
		if IsValid(ent.CModel) then ent.CModel:Remove() end
		if IsValid(ent.WModel2) then ent.WModel2:Remove() end
		if IsValid(ent.AttachedVModel) then ent.AttachedVModel:Remove() end
		if IsValid(ent.AttachedWModel) then ent.AttachedWModel:Remove() end
	end
end)
