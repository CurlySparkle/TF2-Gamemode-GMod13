local mat_MotionBlur	= Material("pp/motionblur")
local mat_Screen		= Material("pp/fb")
local tex_MotionBlur	= render.GetMoBlurTex0()

local cam_collision		= GetConVar("cam_collision")
local cam_idealdist		= GetConVar("cam_idealdist")
local cam_ideallag		= GetConVar("cam_ideallag")
local cam_idealpitch	= GetConVar("cam_idealpitch")
local cam_idealyaw		= GetConVar("cam_idealyaw")
local sensitivity		= GetConVar("sensitivity")

local deathcam_dist					= CreateConVar("deathcam_dist"					, 100)
local deathcam_zoomout_delay		= CreateConVar("deathcam_zoomout_delay"			, 1.5)
local deathcam_lag					= CreateConVar("deathcam_lag"					, 2)
local deathcam_rot_approach_speed	= CreateConVar("deathcam_rot_approach_speed"	, 6)

local freezecam_dist			= CreateConVar("freezecam_dist"				, 100)
local freezecam_dist_variation	= CreateConVar("freezecam_dist_variation"	, 0.5)
local freezecam_delay			= CreateConVar("freezecam_delay"			, 2.5)
local freezecam_timetoarrive	= CreateConVar("freezecam_timetoarrive"		, 0.5)

ThirdpersonEndDelay			= 0.3
SensitivityMultiplier		= 0.0022
LagMultiplier				= 2

FreezecamSpeedMultiplier	= 0.1
FreezecamMinSpeed			= 10
FreezecamMaxSpeed			= 160

--util.PrecacheSound("TFPlayer.FreezeCam")
--util.PrecacheSound("Camera.SnapShot")
util.PrecacheSound("misc/freeze_cam.wav")
util.PrecacheSound("misc/freeze_cam_snapshot.wav")

usermessage.Hook("SetPlayerKiller", function(msg)
	LocalPlayer().Killer = msg:ReadEntity()
	LocalPlayer().KillerName = msg:ReadString()
	LocalPlayer().KillerTeam = msg:ReadShort()
	LocalPlayer().KillerDominationInfo = msg:ReadChar()
	LocalPlayer().KillerPlayer = msg:ReadEntity()
	if not IsValid(LocalPlayer().KillerPlayer) then
		LocalPlayer().KillerPlayer = LocalPlayer().Killer
	end
	LocalPlayer().KillerRagdollEntity = NULL
end)

usermessage.Hook("ExitFreezecam", function()
	StopFreezeCam()
end)

--[[
hook.Add("DoPlayerDeath", "SetPlayerKiller", function(pl, attacker)
	print("penis", attacker)
	if pl==attacker or attacker:IsWorld() or not attacker:IsPlayer() or not attacker:IsNPC() then
		pl.Killer = nil
	else
		pl.Killer = attacker
	end
end)]]

hook.Add("CreateMove", "SimulateCamera", function(cmd)
	if LocalPlayer().SimulatedCamera then
		if not LocalPlayer().CameraAngles then
			LocalPlayer().CameraAngles = LocalPlayer():EyeAngles()
		end
		
		local s = SensitivityMultiplier * sensitivity:GetFloat()
		LocalPlayer().CameraAngles.p = math.Clamp(LocalPlayer().CameraAngles.p + cmd:GetMouseY() * s, -90, 90)
		LocalPlayer().CameraAngles.y = math.NormalizeAngle(LocalPlayer().CameraAngles.y - math.Clamp(cmd:GetMouseX() * s, -180, 180))
	end
end)

function GM:OnViewModeChanged(tp)
	LocalPlayer():UpdateStateParticles()
end

function ViewTarget(ent)
	if ent:GetClass()=="class C_ClientRagdoll" or ent:GetClass()=="class C_HL2MPRagdoll" then
		local bone = ent:GetPhysicsObjectNum(0)
		if bone and bone:IsValid() then
			return bone:GetPos()
		end
	end
	
	if ent:IsPlayer() then
		return ent:GetPos() + ent:GetViewOffset()
	elseif ent:IsNPC() then
		return ent:GetPos() + Vector(0, 0, 50)
	end
	return ent:GetPos()
end

