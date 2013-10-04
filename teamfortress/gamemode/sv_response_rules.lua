
local tf_voice_cooldown = CreateConVar("tf_voice_cooldown", "1", {FCVAR_NOTIFY})

local function PrecacheGameSounds(path)
	local data
	
	if SERVER and game.IsDedicated() then
		data = file.Read(GM.Folder.."/content/scripts/"..path, "GAME")
	else
		data = file.Read(GM.Folder.."/content/scripts/"..path, "GAME")
	end
	
	data = '"woot"\n{\n'..data..'\n}\n'
	
	for s,_ in pairs(util.KeyValuesToTable(data)) do
		util.PrecacheSound(s)
	end
end

PrecacheGameSounds("tf_game_sounds_vo.txt")

module("response_rules", package.seeall)

Criteria = {}
Responses = {}
Rules = {}

local comparisons = {
	[">"]  = function(a,b) return a>b end,
	["<"]  = function(a,b) return a<b end,
	["<="] = function(a,b) return a<=b end,
	[">="] = function(a,b) return a>=b end,
	["!="] = function(a,b) return a~=b end,
	[""]   = function(a,b) return a==b end,
}

function AddCriterion(str)
	--[[
	local name, matchkey, matchvalue, required, weight, w =
		string.match(str, '[cC]riterion%s*"(%S*)"%s*"(%S*)"%s*"(%S*)"%s*(%S*)%s*(%S*)%s*(%S*)')
	]]
	local name, matchkey, matchvalue, required, weight, w =
		string.match(str, '[cC]riterion%s*(%b"")%s*(%b"")%s*(%b"")%s*(%S*)%s*(%S*)%s*(%S*)')
	name = string.match(name, '^"(.*)"$')
	matchkey = string.match(matchkey, '^"(.*)"$')
	matchvalue = string.match(matchvalue, '^"(.*)"$')
	
	if not name then
		return
	end
	
	local tbl = {}
	tbl.key = matchkey
	
	if (required=='required' or required=='"required"') then
		tbl.required = true
	end
	
	if (weight=='weight' or weight=='"weight"') and tonumber(w) then
		tbl.weight = tonumber(w)
	else
		tbl.weight = 1
	end
	
	tbl.values = {}
	for operator,value in string.gmatch(matchvalue, "([<>=!]*)([^,]+)") do
		local t = {}
		t.o = comparisons[operator] or comparisons[""]
		
		if tonumber(value) then
			t.n = tonumber(value)
		else
			t.n = value
		end
		
		table.insert(tbl.values, t)
	end
	if not tbl.values[1] then
		tbl.values[1] = {o=comparisons[""], n=""}
	end
	
	--Msg("Registered criterion '"..name.."'\n")
	
	Criteria[name] = tbl
	return tbl
end

function AddResponse(str)
	local name
	name, str = string.match(str, '[rR]esponse%s*"*(%a+)"*%s*{(.-)}')
	if not name then
		return
	end
	
	local tbl = {}
	
	for line in string.gmatch(str, ".-\n") do
		local head,param,param2,param3 = string.match(line, "(%S+)%s*(%S*)%s*(%S*)%s*(%S*)")
		if head=="scene" then
			local sc = string.match(param, '([%a%d_/%.]+)')
			PrecacheScene(sc)
			local t = {sc}
			if param2=="predelay" then
				t.predelay = {}
				for v in string.gmatch(param3, "[%d%.]+") do
					table.insert(t.predelay, tonumber(v) or 0)
				end
			end
			table.insert(tbl, t)
		end
	end
	
	Responses[name] = tbl
	return tbl
end

