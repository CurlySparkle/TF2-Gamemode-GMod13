
include("sv_clientfiles.lua")
include("sv_resource.lua")
include("sv_response_rules.lua")

include("shared.lua")
include("sv_hl2replace.lua")
include("sv_gamelogic.lua")
include("sv_damage.lua")
include("sv_death.lua")

local LOGFILE = "teamfortress/log_server.txt"
file.Delete(LOGFILE)
file.Append(LOGFILE, "Loading serverside script\n")
local load_time = SysTime()

include("sv_npc_relationship.lua")
include("sv_ent_substitute.lua")

response_rules.Load("talker/tf_response_rules.txt")
response_rules.Load("talker/demoman_custom.txt")
response_rules.Load("talker/heavy_custom.txt")

-- Quickfix for Valve's typo in tf_reponse_rules.txt
response_rules.AddCriterion([[criterion "WeaponIsScattergunDouble" "item_name" "The Force-a-Nature" "required" weight 10]])

concommand.Add("spawncombine", function(pl, cmd, args)
	local n = tonumber(args[1]) or 0
	local pos = pl:GetEyeTrace().HitPos
	local ang = Angle(0,pl:EyeAngles().y,0)
	
	local e = ents.Create("npc_combine_s")
	if n==2 then
		e:SetKeyValue("model","models/combine_soldier_prisonguard.mdl")
	elseif n==3 then
		e:SetKeyValue("model","models/combine_super_soldier.mdl")
	else
		e:SetKeyValue("model","models/combine_soldier.mdl")
	end
	
	e:SetKeyValue("additionalequipment", "weapon_ar2")
	e:SetKeyValue("NumGrenades", 999999)
	e:SetPos(pos)
	e:SetAngles(ang)
	e:Spawn()
end)

concommand.Add("lua_pick", function(pl, cmd, args)
	getfenv()[args[1]] = pl:GetEyeTrace().Entity
end)

concommand.Add("select_slot", function(pl, cmd, args)
	local n = tonumber(args[1] or "")
	local w = pl:GetActiveWeapon()
	if n and w and w:IsValid() and w.OnSlotSelected then
		w:OnSlotSelected(n)
	end
end)

concommand.Add("decapme", function(pl, cmd, args)
	--pl:SetNWBool("ShouldDropDecapitatedRagdoll", true)
	pl:AddDeathFlag(DF_DECAP)
	pl:Kill()
end)

concommand.Add("make_npc_maker", function(pl, cmd, args)
	local e = ents.Create("npc_maker")
	e:SetPos(pl:GetEyeTrace().HitPos)
	e:SetKeyValue("NPCType", args[1])
	e:SetKeyValue("SpawnFrequency", args[2])
	e:SetKeyValue("MaxNPCCount", args[3])
	e:SetKeyValue("MaxLiveChildren", args[4])
	e:Spawn()
	
	e:Fire("Enable")
end)

concommand.Add("changeclass", function(pl, cmd, args)
	pl:SetPlayerClass(args[1])
end, function() return GAMEMODE.PlayerClassesAutoComplete end)

local SpawnableItems = {
	"item_ammopack_small",
	"item_ammopack_medium",
	"item_ammopack_full",
	"item_healthkit_small",
	"item_healthkit_medium",
	"item_healthkit_full",
}

hook.Add("InitPostEntity", "TF_InitSpawnables", function()
	local base = scripted_ents.GetStored("item_base")
	if not base or not base.t or not base.t.SpawnFunction then return end
	
	for _,v in ipairs(SpawnableItems) do
		local ent = scripted_ents.GetStored(v)
		if ent and ent.t then
			ent.t.SpawnFunction = base.t.SpawnFunction
		end
	end
end)

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_RED)
	
	-- Wait until InitPostEntity has been called
	if not self.PostEntityDone then
		timer.Simple(0.05, function() self:PlayerInitialSpawn(ply) end)
		return
	end
	
	Msg("PlayerInitialSpawn : "..ply:GetName().." "..tostring(self.Landmark).."\n")
	if self.Landmark and self.Landmark:IsValidMap() then
		self.Landmark:LoadPlayerData(ply)
	end
end

function GM:OnPlayerChangedTeam(ply, oldteam, newteam)
	if newteam == TEAM_SPECTATOR then
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( Pos )
	elseif oldteam == TEAM_SPECTATOR then
		ply:Spawn()
	end
 
	PrintMessage(HUD_PRINTTALK, Format("%s joined '%s'", ply:Nick(), team.GetName(newteam)))
	
	self:ClearDominations(ply)
	self:UpdateEntityRelationship(ply)
