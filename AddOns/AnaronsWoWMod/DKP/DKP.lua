AWMDKPBonusPerMinute = 0
AWMDKPBonusPerMinuteTimer = GetTime()
AWMTrustedDKPSources = {}

function AWMDKPUpdate()
	AWMDKPMenuYourDKP:SetText('You have '..get(AWMDKP,UnitName('player'),0)..' DKP.')
end

function AWMAddDKPToPlayer(player,absolute,percentage)
	AWMSetDKPToPlayer(player,math.floor(get(AWMDKP,player,0)*(1+percentage/100) + absolute))
end

function AWMSetDKPToPlayer(player,value)
	if (value ~= nil) then
		AWMDKP[player] = value
	end
end

function AWMDKPSync()
	msg = ''
	for name, val in AWMDKP do
		msg = name..'$$'..val..'$$'..msg
	end
	SendAddonMessage('AWMDKPUpdate',msg,'RAID')
	SendAddonMessage('AWMDKPUpdate',msg,'GUILD')
end

SlashCmdList["AWMDKP_COMMAND"] = function(Flag)
	flag = string.lower(Flag)
	words = {};
	for word in string.gfind(flag, "[^%s]+") do
		table.insert(words, word);
	end
	if (words[1] == 'add') then
		if (table.getn(words) == 3) then
			local name = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2,string.len(words[2])))
			
			local dkp = words[3]
			local absolute = 0
			local percentage = 0
			if (string.sub(dkp,string.len(dkp)) == '%') then
				percentage = tonumber(string.sub(dkp,1,string.len(dkp)-1))
			else
				absolute = tonumber(dkp)
			end
			if (name == 'All') then
				for player in AWMDKP do
					AWMAddDKPToPlayer(player,absolute,percentage)
				end
				print('Added '..dkp..' DKP to the everyone.')
			elseif (name == 'Raid') then
				for i = 1,40 do
					local target = 'raid'..i
					if (UnitName(target)) then
						AWMAddDKPToPlayer(UnitName(target),absolute,percentage)
					end
				end
				print('Added '..dkp..' DKP to the entire raid.')
			elseif (name == 'Notraid') then
				for player in AWMDKP do
					AWMAddDKPToPlayer(player,absolute,percentage)
				end
				for i = 1,40 do
					local target = 'raid'..i
					if (UnitName(target)) then
						AWMAddDKPToPlayer(UnitName(target),absolute,percentage)
					end
				end
				print('Added '..dkp..' DKP to everyone not in raid.')
			elseif (name == 'Guild') then
				print('The "guild" command is not finished yet.')
			else
				AWMAddDKPToPlayer(name,absolute,percentage)
				print (name..' has '..get(AWMDKP,name)..' DKP.')
			end
			AWMDKPSync()
		else
			print ('The "add" command takes 2 arguments: 1) player name 2) amount to add.')
		end
--	elseif (words[1] == 'set') then
--		if (table.getn(words) == 3) then
--			local name = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2,string.len(words[2])))
--			if (name ~= 'Raid' and name ~= 'Guild') then
--				AWMSetDKPToPlayer(name,tonumber(words[3]))
--				print (name..' has '..get(AWMDKP,name)..' DKP.')
--			end
--		else
--			print ('The "set" command takes 2 arguments: 1) player name 2) amount set add.')
--		end
	elseif (words[1] == 'raidstart') then
		AWMDKPBonusPerMinute = 1
		print('All raid members will now gain 1 DKP per minute.')
	elseif (words[1] == 'raidstop') then
		AWMDKPBonusPerMinute = 0
		print('Raid members will not gain any DKPs per minute.')
	elseif (words[1] == 'get') then
		local name = string.upper(string.sub(words[2],1,1))..string.lower(string.sub(words[2],2,string.len(words[2])))
		print (name..' has '..get(AWMDKP,name,0)..' DKP.')
	elseif (words[1] == 'isolate') then
		AWMTrustedDKPSources = {}
	elseif (words[1] == 'sync') then
		AWMDKPSync()
	else
		print('Unknown command, try "add", "get", "sync" or "isolate".')
	end
end
SLASH_AWMDKP_COMMAND1 = "/dkp"


f = CreateFrame('Frame')
f:SetScript('OnEvent',function()
	if (arg1 == 'AWMDKPUpdate') then
		if (AWMTrustedDKPSources[arg4]) then
			local args = codeSplit(arg2)
			for i = 1, table.getn(args),2 do
				AWMSetDKPToPlayer(args[i],args[i+1])
			end
		elseif (AWMTrustedDKPSources[arg4] == nil) then
			AWMDKPPendingSource = arg4
			StaticPopupDialogs["AWMDKPTrustSender"]["text"] = arg4.." wants to sync his DKP table with you, do you want him to override your data?"
			StaticPopup_Show("AWMDKPTrustSender")
		end
	end
end);
f:RegisterEvent('CHAT_MSG_ADDON')

f = CreateFrame('Frame')
f:SetScript('OnUpdate',function()
	if (GetTime()-AWMDKPBonusPerMinuteTimer > 60) then
		if (AWMDKPBonusPerMinute ~= 0) then
			AWMDKPBonusPerMinuteTimer = GetTime()
			for i = 1,40 do
				local target = 'raid'..i
				if (UnitName(target)) then
					AWMAddDKPToPlayer(UnitName(target),AWMDKPBonusPerMinute,0)
				end
			end
			AWMDKPSync()
		end
	end
end)

StaticPopupDialogs["AWMDKPTrustSender"] = {
	text = "Do you trust him?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		AWMTrustedDKPSources[AWMDKPPendingSource] = true
	end,
	OnCancel = function()
		AWMTrustedDKPSources[AWMDKPPendingSource] = false
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
}