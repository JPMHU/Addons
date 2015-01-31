---------------------------------------------------
-- This add-on was made by Aryna (ehaugw@aim.com)
-- to help players of the Feenix server, I consider
-- this as my own work, and would like if you don't
-- modify the code. If you want something changed,
-- please let me know by sending me an email, or an
-- ingame message. Thanks
-- - Aryna

AHSASpeed = 40


-- Split Stacks
SplitStacksTick = false
SplitTimer = GetTime()
function AI2SplitStacks(words)
	SplitItemLink = AIDeparse(words,3)
	SplitAmount = words[2]
	SplitStacksTick = true
	SplitBag = 0
	SplitSlot = 0
end
function AI2SplitStacksTick()
	if (SplitStacksTick) then
		if (GetTime() - SplitTimer > 0) then  
			SplitSlot = SplitSlot + 1
			if (SplitSlot > GetContainerNumSlots(SplitBag)) then
				SplitSlot = 1
				SplitBag = SplitBag + 1
			end
			if (SplitBag == 5) then
				SplitStacksTick = false
				return
				print("Split done")
			end
			itemlink = GetContainerItemLink(SplitBag,SplitSlot)
			if (itemlink == SplitItemLink) then
				_,quantum = GetContainerItemInfo(SplitBag,SplitSlot)
				if (quantum > tonumber(SplitAmount)) then
					SplitTimer = GetTime() + 0.25
					SplitContainerItem(SplitBag,SplitSlot,SplitAmount)
					SplitSlot = SplitSlot - 1
					for bag = 0,4 do
						for slot = 1,GetContainerNumSlots(bag) do
							if (GetContainerItemLink(bag,slot) == nil) then
								PickupContainerItem(bag,slot)
							end
						end
					end
				end
			end
		end
	end
end


-- Sell all equal on AH
AI2AHTime = GetTime() + 1000000000
function AI2SellAllOnAH(words)
	AI2AHLink = AIDeparse(words,6)
	AI2AHBid = words[2]
	AI2AHBuyout = words[3]
	AI2AHStack = words[4]
	AHSASpeed = words[5]
	AI2AHTime = 1440
	AI2AHTick = true
	AI2AHDone = false
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot) == nil) then
				AI2AHBag = bag
				AI2AHSlot = slot
				return
			end
			_,quantum = GetContainerItemInfo(bag,slot)
			if (GetContainerItemLink(bag,slot) == AI2AHLink) and (tonumber(AI2AHStack) == tonumber(quantum)) then
				AI2AHBag = bag
				AI2AHSlot = slot
				return
			end
		end
	end
	
end
function AI2AHSellTick()
	if (GetTime() - AI2AHTime > tonumber(AHSASpeed/100)) then
		AI2AHTime = GetTime()
		if (AI2AHTick) then
			AI2AHTick = false
			for bag = 0,4 do
				for slot = 1, GetContainerNumSlots(bag) do
					itemlink = GetContainerItemLink(bag,slot)
					if (itemlink == AI2AHLink) then
						_,quantum = GetContainerItemInfo(bag,slot)
						if (quantum >= tonumber(AI2AHStack)) then
							SplitContainerItem(bag,slot,AI2AHStack)
							PickupContainerItem(AI2AHBag,AI2AHSlot)
							return
						end
					end
				end
			end
			AI2AHDone = true
		else
			PickupContainerItem(AI2AHBag,AI2AHSlot)
			AI2SellOnAH(AI2AHBid, AI2AHBuyout)
			AI2AHTick = true
			if (AI2AHDone) then
				AI2AHTime = GetTime() + 100000000000
				print("All auctions created.")
			end
		end
	end
end

-- Sell one on AH
function AI2SellOnAH(arg1,arg2)
	ClickAuctionSellItemButton()
	StartAuction(arg1*10000, arg2*10000,1440)
