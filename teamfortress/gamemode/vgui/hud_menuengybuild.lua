
local PANEL = {}

local W = ScrW()
local H = ScrH()
local WScale = W/640
local Scale = H/480

local hud_menu_bg = surface.GetTextureID("hud/eng_build_bg")
local hud_menu_item_bg = surface.GetTextureID("hud/eng_build_item")
local ico_build = surface.GetTextureID("hud/ico_build")
local ico_metal = surface.GetTextureID("hud/ico_metal_mask")
local ico_key_blank = surface.GetTextureID("hud/ico_key_blank")

local hud_menu_sentry_build = surface.GetTextureID("hud/eng_build_sentry_blueprint")
local hud_menu_dispenser_build = surface.GetTextureID("hud/eng_build_dispenser_blueprint")
local hud_menu_tele_entrance_build = surface.GetTextureID("hud/eng_build_tele_entrance_blueprint")
local hud_menu_tele_exit_build = surface.GetTextureID("hud/eng_build_tele_exit_blueprint")

local BUILDINGS = {
	{"#TF_Object_Sentry", 				hud_menu_sentry_build},
	{"#TF_Object_Dispenser", 			hud_menu_dispenser_build},
	{"#TF_Object_Tele_Entrance_360", 	hud_menu_tele_entrance_build},
	{"#TF_Object_Tele_Exit_360", 		hud_menu_tele_exit_build},
}

function PANEL:Init()
	self:SetVisible(true)
	self:SetPaintBackgroundEnabled(false)
end

function PANEL:PerformLayout()
end

function PANEL:Paint()
	if not IsCustomHUDVisible("HudEngyMenuBuild") then
		return
	end
	
	local slot = self.slot or 1
	
	-- Name
	draw.Text{
		text=tf_lang.GetRaw(BUILDINGS[slot][1]),
		font="TFDefault",
		pos={(6)*Scale, (0+7.5)*Scale},
		color=Colors.TanLight,
		xalign=TEXT_ALIGN_LEFT,
		yalign=TEXT_ALIGN_CENTER,
	}
	
	-- Background
	surface.SetDrawColor(Colors.ProgressOffWhite)
	tf_draw.TexturedQuadPart(hud_menu_item_bg, (4-8)*Scale, (14-8)*Scale, (98+16)*Scale, (105+16)*Scale, 1, 1, 14, 15)
	
	-- Building blueprint
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(BUILDINGS[slot][2])
	surface.DrawTexturedRect(22*Scale, 33*Scale, 56*Scale, 56*Scale)
	
	-- Metal indicator
	surface.SetDrawColor(Colors.TanDarker)
	surface.SetTexture(ico_metal)
	surface.DrawTexturedRect(10*Scale, 18*Scale, 10*Scale, 10*Scale)
	
	draw.Text{
		text=150,
		font="HudFontSmall",
		pos={(23)*Scale, (17+6.5)*Scale},
		color=Colors.TanDarker,
		xalign=TEXT_ALIGN_LEFT,
		yalign=TEXT_ALIGN_CENTER,
	}
	
	-- Key
	surface.SetDrawColor(255,255,255,255)
	surface.SetTexture(ico_key_blank)
	surface.DrawTexturedRect(41*Scale, 99*Scale, 18*Scale, 18*Scale)
	
	draw.Text{
		text=slot,
		font="TFDefault",
		pos={(0+50)*Scale, (98+9)*Scale},
		color=Colors.Black,
		xalign=TEXT_ALIGN_CENTER,
		yalign=TEXT_ALIGN_CENTER,
	}
end

vgui.Register("HudEngyMenuBuildItem", PANEL)

PANEL = {}

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(true)
	
	self.Panels = {}
	for i=1,4 do
		local t = vgui.Create("HudEngyMenuBuildItem", self)
		t.slot = i
		self.Panels[i] = t
	end
end

function PANEL:PerformLayout()
	self:SetPos(W/2 - 225*Scale, H/2 - 55*Scale)
	self:SetSize(450*Scale, 195*Scale)
	
	for i=1,4 do
		self.Panels[i]:SetPos((25+100*(i-1))*Scale, 47*Scale)
		self.Panels[i]:SetSize(100*Scale, 124*Scale)
	end
end

function PANEL:Paint()
	if not IsCustomHUDVisible("HudEngyMenuBuild") then
		return
	end
	
	surface.SetDrawColor(255,255,255,255)
	tf_draw.TexturedQuadPart(hud_menu_bg, (0-16)*Scale, (10-16)*Scale, (450+32)*Scale, (170+32)*Scale, 0, 0, 32, 13)
	
	surface.SetTexture(ico_build)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawTexturedRect(16*Scale, -7*Scale, 48*Scale, 48*Scale)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(15*Scale, -8*Scale, 48*Scale, 48*Scale)
	
	local txt = {
		text=tf_lang.GetRaw("#Hud_menu_build_title"),
		font="HudFontGiantBold",
		pos={69*Scale, 20*Scale},
		color=Colors.Black,
		xalign=TEXT_ALIGN_LEFT,
		yalign=TEXT_ALIGN_CENTER,
	}
	
	draw.Text(txt)
	
	txt.pos = {68*Scale, 19*Scale}
	txt.color = Colors.TanLight
	draw.Text(txt)
	
	draw.Text{
		text=tf_lang.GetRaw("#Hud_Menu_Build_Cancel"),
		font="SpectatorKeyHints",
		pos={(218+200)*Scale, (35+6.5)*Scale},
		xalign=TEXT_ALIGN_RIGHT,
		yalign=TEXT_ALIGN_CENTER,
	}
	
end

if HudEngyMenuBuild then HudEngyMenuBuild:Remove() end
HudEngyMenuBuild = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))