function AddRule(str)
	local name
	name, str = string.match(str, "[rR]ule%s*(%a+)%s*{(.-)}")
	if not name then
		return
	end
	
	local tbl = {}
	local criteria = string.match(str, "[cC]riteria%s*(.-)\n")
	
	if not criteria then
		return
	end
	
	tbl.criteria = {}
	for criterion in string.gmatch(criteria, "(%S+)") do
		table.insert(tbl.criteria, criterion)
	end
	
	local response = string.match(str, "[rR]esponse%s*(.-)\n")
	if not response then
		return
	end
	
	tbl.response = response
	
	local worldcontext = string.find(str, "applycontexttoworld")
	
	local context, value, duration = string.match(str, "[aA]pplyContext%s*\"(.-):(%d-):(%d-)\"\n")
	if context and value and duration then
		tbl.context = {context, tonumber(value) or 0, tonumber(duration) or 0, worldcontext ~= nil}
	end
	
	Rules[name] = tbl
	return tbl
end

function IsMatchingCriterion(ent,crit)
	local value = ent[crit.key]
	if not crit.values then return false end
	
	for _,v in ipairs(crit.values) do
		if not v.o(value, v.n) then
			return false
		end
	end
	
	return true
end

concommand.Add("match_criterion", function(pl,cmd,args)
	if not Criteria[args[1]] then return end
	pl:ChatPrint(tostring(IsMatchingCriterion(pl,Criteria[args[1]])))
end)

--------------------------------------------------------------------------------

function Load(path)
	Msg("Loading response/rules script '"..path.."' ... ")
	local nrule, nresp, ncrit = 0, 0, 0
	local data
	
	if SERVER and game.IsDedicated() then
		data = file.Read(GM.Folder.."/content/scripts/"..path, "GAME")
	else
		data = file.Read(GM.Folder.."/content/scripts/"..path, "GAME")
	end
	
	if not data or data=="" then
		MsgFN("Error, file '%s' not found!", path)
		return
	end
	
	data = string.gsub(data, "//.-\n", "")
	data = string.gsub(data, "\r", "") -- get rid of carriage returns
	
	-- Criteria
	for str in string.gmatch(data, "([cC]riterion.-\n)") do
		AddCriterion(str)
		ncrit = ncrit + 1
	end
	
	-- Rules
	for str in string.gmatch(data, "([rR]ule.-{.-})") do
		AddRule(str)
		nrule = nrule + 1
	end
	
	-- Responses
	for str in string.gmatch(data, "([rR]esponse.-{.-})") do
		AddResponse(str)
		nresp = nresp + 1
	end
	
	Msg(nrule.." rules, "..nresp.." responses, "..ncrit.." criteria\n")
	
	-- Includes
	for str in string.gmatch(data, "#include \"(.-)\"") do
		Load(str)
	end
end

local MissingCriterionErrorShown

function SelectResponse(ent, dbg)
	for k,v in pairs(ent.TemporaryContexts or {}) do
		if CurTime()>v then
			ent[k] = nil
		end
	end
	
	local bestrule, best, bestscore = nil, nil, 0
	for rname,rule in pairs(Rules) do
		local score = 0
		for rcrit,cname in ipairs(rule.criteria) do
			local criterion = Criteria[cname]
			
			if not criterion then
				if not MissingCriterionErrorShown then
					MissingCriterionErrorShown = true
					ErrorNoHalt("WARNING: Criterion '"..cname.."' is required for rule '"..rname.."' but was not found")
					ErrorNoHalt("WARNING: Outdated tf_response_rules.txt, some scenes might not function properly")
				end
			elseif IsMatchingCriterion(ent, criterion or {}) then
				score = score + criterion.weight
			elseif criterion.required then
				score = -1
				break
			end
		end
		
		if score>=bestscore and Responses[rule.response] then
			bestrule = rule
			best = Responses[rule.response]
			bestscore = score
		end
	end
	
	if bestrule and bestrule.context then
		if bestrule.context[4] then
			-- Apply the context to all players
			local n = "world"..bestrule.context[1]
			for _,v in pairs(player.GetAll()) do
				v[n] = bestrule.context[2]
				if not v.TemporaryContexts then v.TemporaryContexts = {} end
				v.TemporaryContexts[n] = CurTime() + bestrule.context[3]
			end
		else
			ent[bestrule.context[1]] = bestrule.context[2]
			if not ent.TemporaryContexts then ent.TemporaryContexts = {} end
			ent.TemporaryContexts[bestrule.context[1]] = CurTime() + bestrule.context[3]
		end
	end
	
	return best