end
-- Make new armor set
--[[
0 = ammo
1 = head
2 = neck
3 = shoulder
4 = shirt
5 = chest
6 = belt
7 = legs
8 = feet
9 = wrist
10 = gloves
11 = finger 1
12 = finger 2
13 = trinket 1
14 = trinket 2
15 = back
16 = main hand
17 = off hand
18 = ranged
19 = tabard
20 = first bag (the rightmost one)
21 = second bag
22 = third bag
23 = fourth bag (the leftmost one)
]]--
function AI2MakeArmorSet(words)
	local Table;
	local Register;
	local index;
	local item;
	local name;
	if (ArmorSetsRegister[words[2]]) then
		Register = ArmorSetsRegister[words[2]];
		for content in Register do
			Table = ArmorSetsTable[content];
			Table[words[2]] = nil;
			ArmorSetsTable[content] = Table;
		end
	end
	Register = {};
	
	for index = 1, 19 do
		item = GetInventoryItemLink("player", index)
		if (item) then
			name = GetItemName(item);
			Table = ArmorSetsTable[name];
			if (Table == nil) then
				Table = {};
			end
			Table[words[2]] = index;
			ArmorSetsTable[name] = Table;
			Register[name] = name;
		end
	end
	ArmorSetsRegister[words[2]] = Register;
	print("The \""..(words[2]).."\" armor set was made.");
end


function AI2EquipArmorSet(words)
	local item;
	local index, index2
	local bag2,slot2;
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag,slot)
			if (AI2IsInSet(item)) then
				index = AI2IsInSet(item);
				
				--[[if (index == 11) then
					item = GetInventoryItemLink("player",index);
					if (AI2IsInSet(item)) then
						index2 = AI2IsInSet(item);
						PickupInventoryItem(index);
						EquipCursorItem(index2);
					end
				end]]--
				PickupContainerItem(bag,slot);
				EquipCursorItem(index);
			end
		end
	end
end


-- Where should the item be equiped?
function AI2IsInSet(item)
	if (item) then
		local name = GetItemName(item);
		local Table = ArmorSetsTable[name];
		if (Table) then
			if (Table[words[2]]) then
				return tonumber(Table[words[2]]);
			end
		end
	end
	return nil;
end



-- Show value
function AI2ShowValue(words)
	local item = AIDeparse(words,2)
	local name = GetItemName(item);
	if (ValueTable[name]) then
		if ((ValueTable[name]) > 0) then
			print(item.." sells for "..AIToMoney(ValueTable[name])..".");
		else
			print(item.." can\'t be sold.");
		end
	else
		print(item.." has no registered value yet.");
	end
end


-- Clear all but [n] of one kind
function AI2ClearAllBut(words,addIndex, handler)
	if (handler == "SELL") and not (MerchantFrame:IsVisible() or BankFrame:IsVisible()) then
		print("You\'re not trading a vendor.");
		return;
	end
	local itemLink = AIDeparse(words,3+addIndex);
	local string
	deleted = 0;	
	remaining = tonumber(words[2+addIndex]);
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(4 - bag) do
			if itemLink == GetContainerItemLink(4 - bag,slot) then
				texture, itemCount = GetContainerItemInfo(4 - bag, slot);
				if (GetItemColor(itemLink) <= 2) then
					if (remaining > 0) then
						remaining = remaining - itemCount;
					else
						texture, itemCount = GetContainerItemInfo(4 - bag, slot);
						deleted = deleted + itemCount;
						if (handler == "DELETE") then
							PickupContainerItem(4 - bag,slot);
							DeleteCursorItem();
						elseif (handler == "SELL") then
							PickupContainerItem(bag,slot);
							UseContainerItem(4 - bag,slot);
						end
					end
				else
					print(itemLink.." was not touched!");
				end
			end
		end
	end
	if (handler == "DELETE") then
		string = "deleted";
	elseif (handler == "SELL") then
		if (BankFrame:IsVisible()) then
			string = "moved into the bank";
		else
			string = "sold";
		end
	end
	if (deleted > 0) then
		print(itemLink.." x"..deleted.." was "..string..".");
	else
		print("No "..itemLink.." was "..string..".");
	end
	return;
end


-- Count item
function AI2CountItem(words,addIndex)
	local itemLink = AIDeparse(words,3+addIndex);
	local count = 0;	
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if itemLink == GetContainerItemLink(bag,slot) then
				if (itemLink) then
					texture, itemCount = GetContainerItemInfo(bag, slot);
					count = count + itemCount;
				end
			end
		end
	end
	return count
end


-- Clear tags
function AI2ClearTags(words)
	item = AIDeparse(words,2);
	name = GetItemName(item);
	ItemsTable[name] = {};
	print("All the tags added to "..item.." is removed.");
end