end

function GM:PlayerSpawn(ply)
	if ply.CPPos and ply.CPAng then
		ply:SetPos(ply.CPPos)
		ply:SetEyeAngles(ply.CPAng)
	end
	
	--ply:ShouldDropWeapon(true)
	--[[ply:SetNWBool("ShouldDropBurningRagdoll", false)
	ply:SetNWBool("ShouldDropDecapitatedRagdoll", false)
	ply:SetNWBool("DeathByHeadshot", false)]]
	ply:ResetDeathFlags()
	
	ply.LastWeapon = nil
	self:ResetKills(ply)
	self:ResetDamageCounter(ply)
	self:ResetCooperations(ply)
	self:StopCritBoost(ply)
	
	-- Reinitialize class
	if ply:GetPlayerClass()=="" then
		ply:SetPlayerClass("scout")
	else
		ply:SetPlayerClass(ply:GetPlayerClass())
	end
	
	if ply:Team()==TEAM_BLU then
		ply:SetSkin(1)
	else
		ply:SetSkin(0)
	end
	
	ply:Speak("TLK_PLAYER_EXPRESSION", true)
	
	umsg.Start("ExitFreezecam", ply)
	umsg.End()
end

-- Fixing spawning at the wrong spawnpoint on HL2 maps
function GM:PlayerSelectSpawn(pl)
	if self.MasterSpawn==nil then
		self.MasterSpawn = false
		for _,v in pairs(ents.FindByClass("info_player_start")) do
			if v.IsMasterSpawn then
				self.MasterSpawn = v
				break
			end
		end
	end
	
	if self.MasterSpawn then
		return self.MasterSpawn
	end
	
	return self.BaseClass:PlayerSelectSpawn(pl)
end

local PlayerGiveAmmoTypes = {TF_PRIMARY, TF_SECONDARY, TF_METAL}
function GM:GiveAmmoPercent(pl, pc, nometal)
	--Msg("Giving "..pc.."% ammo to "..pl:GetName().." : ")
	local ammo_given = false
	
	for _,v in ipairs(PlayerGiveAmmoTypes) do
		if not nometal or v ~= TF_METAL then
			if pl:GiveTFAmmo(pc * 0.01, v, true) then
				ammo_given = true
			end
		end
	end
	
	--Msg("\n")
	if ammo_given then
		if pl:GetActiveWeapon().CheckAutoReload then
			pl:GetActiveWeapon():CheckAutoReload()
		end
	end
	
	return ammo_given
end

function GM:GiveAmmoPercentNoMetal(pl, pc)
	return self:GiveAmmoPercent(pl, pc, true)
end

function GM:GiveHealthPercent(pl, pc)
	return pl:GiveHealth(pc * 0.01, true)
end

function GM:HealPlayer(healer, pl, h, effect, allowoverheal)
	local health_given = pl:GiveHealth(h, false, allowoverheal)
	--print(health_given)
	if effect then
		if pl:IsPlayer() then
			umsg.Start("PlayerHealthBonus", pl)
				umsg.Short(h)
			umsg.End()
			
			umsg.Start("PlayerHealthBonusEffect")
				umsg.Long(pl:UserID())
				umsg.Bool(h>0)
			umsg.End()
		else
			umsg.Start("EntityHealthBonusEffect")
				umsg.Entity(pl)
				umsg.Bool(h>0)
			umsg.End()
		end
	end
	
	if health_given <= 0 then return end
	if not healer or not healer:IsPlayer() then return end
	
	healer.AddedHealing = (healer.AddedHealing or 0) + health_given
	healer.HealingScoreProgress = (healer.HealingScoreProgress or 0) + health_given
end

-- Deprecated, use HealPlayer instead
function GM:GiveHealthBonus(pl, h, allowoverheal)
	pl:GiveHealth(h, false, allowoverheal)
	
	if pl:IsPlayer() then
		umsg.Start("PlayerHealthBonus", pl)
			umsg.Short(h)
		umsg.End()
		
		umsg.Start("PlayerHealthBonusEffect")
			umsg.Long(pl:UserID())
			umsg.Bool(h>0)
		umsg.End()
	else
		umsg.Start("EntityHealthBonusEffect")
			umsg.Entity(pl)
			umsg.Bool(h>0)
		umsg.End()
	end
	
	return true
end

file.Append(LOGFILE, Format("Done loading, time = %f\n", SysTime() - load_time))
local load_time = SysTime()
