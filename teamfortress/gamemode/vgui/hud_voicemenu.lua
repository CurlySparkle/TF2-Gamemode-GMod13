local PANEL = {}

local W = ScrW()
local H = ScrH()
local WScale = W/640
local Scale = H/480

local VoiceMenuList = {
{
	{"TLK_PLAYER_MEDIC",	"#Voice_Menu_Medic"},
	{"TLK_PLAYER_THANKS",	"#Voice_Menu_Thanks"},
	{"TLK_PLAYER_GO",		"#Voice_Menu_Go"},
	{"TLK_PLAYER_MOVEUP",	"#Voice_Menu_MoveUp"},
	{"TLK_PLAYER_LEFT",		"#Voice_Menu_Left"},
	{"TLK_PLAYER_RIGHT",	"#Voice_Menu_Right"},
	{"TLK_PLAYER_YES",		"#Voice_Menu_Yes"},
	{"TLK_PLAYER_NO",		"#Voice_Menu_No"},
},

{
	{"TLK_PLAYER_INCOMING",			"#Voice_Menu_Incoming"},
	{"TLK_PLAYER_CLOAKEDSPY",		"#Voice_Menu_CloakedSpy"},
	{"TLK_PLAYER_SENTRYAHEAD",		"#Voice_Menu_SentryAhead"},
	{"TLK_PLAYER_TELEPORTERHERE",	"#Voice_Menu_TeleporterHere"},
	{"TLK_PLAYER_DISPENSERHERE",	"#Voice_Menu_DispenserHere"},
	{"TLK_PLAYER_SENTRYHERE",		"#Voice_Menu_SentryHere"},
	{"TLK_PLAYER_ACTIVATECHARGE",	"#Voice_Menu_ActivateCharge"},
	{"TLK_PLAYER_CHARGEREADY",		"#Voice_Menu_ChargeReady"},
},

{
	{"TLK_PLAYER_HELP",			"#Voice_Menu_Help"},
	{"TLK_PLAYER_BATTLECRY",	"#Voice_Menu_BattleCry"},
	{"TLK_PLAYER_CHEERS",		"#Voice_Menu_Cheers"},
	{"TLK_PLAYER_JEERS",		"#Voice_Menu_Jeers"},
	{"TLK_PLAYER_POSITIVE",		"#Voice_Menu_Positive"},
	{"TLK_PLAYER_NEGATIVE",		"#Voice_Menu_Negative"},
	{"TLK_PLAYER_NICESHOT",		"#Voice_Menu_NiceShot"},
	{"TLK_PLAYER_GOODJOB",		"#Voice_Menu_GoodJob"},
}
}

concommand.Add("voicemenu", function(pl, cmd, args)
	local a, b = tonumber(args[1]), tonumber(args[2])
	if not a or not b then return end
	
	if a < 0 then
		HudVoiceMenu:Hide()
	end
	
	local v = VoiceMenuList[a+1]
	if not v then return end
	
	v = v[b+1]
	if not v then return end
	
	RunConsoleCommand("__svspeak", v[1])
	HudVoiceMenu:Hide()
end)

local VoiceTable = {}

local TextYOffset = 9.3*Scale
local FadeInTime = 0.15
local FadeOutTime = 0.3
local AutoCloseTime = 10

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(false)
	
	self.BackgroundColor = table.Copy(Colors.TransparentLightBlack)
	self.ForegroundColor = table.Copy(Colors.TanLight)
end

function PANEL:PerformLayout()
	self:SetPos(5*Scale,H*0.5 - 104*Scale)
	self:SetSize(380*Scale, 200*Scale)
end

function PANEL:SelectMenu(n)
	if not VoiceMenuList[n] then return end
	if n == self.CurrentMenu then
		self:Hide()
		return
	end
	
	VoiceTable = {}
	for k, v in ipairs(VoiceMenuList[n]) do
		VoiceTable[k] = Format("%d. %s", k, tf_lang.GetRaw(v[2]))
	end
	table.insert(VoiceTable, "0. "..tf_lang.GetRaw("#Cancel"))
	
	self.CurrentMenu = n
	self:Show()
end

function PANEL:Show()
	self:SetVisible(true)
	self.Opened = true
	self.EndTime = CurTime() + FadeInTime
	self.NextAutoClose = CurTime() + AutoCloseTime
end

function PANEL:Hide()
	if not self.Opened then return end
	self.Opened = false
	self.EndTime = CurTime() + FadeOutTime
	self.CurrentMenu = nil
end

function PANEL:Paint()
	if self.NextAutoClose and CurTime() > self.NextAutoClose then
		self.NextAutoClose = nil
		self:Hide()
	end
	
	if self.EndTime then
		local r
		if self.Opened then
			r = math.Clamp(1 - (self.EndTime - CurTime()) / FadeInTime, 0, 1)
		else
			r = math.Clamp((self.EndTime - CurTime()) / FadeOutTime, 0, 1)
			if r == 0 then
				self:SetVisible(false)
				return
			end
		end
		
		self.BackgroundColor.a = Lerp(r, 0, Colors.TransparentLightBlack.a)
		self.ForegroundColor.a = Lerp(r, 0, Colors.TanLight.a)
	else
		self.BackgroundColor.a = Colors.TransparentLightBlack.a
		self.ForegroundColor.a = Colors.TanLight.a
	end
	
	local height = TextYOffset * (#VoiceTable - 1)
	local y0 = 100*Scale - height * 0.5
	
	local width = 0
	surface.SetFont("TFDefault")
	for _,v in ipairs(VoiceTable) do
		local w, h = surface.GetTextSize(v)
		width = math.max(width, w)
	end
	
	draw.RoundedBox(4, 0, y0 - TextYOffset, width + 10*Scale, height + 2*TextYOffset, self.BackgroundColor)
	
	local param = {
		font="TFDefault",
		pos={4.5*Scale, y0},
		color=self.ForegroundColor,
		xalign=TEXT_ALIGN_LEFT,
		yalign=TEXT_ALIGN_CENTER,
	}
	for _,v in ipairs(VoiceTable) do
		param.text = v
		draw.Text(param)
		param.pos[2] = param.pos[2] + TextYOffset
	end
end

if HudVoiceMenu then HudVoiceMenu:Remove() end
HudVoiceMenu = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))

concommand.Add("voice_menu_1", function()
	HudVoiceMenu:SelectMenu(1)
end)

concommand.Add("voice_menu_2", function()
	HudVoiceMenu:SelectMenu(2)
end)

concommand.Add("voice_menu_3", function()
	HudVoiceMenu:SelectMenu(3)
end)

hook.Add("PlayerSlotSelected", "VoiceMenuSelect", function(slot)
	if HudVoiceMenu.CurrentMenu then
		RunConsoleCommand("voicemenu", HudVoiceMenu.CurrentMenu - 1, slot - 1)
		return true
	end
end)