function SetDesiredCenteredView(pl, origin, ang, tbl)
	tbl = tbl or {}
	local newang = ang + Angle(cam_idealpitch:GetFloat(), cam_idealyaw:GetFloat(), 0)
	newang.r = 0
	local newdist = tbl.dist or cam_idealdist:GetFloat()
	
	if not pl.CurrentView then
		pl.CurrentView = {
			angles = tbl.defaultang or ang,
			distance = tbl.defaultdist or 0
		}
	end
	
	pl.TargetView = {
		angles = newang,
	}
	
	local lag = LagMultiplier/(LagMultiplier+(tbl.lag or cam_ideallag:GetFloat()))
	
	pl.CurrentView.angles = LerpAngle(lag, pl.CurrentView.angles, pl.TargetView.angles)
	pl.CurrentView.angles.r = 0
	
	if tbl.collision or cam_collision:GetBool() then
		local tr = util.TraceHull{
			start = origin,
			endpos = origin - newdist * pl.CurrentView.angles:Forward(),
			filter = pl,
			mins = Vector(-3,-3,-3),
			maxs = Vector( 3, 3, 3)
		}
		newdist = newdist * tr.Fraction
	end
	pl.TargetView.distance = newdist
	
	if pl.CurrentView.distance>pl.TargetView.distance then
		pl.CurrentView.distance = pl.TargetView.distance
	else
		pl.CurrentView.distance = Lerp(lag, pl.CurrentView.distance, pl.TargetView.distance)
	end
	
	return {angles = pl.CurrentView.angles, origin = origin - pl.CurrentView.distance * pl.CurrentView.angles:Forward()}
end

hook.Add("CalcView", "TFCalcView", function(pl, pos, ang, fov)
	if not IsValid(pl) then
		return
	end
	
	if IsValid(GetViewEntity()) and GetViewEntity() ~= pl then
		return
	end
	
	--------------------------------------------------------------------------------------------
	-- FREEZECAM
	if pl.FrozenScreen then
		return {origin = pl.FreezeCamPos, angles = pl.FreezeCamAng}
	end
	
	if pl.FreezeCam then
		local targetpos
		if IsValid(pl.FreezeCamTarget) then
			targetpos = ViewTarget(pl.FreezeCamTarget)
		elseif pl.FreezeCamDefaultTargetPos then
			targetpos = pl.FreezeCamDefaultTargetPos
		else
			return StopFreezeCam()
		end
		
		local targetang = (targetpos-pl.FreezeCamPos):Angle()
		targetang.p = 0
		
		local tr = util.TraceLine{
			start = targetpos,
			endpos = targetpos - targetang:Forward() * pl.FreezeCamDistance,
			filter = pl.FreezeCamTarget,
		}
		
		targetpos = tr.HitPos
		
		local d = pl.FreezeCamPos:Distance(targetpos)
		pl.FreezeCamSpeed = math.Clamp(FreezecamSpeedMultiplier * pl.FreezeCamStartPos:Distance(targetpos) / freezecam_timetoarrive:GetFloat(),
			FreezecamMinSpeed, FreezecamMaxSpeed)
		if d<pl.FreezeCamSpeed then
			StartFreezeScreen()
			pl.FreezeCamAng = targetang
			return {origin = pl.FreezeCamPos, angles = pl.FreezeCamAng}
		else
			pl.FreezeCamPos = pl.FreezeCamPos + (targetpos - pl.FreezeCamPos) * (pl.FreezeCamSpeed / d)
			return {origin = pl.FreezeCamPos, angles = targetang}
		end
	end
	
	
	--------------------------------------------------------------------------------------------
	-- DEATH CAM
	if not pl:Alive() then
		if not pl.LastDead then
			pl.CurrentView = nil
			pl.NextEndDeathcamZoomOut = CurTime() + deathcam_zoomout_delay:GetFloat()
			pl.NextFreezeCam = CurTime() + freezecam_delay:GetFloat()
			pl.CurrentDeathcamAngle = ang
		end
		
		local killer = pl.Killer
		if IsValid(killer) and IsValid(killer.DeathRagdoll) then
			pl.KillerRagdollEntity = killer.DeathRagdoll
		end
		if IsValid(pl.KillerRagdollEntity) then
			killer = pl.KillerRagdollEntity
		end
		
		if pl.NextFreezeCam and CurTime()>pl.NextFreezeCam then
			local viewpos = pl.DeathCamPos - pl.CurrentView.distance * pl.CurrentView.angles:Forward()
			pl.NextFreezeCam = nil
			StartFreezeCam(viewpos, killer, pl.LastKillerPos)
			return SetDesiredCenteredView(pl, pl.DeathCamPos, pl.CurrentDeathcamAngle, {
				dist=dist,
				defaultdist=10,
				lag=deathcam_lag:GetFloat()
			})
		end
		
		local dist
		if CurTime()<pl.NextEndDeathcamZoomOut then
			dist = Lerp((pl.NextEndDeathcamZoomOut-CurTime())/deathcam_zoomout_delay:GetFloat(),deathcam_dist:GetFloat(),0)
		else
			dist = deathcam_dist:GetFloat()
		end
		
		local rag = pl:GetRagdollEntity()
		if IsValid(rag) then
			local origin
			local bone = rag:GetPhysicsObjectNum(0)
			if bone and bone:IsValid() then
				origin = bone:GetPos()
			else
				local min,max = rag:WorldSpaceAABB()
				origin = (min+max)*0.5
			end
			
			pl.DeathCamPos = origin + Vector(0,0,20)
		elseif not pl.DeathCamPos then
			pl.DeathCamPos = pl:GetPos() + Vector(0, 0, 10)
		end
		
		pl.LastDead = true
		
		if IsValid(killer) then
			pl.LastKillerPos = ViewTarget(killer)
			local targetang = (pl.LastKillerPos-pl.DeathCamPos):Angle()
			pl.CurrentDeathcamAngle.p = targetang.p
			if math.abs(math.AngleDifference(pl.CurrentDeathcamAngle.y, targetang.y))>deathcam_rot_approach_speed:GetFloat() then
				pl.CurrentDeathcamAngle.y = math.ApproachAngle(pl.CurrentDeathcamAngle.y, targetang.y, deathcam_rot_approach_speed:GetFloat())
			else
				pl.CurrentDeathcamAngle.y = targetang.y
			end
			
			return SetDesiredCenteredView(pl, pl.DeathCamPos, pl.CurrentDeathcamAngle, {
				dist=dist,
				lag=deathcam_lag:GetFloat()
			})
		else
			return SetDesiredCenteredView(pl, pl.DeathCamPos, ang, {
				dist=dist,
				lag=deathcam_lag:GetFloat()
			})
		end
	else
		if pl.LastDead then
			pl.CurrentView = nil
			pl.Killer = nil
			pl.LastKillerPos = nil
		end
		
		pl.DeathCamPos = nil
		pl.LastDead = false
	end
	
	--------------------------------------------------------------------------------------------
	-- THIRD PERSON
	if not pl.IsThirdperson then
		return
	end
	
	if pl.SimulatedCamera and pl.CameraAngles then
		ang = pl.CameraAngles
	end
	
	if pl.NextEndThirdperson then
		if CurTime()>pl.NextEndThirdperson then
			pl.NextEndThirdperson = nil
			pl.IsThirdperson = false
			--[[if not IsValid(GetViewEntity()) or GetViewEntity()==LocalPlayer() then
				gamemode.Call("OnViewModeChanged", false)
			end]]
			return
		else
			pl.CurrentView.angles = ang
			pl.CurrentView.distance = Lerp((pl.NextEndThirdperson - CurTime())/ThirdpersonEndDelay, 0, pl.TargetView.distance)
			return {angles = pl.CurrentView.angles, origin = pos - pl.CurrentView.distance * pl.CurrentView.angles:Forward()}
		end
	end
	
	return SetDesiredCenteredView(pl, pos, ang)
end)