-- Sell stuff
function AI2HandleItems(input1,input2,input3)
	if (input3 == nil) then
		input3 = 60;
	end
	input3 = tonumber(input3);
	if (input2 == "SELL") and not (MerchantFrame:IsVisible() or BankFrame:IsVisible()) then
		print("You\'re not trading a vendor.");
		return;
	end
	if (input2 == "SELL") and (BankFrame:IsVisible()) then
		input2 = "BANK";
	end
	local name;
	local item;
	local id;
	local handled = {};
	local link = {};
	local string = "";
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag,slot)
			if (item) then
				name = GetItemName(item);
				if (ItemsTable[name] == nil) and (GetItemColor(item) == 0) then
					ItemsTable[name] = {};
				end
				if (ItemsTable[name]) then
					Table = ItemsTable[name];
					if (GetItemColor(item) == 0) then
						Table["Trash"] = true;
						ItemsTable[name] = Table;
					end
					if (GetItemType(item) == "Recipe") then
						Table["Recipe"] = true;
						ItemsTable[name] = Table;
					end
					if (Table[input1]) and (GetItemSelectedInfo(item,"LEVEL") <= input3) then
						if (GetItemColor(item) <= 2) then
							if (handled[name] == nil) then
								handled[name] = 0;
							end
							link[name] = item;
							_, quantum = GetContainerItemInfo(bag, slot);
							handled[name] = handled[name] + quantum;
							if (input2 == "SELL") then
								string = "The following \""..input1.."\" items were sold:";
								PickupContainerItem(bag,slot);
								UseContainerItem(bag,slot);
							end
							if (input2 == "BANK") then
								string = "The following \""..input1.."\" items were moved into the bank:";
								PickupContainerItem(bag,slot);
								UseContainerItem(bag,slot);
							end
							if (input2 == "DELETE") then
								string = "The following \""..input1.."\" items were deleted:";
								PickupContainerItem(bag,slot);
								DeleteCursorItem();
							end
						else
							print(item.." was not touched!");
						end
					end
				end
			end
		end	
	end
	if (string ~= "") then
		for content in handled do
			if (input2 == "SELL") then
				string = string.."\r"..(link[content]).." x"..(handled[content]).." for "..(AIToMoney(ValueTable[content]*handled[content]))..".";
			elseif (input2 == "DELETE") or (input2 == "BANK") then
				string = string.."\r"..(link[content]).." x"..handled[content]..".";
			end
		end
		print(string);
	else
		if (input2 == "SELL") then
			print("No \""..input1.."\" items were sold.");
		elseif (input2 == "BANK") then
			print("No \""..input1.."\" items were moved into the bank.");
		elseif (input2 == "DELETE") then
			print("No \""..input1.."\" items were deleted.");
		end
	end
	return;
end


-- Add tag
function AI2Tag(words)
	local item = AIDeparse(words,3);
	local name = GetItemName(item);
	local tag = words[2];
	if (name) then
		local Table = ItemsTable[name];
		if (Table == nil) then
			Table = {};
		end
		if (tag == "Need") then
			Table["Greed"] = false;
			Table["Pass"] = false;
		elseif (tag == "Greed") then
			Table["Need"] = false;
			Table["Pass"] = false;
		elseif (tag == "Pass") then
			Table["Greed"] = false;
			Table["Need"] = false;
		elseif (tag == "Junk") then
			Table["Trash"] = false;
		elseif (tag == "Trash") then
			Table["Junk"] = false;
		end
		Table[tag] = true;
		Table["LINK"] = item;
		ItemsTable[name] = Table;
	end
	
end


-- Remove tag
function AI2UnTag(words)
	local item = AIDeparse(words,3);
	local name = GetItemName(item);
	local tag = words[2];
	if (name) then
		local Table = ItemsTable[name];
		if (Table == nil) then
			Table = {};
		end
		if (tag == "Need") then
			Table["Greed"] = false;
			Table["Pass"] = false;
		elseif (tag == "Greed") then
			Table["Need"] = false;
			Table["Pass"] = false;
		elseif (tag == "Pass") then
			Table["Greed"] = false;
			Table["Need"] = false;
		elseif (tag == "Junk") then
			Table["Trash"] = false;
		elseif (tag == "Trash") then
			Table["Junk"] = false;
		end
		Table[tag] = false;
		Table["LINK"] = item;
		ItemsTable[name] = Table;
	end
	
end


