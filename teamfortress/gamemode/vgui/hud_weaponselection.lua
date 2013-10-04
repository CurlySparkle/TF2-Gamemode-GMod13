local PANEL = {}

local W = ScrW()
local H = ScrH()
local WScale = W/640
local Scale = H/480

-- maximum number of slots to be displayed
local MAXSLOTS = 6

local color_panel = {
	[0]=surface.GetTextureID("hud/color_panel_brown"),
	surface.GetTextureID("hud/color_panel_red"),
	surface.GetTextureID("hud/color_panel_blu"),
}
local w_machete_large = surface.GetTextureID("backpack/weapons/c_models/c_sandwich/c_sandwich_large")
local teamnames = {"red","blue"}
--local w_machete_large = surface.GetTextureID("sprites/bucket_fists_blue")

local ACTIVE_WIDTH = 110
local ACTIVE_HEIGHT = 77
local INACTIVE_WIDTH = 71.5
local INACTIVE_HEIGHT = 54
local GAP_HEIGHT = 3.75

local DEFAULT_ICONS = {
tf_weapon_bat					= "sprites/bucket_bat_%s",
tf_weapon_bonesaw				= "sprites/bucket_bonesaw",
tf_weapon_bottle				= "sprites/bucket_bottle_%s",
tf_weapon_builder				= "sprites/bucket_sapper",
tf_weapon_club					= "sprites/bucket_machete",
tf_weapon_fireaxe				= "sprites/bucket_fireaxe",
tf_weapon_fists					= "sprites/bucket_fists_%s",
tf_weapon_flamethrower			= "sprites/bucket_flamethrower_%s",
tf_weapon_grenadelauncher		= "sprites/bucket_grenlaunch",
tf_weapon_knife					= "sprites/bucket_knife",
tf_weapon_medigun				= "sprites/bucket_medigun_%s",
tf_weapon_minigun				= "sprites/bucket_minigun",
tf_weapon_pda_engineer_build	= "sprites/bucket_pda_build",
tf_weapon_pda_engineer_destroy	= "sprites/bucket_pda_destroy",
tf_weapon_pipebomblauncher		= "sprites/bucket_pipelaunch",
tf_weapon_pistol				= "sprites/bucket_pistol",
tf_weapon_pistol_scout			= "sprites/bucket_pistol",
tf_weapon_revolver				= "sprites/bucket_revolver",
tf_weapon_rocketlauncher		= "sprites/bucket_rl",
tf_weapon_scattergun			= "sprites/bucket_scatgun",
tf_weapon_shotgun_hwg			= "sprites/bucket_shotgun",
tf_weapon_shotgun_primary		= "sprites/bucket_shotgun",
tf_weapon_shotgun_pyro			= "sprites/bucket_shotgun",
tf_weapon_shotgun_soldier		= "sprites/bucket_shotgun",
tf_weapon_shovel				= "sprites/bucket_shovel",
tf_weapon_smg					= "sprites/bucket_smg",
tf_weapon_sniperrifle			= "sprites/bucket_sniper",
tf_weapon_syringegun_medic		= "sprites/bucket_syrgun_%s",
tf_weapon_wrench				= "sprites/bucket_wrench",
}

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(false)
	
	self.Panels = {}
	for i=1,MAXSLOTS do
		local t = vgui.Create("ItemModelPanel")
		t:SetParent(self)
		t.activeImage = color_panel[1]
		t.inactiveImage = color_panel[0]
		t.srcborder = 23
		t.drawborder = 4.5*Scale
		t.disabled = true
		t.itemImage = w_machete_large
		t.itemImage_low = nil
		t.text = "THE SANDVICH"
		t.number = i
		t:SetQuality("Unique")
		
		self.Panels[i] = t
	end
	
	self.Loadout = {}
	self.Current = 1
	
	--[[self:SetLoadout({1,2,3})
	self:Select(1)]]
end

function PANEL:PerformLayout()
	self:SetPos(0,0)
	self:SetSize(W,H)
	
	if not self.Panels then return end
	
	local y = (H - (self.TotalHeight)*Scale) / 2
	for k=1,self.NumSlots do
		local t = self.Panels[k]
		if k == self.Current then
			t:SetPos(W-(ACTIVE_WIDTH+3)*Scale, y)
			t:SetSize(ACTIVE_WIDTH*Scale, ACTIVE_HEIGHT*Scale)
			t.model_ypos = 5
			t.model_tall = 62
			t.text_ypos = 57.5 +5
			t.inactiveImage = color_panel[1]
			y = y + (ACTIVE_HEIGHT+GAP_HEIGHT)*Scale
		else
			t:SetPos(W-(INACTIVE_WIDTH+3)*Scale, y)
			t:SetSize(INACTIVE_WIDTH*Scale, INACTIVE_HEIGHT*Scale)
			t.model_ypos = 5
			t.model_tall = 42
			t.text_ypos = 38.5
			t.inactiveImage = color_panel[0]
			y = y + (INACTIVE_HEIGHT+GAP_HEIGHT)*Scale
		end
	end
end

function PANEL:CanSelectSlot(n)
	for i,l in ipairs(self.Loadout) do
		if l.slot == n then
			return true
		end
	end
	return false
