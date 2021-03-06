﻿------------------------------
--      Are you local?      --
------------------------------

local boss = AceLibrary("Babble-Boss-2.2")["Maexxna"]
local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

local times = {}
local prior = nil
local started

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Maexxna",

	spray_cmd = "spray",
	spray_name = "Web Spray Alert",
	spray_desc = "Warn for webspray and spiders",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",

	cocoon_cmd = "cocoon",
	cocoon_name = "Cocoon Alert",
	cocoon_desc = "Warn for Cocooned players",

	poison_cmd = "Poison",
	poison_name = "Necrotic Poison Alert",
	poison_desc = "Warn for Necrotic Poison",

	cocoontrigger = "(.*) (.*) afflicted by Web Wrap.",
	webspraytrigger = "afflicted by Web Spray.",
	poisontrigger = "afflicted by Necrotic Poison.",
	etrigger1 = "Maexxna gains Enrage",

	cocoonwarn = "%s Cocooned!",
	poisonwarn = "Necrotic Poison!",
--	enragetrigger = "%s becomes enraged.",

	webspraywarn31sec = "Wall Cocoons in ~10 seconds",
	webspraywarn15sec = "Wall Cocoons! 10 seconds until Spiders spawn!",
	webspraywarn5sec = "AOE - Spiders Spawn - AOE! WEB SPRAY 5 SECONDS!",
	webspraywarn = "Web Spray! 40 seconds until next!",

	enragewarn = "Enrage - SQUISH SQUISH SQUISH!",
	enragesoonwarn = "Enrage Soon! - Bug Swatters out!",

	webspraybar = "Web Spray",
	cocoonbar = "Cocoons",
	spiderbar = "Spiders",
	poisonbar = "Necrotic Poison",

	you = "You",
	are = "are",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsMaexxna = BigWigs:NewModule(boss)
BigWigsMaexxna.zonename = AceLibrary("Babble-Zone-2.2")["Naxxramas"]
BigWigsMaexxna.enabletrigger = boss
BigWigsMaexxna.toggleoptions = {"spray", "poison", "cocoon", "enrage", "bosskill"}
BigWigsMaexxna.revision = tonumber(string.sub("$Revision: 15520 $", 12, -3))

------------------------------
--      Initialization      --
------------------------------

function BigWigsMaexxna:OnEnable()
	self.enrageannounced = nil
	prior = nil
	times = {}
	started = nil

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Enrage")
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "GenericBossDeath")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "SprayEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "SprayEvent")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "SprayEvent")
	self:RegisterEvent("BigWigs_Message")
-- Don't use this until emote is fixed
--	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")

	self:RegisterEvent("BigWigs_RecvSync")
	self:TriggerEvent("BigWigs_ThrottleSync", "MaexxnaWebspray", 8)
	self:TriggerEvent("BigWigs_ThrottleSync", "MaexxnaPoison", 5)
	self:TriggerEvent("BigWigs_ThrottleSync", "MaexxnaCocoon", 0)
	-- the MaexxnaCocoon sync is left unthrottled, it's throttled inside the module itself
	-- because the web wrap happens to a lot of players at once.
end

function BigWigsMaexxna:SprayEvent( msg )
	-- web spray warning
	if string.find(msg, L["webspraytrigger"]) and not prior then
		self:TriggerEvent("BigWigs_SendSync", "MaexxnaWebspray")
	elseif string.find(msg, L["poisontrigger"]) then
		self:TriggerEvent("BigWigs_SendSync", "MaexxnaPoison")
	elseif string.find(msg, L["cocoontrigger"]) then
		local _,_,wplayer,wtype = string.find(msg, L["cocoontrigger"])
		if wplayer and wtype then
			if wplayer == L["you"] and wtype == L["are"] then
				wplayer = UnitName("player")
			end
			local t = GetTime()
			if ( not times[wplayer] ) or ( times[wplayer] and ( times[wplayer] + 10 ) < t) then
				self:TriggerEvent("BigWigs_SendSync", "MaexxnaCocoon "..wplayer)
			end
		end
	end
end

function BigWigsMaexxna:BigWigs_RecvSync( sync, rest )
	if sync == self:GetEngageSync() and rest and rest == boss and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then self:UnregisterEvent("PLAYER_REGEN_DISABLED") end
		self:BigWigs_RecvSync("MaexxnaWebspray", nil, nil)
	
	elseif sync == "MaexxnaPoison" then
		if self.db.profile.poison then 
		self:TriggerEvent("BigWigs_Message", L["poisonwarn"], "Urgent", true, "Long") end
		self:TriggerEvent("BigWigs_StartBar", self, L["poisonbar"], 20, "Interface\\Icons\\Ability_Creature_Poison_03" )
	
	elseif sync == "MaexxnaWebspray" then
		if prior then return end
		prior = true
		
		self:CancelScheduledEvent("bwmaexxna31")
		self:CancelScheduledEvent("bwmaexxna15")
		self:CancelScheduledEvent("bwmaexxna5")

-- No cocooon warning because we announce who is cocooned
-- and we don't want spam filter to mute us
		self:ScheduleEvent("bwmaexxna31", "BigWigs_Message", 9, L["webspraywarn31sec"], "Attention")
		self:ScheduleEvent("bwmaexxna15", "BigWigs_Message", 25, L["webspraywarn15sec"], "Attention")
		self:ScheduleEvent("bwmaexxna5", "BigWigs_Message", 35, L["webspraywarn5sec"], "Attention")

		self:TriggerEvent("BigWigs_Message", L["webspraywarn"], "Important")	
-- However there is still a bar for it
		self:TriggerEvent("BigWigs_StartBar", self, L["cocoonbar"], 22, "Interface\\Icons\\Spell_Nature_Web" )
		self:TriggerEvent("BigWigs_StartBar", self, L["spiderbar"], 35, "Interface\\Icons\\INV_Misc_MonsterSpiderCarapace_01" )
		self:TriggerEvent("BigWigs_StartBar", self, L["webspraybar"], 40, "Interface\\Icons\\Ability_Ensnare" )
	
	elseif sync == "MaexxnaCocoon" then
		local t = GetTime()
		if ( not times[rest] ) or ( times[rest] and ( times[rest] + 10 ) < t) then
			if self.db.profile.cocoon then self:TriggerEvent("BigWigs_Message", string.format(L["cocoonwarn"], rest), "Urgent" ) end
			times[rest] = t
		end
	end
end

function BigWigsMaexxna:UNIT_HEALTH( msg )
	if UnitName(msg) == boss then
		local health = UnitHealth(msg)
		if (health > 30 and health <= 35 and not self.enrageannounced) then
			if self.db.profile.enrage then 
			self:TriggerEvent("BigWigs_Message", L["enragesoonwarn"], "Important") end
			self.enrageannounced = true
		elseif (health > 40 and self.enrageannounced) then
			self.enrageannounced = nil
		end
	end
end

-- Doesnt happen yet, so comment out until its fixed
--function BigWigsMaexxna:CHAT_MSG_MONSTER_EMOTE( msg )
--	if self.db.profile.enrage and msg == L["enragetrigger"] then 
--		self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important")
--	end
--end

-- Workaround
function BigWigsMaexxna:Enrage( msg )
	if string.find(msg, L["etrigger1"]) then
		if self.db.profile.enrage then 
		self:TriggerEvent("BigWigs_Message", L["enragewarn"], "Important") 
		end
	end
end

function BigWigsMaexxna:BigWigs_Message(text)
	if text == L["webspraywarn5sec"] then
		prior = nil
	end
end