-- Modify tooltip
function AI2TooltipShow()
	local name = getglobal("GameTooltipTextLeft1"):GetText();
	local Table = ItemsTable[name];
	local leftText = "";
	local rightText = "";
	
	if (Table) then
		if (Table["Need"]) then
			leftText = "Auto-Need";
		elseif (Table["Greed"]) then
			leftText = "Auto-Greed";
		elseif (Table["Pass"]) then
			leftText = "Auto-Pass";
		else
			if (string.find(name,"Coin") or string.find(name,"Bijou")) then
				leftText = "Auto-Need";
			end
		end
		
		if (Table["Trash"]) then
			rightText = "Trash";
		elseif (Table["Junk"]) then
			rightText = "Junk";
		end
		
		if (leftText..rightText == rightText..leftText) then
			GameTooltip:AddLine(leftText..rightText ,0.3,0.7,0.9)
		else
			GameTooltip:AddDoubleLine(leftText, rightText ,0.3,0.7,0.9 ,0.3,0.7,0.9)
		end
		
		
		for content in Table do
			if (Table[content]) and (content ~= "Pass") and (content ~= "Need") and (content ~= "Greed") and (content ~= "Junk")and (content ~= "Trash")  and (content ~= "LINK") then
				GameTooltip:AddLine(content ,0.7,0.9,1)
			end
		end
		GameTooltip:Show()
	end
end


-- Register the values
function AI2RegisterValues()
	local name
	local item
	for bag = 0,4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag,slot)
			if (item) then
				name = GetItemName(item);
				SellPrice = 0;
				GameTooltip:SetBagItem(bag, slot);
				texture, itemCount = GetContainerItemInfo(bag, slot);		
				ValueTable[name] = SellPrice/itemCount;
			end
		end	
	end
end



-- Automatic roll on items
function AI2AutoRoll(id)
	local texture, name, count, quality = GetLootRollItemInfo(id);
	local Table = ItemsTable[name];
	if (Table == nil) then
		Table = {};
	end
	if (Table["Need"]) then
		RollOnLoot(id,1);
		return;
	elseif (Table["Greed"]) then
		RollOnLoot(id,2);
		return;
	elseif (Table["Pass"]) then
		RollOnLoot(id,0);
		return;
	end
	
	if (string.find(name,"Coin") or string.find(name,"Bijou")) then
		RollOnLoot(id,1);
		return;
		--SendChatMessage("*Auto-needed "..name.." with AutoInventory*","RAID");
	end
	return;
end


-- Repair gear
function AI2Repair()
	local cost = GetRepairAllCost();
	if (cost > 0) then
		RepairAllItems()
		print("The repair cost was "..AIToMoney(cost)..".");
	end
end

-- Get item value from vendor
GameTooltip:SetScript("OnTooltipAddMoney",
	function()
		SetTooltipMoney(GameTooltip, arg1);
		SellPrice = arg1;
		return "lol"
end)


-- Load addon
function AI2OnLoad()
	AI2Patch = 200000
	
	if (PersonalData == nil) then
		ItemsTable = {};
		ArmorSetsTable = {};
		ArmorSetsRegister = {};
		PersonalData = {};
		
		PersonalData["PATCH"] = AI2Patch;
	end
	
	if (GlobalData == nil) then
		ValueTable = {};
		GlobalData = {};
		
		GlobalData["PATCH"] = AI2Patch;
	end
	
	MissingLink = "You must link an item.";
	MissingGroup = "You must specify a group.";
	MissingGear = "You must specify a gear set name.";
end