end

local function playscene_delayed(ent, scene)
	if not IsValid(ent) then return end
	ent:PlayScene(scene, 0)
end

function PlayResponse(ent, response, nospeech)
	if ent.NextSpeak and CurTime()<ent.NextSpeak and not nospeech then
		return false
	end
	
	local num = #response
	local i = math.random(1,num)
	local j = i
	
	while response[j][1]==ent.LastScene and not nospeech do
		j = j+1
		if j>num then j=1 end
		if j==i then break end
	end
	
	local r = response[j]
	
	local delay
	if r.predelay then
		if r.predelay[2] then
			delay = math.Rand(r.predelay[1], r.predelay[2])
		else
			delay = r.predelay[1]
		end
	end
	
	if not ent.NextSpeak or CurTime()>ent.NextSpeak or nospeech then
		if delay then
			timer.Simple(delay, function() playscene_delayed(ent, r[1]) end)
		else
			ent:PlayScene(r[1], 0)
		end
		
		if not nospeech then
			ent.LastScene = r[1]
			
			if tf_voice_cooldown:GetBool() then
				ent.NextSpeak = CurTime() + 1.5
				if delay then ent.NextSpeak = ent.NextSpeak + delay end
			end
		end
		return true
	end
	
	return false
end

local META = FindMetaTable("Player")

function META:Speak(concept, nospeech, dbg)
	if self:IsHL2() then return false end
	
	if not self:Alive() then
		return false
	end
	--[[
	if not nospeech then
		Msg("Concept : "..concept.."\n")
	end]]
	
	----------------------------------------------------------------
	
	-- Which concept we want to play
	self.Concept = concept
	
	-- Random number
	self.randomnum = math.random(0,100)
	
	-- Current weapon
	if IsValid(self:GetActiveWeapon()) then
		self.playerweapon = self:GetActiveWeapon():GetClass()
		if self:GetActiveWeapon().GetItemData then
			self.item_name = self:GetActiveWeapon():GetItemData().name or ""
			self.item_type_name = self:GetActiveWeapon():GetItemData().item_type_name or ""
		else
			self.item_name = ""
			self.item_type_name = ""
		end
	else
		self.playeranim = ""
	end
	
	-- Health fraction
	self.playerhealthfrac = self:Health()/self:GetMaxHealth()
	
	-- What class the player is looking at
	self.crosshair_on = ""
	self.crosshair_enemy = "No"
	
	local start = self:GetShootPos()
	local endpos = start + self:GetAimVector() * 10000
	local tr = util.TraceHull{
		start = start,
		endpos = endpos,
		filter = self,
		mins = Vector(-10, -10, -10),
		maxs = Vector(10, 10, 10),
	}
	
	local class = ""
	if tr.Entity and tr.Entity:IsPlayer() then
		class = tr.Entity:GetPlayerClass()
		-- Capitalize player class because the talker system wants to :/
		class = string.upper(string.sub(class,1,1))..string.sub(class,2)
		
		if self:IsValidEnemy(tr.Entity) then
			self.crosshair_enemy = "Yes"
		end
	end
	self.crosshair_on = class
	
	-- Temporary
	self.GameRound = 5
	if self:IsLoser() then
		self.OnWinningTeam = 0
	else
		self.OnWinningTeam = 1
	end
	
	----------------------------------------------------------------
	
	local response = SelectResponse(self, dbg)
	
	if response then
		return PlayResponse(self, response, nospeech, dbg)
	end
	
	return false
end
