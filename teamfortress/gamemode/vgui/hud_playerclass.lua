local PANEL = {}

local W = ScrW()
local H = ScrH()
local Scale = H/480

local character_bg = {
	surface.GetTextureID("hud/character_red_bg"),
	surface.GetTextureID("hud/character_blue_bg"),
}
local character_default = surface.GetTextureID("hud/class_scoutred")

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(true)
end

function PANEL:PerformLayout()
	self:SetPos(0,0)
	self:SetSize(W,H)
end

function PANEL:Paint()
	if not LocalPlayer():Alive() or LocalPlayer():IsHL2() or GAMEMODE.ShowScoreboard or GetConVarNumber("cl_drawhud")==0 then return end
	
	local t = LocalPlayer():Team()
	local tbl = LocalPlayer():GetPlayerClassTable()
	
	local tex = character_bg[t] or character_bg[1]
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(9*Scale, (480-60)*Scale, 100*Scale, 50*Scale)
	
	tex = character_default
	if tbl and tbl.CharacterImage and tbl.CharacterImage[1] then
		tex = tbl.CharacterImage[t] or tbl.CharacterImage[1]
	end
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(25*Scale, (480-88)*Scale, 75*Scale, 75*Scale)
end

if HudPlayerClass then HudPlayerClass:Remove() end
HudPlayerClass = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))