-- Slash commands
SlashCmdList["AI2COMMANDS"] = function(Flag)
	if (Flag == "") then
		Flag = "help"
	end
	flag = string.lower(Flag);
	words = {};
	for word in string.gfind(Flag, "[^%s]+") do
		table.insert(words, word);
	end
	ARG = string.lower(words[1]);
	
	
	-- Shortcuts
	if (ARG == "markbank") or (ARG == "bank") or (ARG == "mb") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Bank")
			words[1] = "tag";
		else
			print(MissingLink);
		end
	elseif (ARG == "unmarkbank") or (ARG == "unbank") or (ARG == "ub") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Bank")
			words[1] = "untag";
		else
			print(MissingLink);
		end
	elseif (ARG == "clear") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"0")
			words[1] = "clearallbut";
		else
			print(MissingLink);
		end
	elseif (ARG == "sell") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"0")
			words[1] = "sellallbut";
		else
			print(MissingLink);
		end
	elseif (ARG == "nr") or (ARG == "needroll") or (ARG == "need") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Need")
			words[1] = "tag";
		else
			print(MissingLink);
		end
	elseif (ARG == "gr") or (ARG == "greedroll") or (ARG == "greed") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Greed")
			words[1] = "tag";
		else
			print(MissingLink);
		end
	elseif (ARG == "pr") or (ARG == "passroll") or (ARG == "pass") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Pass")
			words[1] = "tag";
		else
			print(MissingLink);
		end
	elseif (ARG == "mr") or (ARG == "manualroll") or (ARG == "manual") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Need")
			words[1] = "untag";
		else
			print(MissingLink);
		end
	elseif (ARG == "mj") or (ARG == "markjunk") or (ARG == "junk") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Junk")
			words[1] = "tag";
		else
			print(MissingLink);
		end
	elseif (ARG == "mt") or (ARG == "marktrash") or (ARG == "trash") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Trash")
			words[1] = "tag";
		else
			print(MissingLink);
		end
	elseif (ARG == "uj") or (ARG == "unmarkjunk") or (ARG == "unjunk") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Junk")
			words[1] = "untag";
		else
			print(MissingLink);
		end
	elseif (ARG == "utr") or (ARG == "unmarktrash") or (ARG == "untrash") then
		if (table.getn(words) > 1) then
			table.insert(words,2,"Trash")
			words[1] = "untag";
		else
			print(MissingLink);
		end
	end
	
	ARG = string.lower(words[1]);
	
	
	-- Full commands
	if (ARG == "showvalue") or (ARG == "sv") then
		if (table.getn(words) > 2) then
			AI2ShowValue(words);
		else
			print(MissingLink)
		end
	elseif (ARG == "ahs") or (ARG == "ahsell") then
		if (table.getn(words) ==3) then
			AI2SellOnAH(words[2],words[3])
		end
	elseif (ARG == "stop") then
		AI2AHTime = GetTime() + 1000000000
		SplitStacksTick = false;
		print("All actions were stopped")
	elseif (ARG == "ahsa") or (ARG == "ahsellall") then
		AI2SellAllOnAH(words)
	elseif (ARG == "ss") or (ARG == "splitstack") then
		AI2SplitStacks(words)
	elseif (flag == "sellalltrash") or (flag == "sat") then 
		AI2HandleItems("Trash","SELL");
	elseif (flag == "sellalljunk") or (flag == "saj") then 
		AI2HandleItems("Junk","SELL");
	elseif (flag == "clearalltrash") or (flag == "cat") then 
		AI2HandleItems("Trash","DELETE");
	elseif (flag == "clearalljunk") or (flag == "caj") then 
		AI2HandleItems("Junk","DELETE");
	elseif (ARG == "sellallbut") or (ARG == "sab") then
		-- CHECK HERE
		if (table.getn(words) > 2) then
			--print(AI2CountItem(words,0).." will be sold.")
			AI2ClearAllBut(words,0, "SELL")
		else
			print(MissingLink);
		end
	elseif (ARG == "clearallbut") or (ARG == "cab") then
		-- CHECK HERE
		if (table.getn(words) > 2) then
			--print(AI2CountItem(words,0).." will be deleted.")
			AI2ClearAllBut(words,0, "DELETE")
		else
			print(MissingLink);
		end
	elseif (ARG == "sellgroup") or (ARG == "sg") then
		if (table.getn(words) > 1) then
			AI2HandleItems(words[2],"SELL");
		else
			print(MissingGroup);
		end
	elseif (ARG == "cleargroup") or (ARG == "cg") then
		if (table.getn(words) > 1) then
			AI2HandleItems(words[2],"DELETE");
		else
			print(MissingGroup);
		end
	elseif (ARG == "cleartags") or (ARG == "ct") then
		if (table.getn(words) > 1) then
			AI2ClearTags(words);
		else
			print(MissingLink);
		end
	elseif (ARG == "tag") or (ARG == "tg") then
		if (table.getn(words) > 2) then
			AI2Tag(words);
		else
			print(MissingLink);
		end
	elseif (ARG == "untag") or (ARG == "ut") then
		if (table.getn(words) > 2) then
			AI2UnTag(words);
		else
			print(MissingLink);
		end
	elseif (ARG == "makearmorset") or (ARG == "makeset") or (ARG == "mas") then
		if (table.getn(words) > 1) then
			AI2MakeArmorSet(words)
		else
			print(MissingGear);
		end
	elseif (ARG == "equiparmorset") or (ARG == "equipset") or (ARG == "eas") then
		if (table.getn(words) > 1) then
			AI2EquipArmorSet(words)
		else
			print(MissingGear);
		end
	elseif (ARG == "getitemtype") or (ARG == "git") then
		if (table.getn(words) > 1) then
			print(GetItemType(GetItemLink(AIDeparse(words,2))))
		else
			print(MissingLink);
		end
	else
		print("Invalid command. Read the instructions in the README.");
	end