function GM:PostProcessPermitted(pp)
	-- Don't apply post processing when freezecam is active
	if LocalPlayer().FrozenScreen and LocalPlayer().FrozenScreenReady then
		return false
	end
	return self.BaseClass:PostProcessPermitted(pp)
end

function GM:RenderScreenspaceEffects()
	self.BaseClass:RenderScreenspaceEffects()
	
	if LocalPlayer().FrozenScreen then
		if not LocalPlayer().FrozenScreenReady then
			-- Capture the screen when every post processing operation is done
			render.UpdateScreenEffectTexture()
			mat_Screen:SetFloat("$alpha", 1)
			
			local OldRT = render.GetRenderTarget()
			render.SetRenderTarget(tex_MotionBlur)
			render.SetMaterial(mat_Screen)
			render.DrawScreenQuad()
			render.SetRenderTarget(OldRT)
			
			LocalPlayer().FrozenScreenReady = true
			CalloutPanel:SetupCalloutPanels()
			return
		end
		
		mat_MotionBlur:SetFloat("$alpha", 1)
		mat_MotionBlur:SetTexture("$basetexture", tex_MotionBlur)
		render.SetMaterial(mat_MotionBlur)
		render.DrawScreenQuad()
	end
end

function GM:ShouldDrawLocalPlayer()
	return LocalPlayer().IsThirdperson
end

function StartThirdperson()
	LocalPlayer().IsThirdperson = true
	LocalPlayer().CurrentView = nil
	
	--[[if not IsValid(GetViewEntity()) or GetViewEntity()==LocalPlayer() then
		gamemode.Call("OnViewModeChanged", true)
	end]]
end

