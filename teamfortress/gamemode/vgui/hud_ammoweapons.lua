local PANEL = {}

local W = ScrW()
local H = ScrH()
local WScale = W/640
local Scale = H/480

local ammo_bg = {
	surface.GetTextureID("hud/ammo_red_bg"),
	surface.GetTextureID("hud/ammo_blue_bg"),
}

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(true)
end

function PANEL:PerformLayout()
	self:SetPos(W-99*Scale,H-55*Scale)
	self:SetSize(90*Scale,45*Scale)
end

function PANEL:Paint()
	local w = LocalPlayer():GetActiveWeapon()
	
	if not LocalPlayer():Alive() or LocalPlayer():IsHL2() or GetConVarNumber("cl_drawhud")==0 or GAMEMODE.ShowScoreboard or not IsValid(w) or not w.Primary or string.lower(w.Primary.Ammo)=="none" then
		return
	end
	
	local ammo = w:Clip1()
	local reserve = w:Ammo1()
	
	local t = LocalPlayer():Team()
	local tbl = LocalPlayer():GetPlayerClassTable()
	
	local tex = ammo_bg[t] or ammo_bg[1]
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(2*Scale, 2*Scale, (90-2)*Scale, (45-2)*Scale)
	
	if w.Primary.ClipSize<0 then
		local param = {
			text=reserve,
			font="HudFontGiantBold",
			pos={80*Scale, (3+40-44)*Scale},
			color=Colors.Black,
			xalign=TEXT_ALIGN_RIGHT,
			yalign=TEXT_ALIGN_BOTTOM,
		}
		draw.Text(param)
		param.pos[1] = param.pos[1]-Scale
		param.pos[2] = param.pos[2]-Scale
		param.color=Colors.TanLight
		draw.Text(param)
	else
		local param = {
			text=ammo,
			font="HudFontGiantBold",
			pos={56*Scale, (41-44)*Scale},
			color=Colors.Black,
			xalign=TEXT_ALIGN_RIGHT,
			yalign=TEXT_ALIGN_BOTTOM,
		}
		draw.Text(param)
		param.pos[1] = param.pos[1]-Scale
		param.pos[2] = param.pos[2]-Scale
		param.color=Colors.TanLight
		draw.Text(param)
		
		param = {
			text=reserve,
			font="HudFontMediumSmall",
			pos={56*Scale, (9+27-18)*Scale},
			color=Colors.Black,
			xalign=TEXT_ALIGN_LEFT,
			yalign=TEXT_ALIGN_BOTTOM,
		}
		draw.Text(param)
		param.pos[1] = param.pos[1]-Scale
		param.pos[2] = param.pos[2]-Scale
		param.color=Colors.TanLight
		draw.Text(param)
	end
end

if HudAmmoWeapons then HudAmmoWeapons:Remove() end
HudAmmoWeapons = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))