end

SLASH_AI2COMMANDS1 = "/ai";





StaticPopupDialogs["AI_CLEAR_CHECK"] = {
	text = "Question",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		AI2ClearAfterCheck()
	end,
	OnCancel = function()
		AI2CancelAfterCheck()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
}





-- Event handler.
CreateFrame("Frame", "AI2_ADDON_LOADED");
AI2_ADDON_LOADED:SetScript("OnEvent", function()
	if (arg1 == "AutoInventory2") then
		AI2_ADDON_LOADED:UnregisterEvent("ADDON_LOADED");
		AI2OnLoad();
	end
end);


CreateFrame("Frame", "AI2_AH");
AI2_AH:SetScript("OnUpdate", function()
	AI2AHSellTick()
end);

CreateFrame("Frame", "AI2_SPLIT_STACK");
AI2_SPLIT_STACK:SetScript("OnUpdate", function()
	AI2SplitStacksTick()
end);


CreateFrame("Frame", "AI2_MERCHANT_SHOW");
AI2_MERCHANT_SHOW:SetScript("OnEvent", function()
	AI2Repair();
	AI2RegisterValues()
	AI2HandleItems("Junk","SELL");
	AI2HandleItems("Trash","SELL");
end);


CreateFrame("Frame", "AI2_START_LOOT_ROLL");
AI2_START_LOOT_ROLL:SetScript("OnEvent", function()
	AI2AutoRoll(arg1);
end);

CreateFrame("Frame", "AI2_BANKFRAME_OPENED");
AI2_BANKFRAME_OPENED:SetScript("OnEvent", function()
	AI2HandleItems("Bank","SELL");
end);


AI2_BANKFRAME_OPENED:RegisterEvent("BANKFRAME_OPENED");
AI2_START_LOOT_ROLL:RegisterEvent("START_LOOT_ROLL");
AI2_MERCHANT_SHOW:RegisterEvent("MERCHANT_SHOW");
AI2_ADDON_LOADED:RegisterEvent("ADDON_LOADED");


-- ##### ARYNASFUNCTIONS

function print(String)
	DEFAULT_CHAT_FRAME:AddMessage(String, 1.0, 1.0, 0.0);
end

function GetItemSelectedInfo(Link,itemType)
	local a,b,c,d,e,f,g,h = GetItemInfo(GetItemLink(Link));
	local info = {}
	info["NAME"] = a;
	info["LINK"] = b;
	info["COLOR"] = c;
	info["LEVEL"] = d;
	info["TYPE"] = e;
	info["SUBTYPE"] = f;
	info["MAXSTACK"] = g
	return info[itemType];
end

function GetItemType(Link)
	local a,b,c,d,e,f,g,h = GetItemInfo(GetItemLink(Link));
	--a = name, b = link, c = color, d = level, e = AHtype, f = subtype, g = max stack
	return e;
end
function GetItemName(Link)
	itemLink=GetItemLink(Link)
	local name = GetItemInfo(itemLink);
	return name;
end
function GetItemColor(Link)
	itemLink=GetItemLink(Link)
	local _,_,color = GetItemInfo(itemLink);
	return color;
end
function GetItemLink(Link)
	local _,_,itemLink=string.find(Link,"(item:%d+)");
	return itemLink;
end

function AIToMoney(input)
	local Gold = math.floor(input/10000);
	local Silver = math.floor((input - Gold*10000)/100);
	local Bronze = input - Gold * 10000 - Silver * 100;
	local String = 0;
	if Gold > 0 then
		String = Gold.."g";
	end
	if Silver > 0 then
		if Gold > 0 then
			String = String..", "..Silver.."s";
		else
			String = Silver.."s";
		end
	end
	if Bronze > 0 then
		if Gold > 0 or Silver > 0 then
			String = String..", "..Bronze.."c";
		else
			String = Bronze.."c";
		end
	end
	return String;
end

function AIDeparse(nameFragments, start)
	local FullName = ""
	for index = start,table.getn(nameFragments) do
		if FullName == "" then
			FullName = nameFragments[index];
		else
			FullName = (FullName.." "..(nameFragments[index]));
		end
	end
	return FullName;
end