function EndThirdperson(immediate)
	if immediate then
		LocalPlayer().NextEndThirdperson = nil
		LocalPlayer().IsThirdperson = false
	else
		LocalPlayer().NextEndThirdperson = CurTime() + ThirdpersonEndDelay
	end
end

function StartSimulatedCamera()
	LocalPlayer().SimulatedCamera = true
	LocalPlayer().CameraAngles = nil
end

function EndSimulatedCamera()
	LocalPlayer().SimulatedCamera = false
end

function StartFreezeScreen()
	LocalPlayer().FrozenScreen = true
	LocalPlayer().FrozenScreenReady = false
end

function StopFreezeScreen()
	LocalPlayer().FrozenScreen = false
end

function StartFreezeCam(startpos, target, defaultpos)
	FreezePanelBase:Show()
	
	LocalPlayer().FreezeCamStartPos = startpos
	LocalPlayer().FreezeCamPos = startpos
	LocalPlayer().FreezeCam = true
	LocalPlayer().FreezeCamTarget = target
	LocalPlayer().FreezeCamDefaultTargetPos = defaultpos
	
	local var = freezecam_dist_variation:GetFloat()
	LocalPlayer().FreezeCamDistance = freezecam_dist:GetFloat() * (1+math.Rand(-var, var))
	
	local targetpos
	if IsValid(target) then targetpos = ViewTarget(target)
	elseif defaultpos then targetpos = defaultpos
	else return StopFreezeCam()
	end
	
	LocalPlayer().FreezeCamSpeed = math.Clamp(FreezecamSpeedMultiplier * startpos:Distance(targetpos) / freezecam_timetoarrive:GetFloat(),
		FreezecamMinSpeed, FreezecamMaxSpeed)
	LocalPlayer():EmitSound("misc/freeze_cam.wav")
end

function StopFreezeCam()
	FreezePanelBase:Hide()
	
	LocalPlayer().FreezeCam = false
	StopFreezeScreen()
	StopScreenshot()
end

function StartScreenshot()
	if LocalPlayer().InScreenshot then return end
	
	GAMEMODE:HideHUDElement("CHudChat")
	LocalPlayer().InScreenshot = true
	FreezePanelBase:InvalidateLayout()
	CalloutPanel:RefreshCalloutPanels()
	LocalPlayer().ScreenshotStage = 0
end

function StopScreenshot()
	GAMEMODE:ShowHUDElement("CHudChat")
	LocalPlayer().InScreenshot = false
	FreezePanelBase:InvalidateLayout()
	LocalPlayer().ScreenshotStage = nil
end

hook.Add("PlayerBindPress", "ScreenshotPress", function(pl, bind)
	if pl==LocalPlayer() and LocalPlayer().FrozenScreen and LocalPlayer().FrozenScreenReady and bind=="jpeg" then
		StartScreenshot()
		return true
	end
end)

hook.Add("Think", "ViewEntityCheck", function()
	local viewent = GetViewEntity()
	local lastviewent = LocalPlayer().LastViewEntity
	
	local shoulddraw = LocalPlayer():ShouldDrawLocalPlayer()
	local lastshoulddraw = LocalPlayer().LastShouldDrawLocalPlayer
	
	--[[
	if lastviewent then
		if viewent ~= lastviewent then
			if (IsValid(viewent) and viewent~=LocalPlayer()) and not (IsValid(lastviewent) and lastviewent~=LocalPlayer()) then
				gamemode.Call("OnViewModeChanged", true)
			elseif not (IsValid(viewent) and viewent~=LocalPlayer()) and (IsValid(lastviewent) and lastviewent~=LocalPlayer()) then
				gamemode.Call("OnViewModeChanged", false)
			end
		end
	end]]
	
	if shoulddraw ~= lastshoulddraw then
		gamemode.Call("OnViewModeChanged", shoulddraw)
	end
	
	LocalPlayer().LastShouldDrawLocalPlayer = shoulddraw
	LocalPlayer().LastViewEntity = viewent
end)

hook.Add("Think", "ScreenshotProcess", function()
	local st = LocalPlayer().ScreenshotStage
	
	if st==0 then
		LocalPlayer().ScreenshotStage = 1
	elseif st==1 then
		RunConsoleCommand("jpeg")
		LocalPlayer().ScreenshotStage = 2
	elseif st==2 then
		CalloutPanel:Flash(0.5)
		LocalPlayer().ScreenshotStage = nil
	end
end)

concommand.Add("tf_firstperson", function(pl)
	if pl.IsThirdperson then
		EndThirdperson()
	end
end)

concommand.Add("tf_thirdperson", function(pl)
	if not pl.IsThirdperson then
		StartThirdperson()
	end
end)