end

function PANEL:Select(n)
	for i=1,MAXSLOTS do
		self.Panels[i].Hover = false
	end
	
	for i,l in ipairs(self.Loadout) do
		if l.slot == n then
			self.Current = i
			self.CurrentSlot = l.slot
			self.Panels[self.Current].Hover = true
			self:InvalidateLayout()
			return
		end
	end
end

function PANEL:GetNextSlot(n)
	for i,l in ipairs(self.Loadout) do
		if l.slot == n then
			if self.Loadout[i+1] then
				return self.Loadout[i+1].slot
			else
				return self.Loadout[1].slot
			end
		end
	end
	return 1
end

function PANEL:GetPreviousSlot(n)
	for i,l in ipairs(self.Loadout) do
		if l.slot == n then
			if self.Loadout[i-1] then
				return self.Loadout[i-1].slot
			else
				return self.Loadout[#self.Loadout].slot
			end
		end
	end
	return 1
end

function PANEL:CalcCurrentWeaponSlot()
	for i=1,self.NumSlots do
		local l = self.Loadout[i]
		
		if l and l.ent == LocalPlayer():GetActiveWeapon() then
			return i
		end
	end
	
	return 1
end

function PANEL:UpdateLoadout()
	self.Loadout = {}
	
	local maxslot = 0
	local loadout = {}
	
	for _,v in pairs(LocalPlayer():GetWeapons()) do
		if v.Slot and not v.Hidden then
			loadout[v.Slot+1] = {
				class=v:GetClass(),
				ent=v,
				slot=v.Slot+1,
				id=(v.ItemIndex and v:ItemIndex()) or -1
			}
			
			if v.Slot>maxslot then maxslot = v.Slot end
		end
	end
	
	for i=1,maxslot+1 do
		if loadout[i] then
			table.insert(self.Loadout, loadout[i])
		end
	end
	
	self.NumSlots = math.Clamp(#self.Loadout, 0, MAXSLOTS)
	self.TotalHeight = (INACTIVE_HEIGHT + 4) * (self.NumSlots-1) + ACTIVE_HEIGHT
	self:InvalidateLayout()
	
	for i=1,MAXSLOTS do
		local t = self.Panels[i]
		local l = self.Loadout[i]
		
		if i<=self.NumSlots then
			t:SetVisible(true)
			local w = tf_items.ItemsByID[l.id]
			if w then
				if w.baseitem and DEFAULT_ICONS[l.class] then
					t.itemImage = surface.GetTextureID(Format(DEFAULT_ICONS[l.class], teamnames[LocalPlayer():EntityTeam()] or teamnames[1]))
				elseif w.image_inventory then
					t.itemImage = surface.GetTextureID(w.image_inventory)
				else
					t.itemImage = nil
				end
				
				
				t:SetTextColor(l.ent:GetNameColor())
				local q = (l.ent.GetQuality and l.ent:GetQuality()) or 0
				
				if q == 0 then
					t.text = nil
				else
					t.text = l.ent:GetFullName()
				end
			else
				t.itemImage = l.ent
				t:SetTextColor(l.ent:GetNameColor())
				t.text = l.ent:GetFullName()
			end
			
			if LocalPlayer():EntityTeam() == TEAM_BLU then
				t.activeImage = color_panel[2]
			else
				t.activeImage = color_panel[1]
			end
			
			t.number = l.slot
			t.itemImage_hi = nil
			
			if l.ent == LocalPlayer():GetActiveWeapon() then
				self.Current = i
				self.CurrentSlot = l.slot
			end
		else
			t:SetVisible(false)
		end
	end
end

function PANEL:SetLoadout(tbl)
	self.Loadout = table.Copy(tbl)
	self.NumSlots = math.Clamp(#self.Loadout, 1, MAXSLOTS)
	self.TotalHeight = (INACTIVE_HEIGHT + 4) * (self.NumSlots-1) + ACTIVE_HEIGHT
	self:InvalidateLayout()
	
	for k=1,MAXSLOTS do
		local t = self.Panels[k]
		
		if k<=self.NumSlots then
			t:SetVisible(true)
			local w = TF_WEAPONS[self.Loadout[k]]
			if w then
				local tex = Format(w.icon, teamnames[LocalPlayer():EntityTeam()] or teamnames[1])
				t.itemImage = surface.GetTextureID(tex)
				t.itemImage_hi = nil
				t.text = w.name
			else
				t.itemImage = nil
				t.itemImage_hi = nil
				t.text = nil
			end
		else
			t:SetVisible(false)
		end
	end
end

function PANEL:CanSelectWeapon(n)
	--[[n = self.Loadout[n or self.Current]
	for _,v in pairs(LocalPlayer():GetWeapons()) do
		if v:GetClass()==n then return true end
	end
	return false]]
	
	return true
end

function PANEL:CurrentWeapon()
	--return self.Loadout[self.Current]
	return self.Loadout[self.Current].class
end

function PANEL:Paint()
	if not LocalPlayer():Alive() then
		self:SetVisible(false)
	end
end

if HudWeaponSelection then HudWeaponSelection:Remove() end
HudWeaponSelection = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))
