local TotalTick = 0;
local Burn_UpdateInterval = 0.01;
local NTTs = {};
local Burn_Timer = 0;
local CombustN = 0;
local Burn_igniteOn=false;
local ticked = false;
local Burn_total = 0;
local Burn_mageList = {};
local Burn_igniteStacks = 0;
local Burn_group = "none";
local Burn_alpha = 0.0
local Burn_highTick = {};
local Burn_highTotal = {};
local Burn_infoNum = 1;
local Burn_buTimer = 0;
local Burn_clock = 0;
local Burn_warnAlpha = 0;
local Burn_critFlash = 0;
local Burn_igniteSplashtimer = 0;
local Burn_critOwnerTest = 0;
local BunitID = "";


function Burn_Onload()

	--test
	Burn_Crit_5_1:SetVertexColor(0,0,0,0)
	Burn_Crit_5_2:SetVertexColor(0,0,0,0)
	Burn_Ignite_Splash:SetVertexColor(0,0,0,0)

	
	Burn_r1=1
	Burn_b1=0
	Burn_g1=0
	Burn_r2=1
	Burn_b2=0
	Burn_g2=0.5
	Burn_rt=0
	Burn_gt=.8
	Burn_bt=.7	
	Burn_on = true
	Burnguihelp1:Hide();
	Burnguihelp2:Hide();
	Burnguihelp3:Hide();
	Burnguihelp4:Hide();
	Burn_size = 1.8;
	Burn_min = false;

	
	ConsoleExec("SET CombatLogRange \"50\"");
	ConsoleExec("SET CombatLogRangeFriendlyPlayers \"50\"")
	ConsoleExec("SET CombatLogRangeCreature \"50\"");
	ConsoleExec("SET CombatLogRangeHostilePlayers \"50\"");
	ConsoleExec("SET CombatLogRangeHostilePlayersPets \"50\"");
	ConsoleExec("SET CombatLogPartyRange \"50\"");
	ConsoleExec("SET CombatDeathLogRange \"50\"");
	
	
	
	this:RegisterEvent("VARIABLES_LOADED");	
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
	this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
	this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER");
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
	this:RegisterEvent("PLAYER_DEAD");
	this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("PARTY_MEMBERS_CHANGED");
	this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
	this:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
	this:RegisterEvent("CHAT_MSG_ADDON");
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
	this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
	
	this:RegisterForDrag();
	
	this:SetHitRectInsets(10, 10, 10, 40)--(left, right, top, bottom)
	

	SLASH_BURN1 = "/burn";
	SlashCmdList["BURN"] = function(msg)
		BurnSlash(msg);
	end	
	
	for  i = 1, 5 do
		NTTs[i] = {};
	end
	
	for i = 1, 3 do
		Burn_highTick[i] = {"",0,0};
		Burn_highTotal[i] = {"",0,0};

	end	
	
	
	BurnFrameNameTitle:SetWidth(45);
	BurnFrameTickTitle:SetWidth(30);
	BurnFrameTotalTitle:SetWidth(33);
	BurnFrameName1:SetWidth(45);
	BurnFrameTick1:SetWidth(30);
	BurnFrameTotal1:SetWidth(33);
	BurnFrameName2:SetWidth(45);
	BurnFrameTick2:SetWidth(30);
	BurnFrameTotal2:SetWidth(33);
	BurnFrameName3:SetWidth(45);
	BurnFrameTick3:SetWidth(30);
	BurnFrameTotal3:SetWidth(33);
	BurnFrameName4:SetWidth(45);
	BurnFrameTick4:SetWidth(30);
	BurnFrameTotal4:SetWidth(33);
	
	BurningName:SetWidth(100);
	BurningTickTitle:SetWidth(100);
	BurningTotalTitle:SetWidth(100);
	BurningTick:SetWidth(100);
	BurningTotal:SetWidth(100);

	
	
	
	Burn_mageList[1] = { UnitName("player"), 1 };
	
	BurnFrameNameTitle:SetText("Name:");
	BurnFrameTickTitle:SetText("Tick:");	
	BurnFrameTotalTitle:SetText("Total:");


	BurnguiMiddleCombust:SetTexCoordModifiesRect(true)
	BurnguiMiddleIgnite:SetTexCoordModifiesRect(true)
	Burn_Ignite_Splash:SetTexCoordModifiesRect(true)
	BurnguiBar:SetTexCoordModifiesRect(true);
	BurnguiMiddleCombust:SetTexCoord(0,0,0,1);
	Burn_Ignite_Splash:SetTexCoord(0,0,0,1);
	BurnguiMiddleIgnite:SetTexCoord(0,0,0,1);	
	BurnguiBar:SetTexCoord(0,0,0,1);
	BurnguiMiddleBack:SetTexCoordModifiesRect(true)
	BurnguiMiddleBack1:SetTexCoordModifiesRect(true)
	BurnguiMiddleBack2:SetTexCoordModifiesRect(true)

	

	
	this.TimeDelta1 = 0;
	this.TimeDelta2 = 0;
	this.TimeDelta3 = 0;
	this.TimeDelta4 = 0;
	this.TimeDelta5 = 0;
	this.TimeDelta6 = 0;
	BurnguiMiddleBack:SetVertexColor( 0,0,0,0.6);
	BurnguiMiddleBack1:SetVertexColor( 0,0,0,0);
	BurnguiMiddleBackmin:SetVertexColor( 0,0,0,0.5);
	BurnguiMiddleBackmin1:SetVertexColor( 0,0,0,0);	
	BurnguiMiddleBack2:SetVertexColor( 0,0,0,0);
	Burnshadow:SetVertexColor(1,1,1,0.8)
	Burnshadowmin:SetVertexColor(1,1,1,0.8)
	Burn_5_ignite:Hide();

	
	ChatFrame1:AddMessage("Burn loaded. '/burn' for options");

end

function Burn_StartDragging()
	if ( ( ( not this.isLocked ) or ( this.isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then
		this:StartMoving();
		this.isMoving = true;
	end
end

function Burn_StopDragging()
	if ( this.isMoving ) then
		this:StopMovingOrSizing();
		this.isMoving = false;
	end
end

function Burn_OnEvent()
	
	if ( event == "CHAT_MSG_ADDON" ) then
		if ( arg1 == "Burn" ) then
			if ( arg2 == "Threat Warning" ) then
				if ( Burn_igniteOn == true ) then
					Burn_warnAlpha = 1;
				end	
			end
		end

	elseif ( event == "CHAT_MSG_SPELL_SELF_DAMAGE" ) then
		if ( string.find ( arg1, "Your (.+) crits (.+) for (%d+) Fire damage%.") ) then
		_, _, spell  = string.find ( arg1, "Your (.+) crits (.+) for (%d+) Fire damage%." )
			if ( spell ~= "shoot" ) then
				if ( CombustN > 0 ) then
					CombustN=CombustN-1;
				end
		
				if ( CombustN == 2 ) then
					BurnguiMiddleCombust:SetTexCoord(0,0.60,0,1);
				elseif ( CombustN == 1 ) then
					BurnguiMiddleCombust:SetTexCoord(0,0.40,0,1);
				elseif ( CombustN == 0 ) then
					BurnguiMiddleCombust:SetTexCoord(0,0,0,1);
				end
				if ( UnitName("player") == NTTs[1][1] ) then
					Burn_critOwnerTest = 1;
				end	
				Burn_critFlash = 1;
			end	
		end
	elseif ( event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE" ) then
		if ( string.find ( arg1, "(.+)'s (.+) crits (.+) for (%d+) Fire damage%.") ) then		
			_, _, player, spell, mob, _ = string.find ( arg1, "(.+)'s (.+) crits (.+) for (%d+) Fire damage%." )
			if ( mob == UnitName("target") ) then
				if ( Burn_group == "raid" ) then
					for i = 1, 40 do
						if ( Burn_mageList[i][1] == player ) then
							BunitID = "raid" .. Burn_mageList[i][2] .. "target";
							
							
						end
					end
				end
				if ( Burn_group == "party" ) then
					for i = 1, 4 do
						if ( Burn_mageList[i][1] == player ) then
							BunitID = "party" .. Burn_mageList[i][2] .. "target";
							
							
						end
					end
				end			
				if ( Burn_group == "none" or UnitIsUnit("target", BunitID) ) then
					if ( player == NTTs[1][1] ) then
						Burn_critOwnerTest = 1;
					end
					Burn_critFlash = 1;
				end
			end
		end		
		
	elseif ( event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE"  or  event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"   ) then	
		if ( string.find ( arg1, "(.+) is afflicted by Ignite%." ) ) then
			_, _, mob = string.find ( arg1, "(.+) is afflicted by Ignite." )
			
			--check targets
			if ( mob == UnitName("target") ) then
				for i = 1,16 do
					BDTex, itest = UnitDebuff("target", i);
					if BDTex == "Interface\\Icons\\Spell_Fire_Incinerate" then
						Burn_igniteStacksUpdate = itest;
					end
				end	

				if ( Burn_igniteStacksUpdate == Burn_igniteStacks + 1 ) then 
					Burn_Timer = 4;	
					Burn_igniteSplashtimer = 1;
					Burn_Ignite_Splash:SetTexCoord(0,0.33,0,1);
					Burn_igniteOn = true;
					BurnguiMiddleIgnite:SetTexCoord(0,0.33,0,1);
					Burn_igniteStacks = 1;
				end
			end
			
		elseif ( string.find ( arg1, "(.+) is afflicted by Ignite %((%d)%)%." ) ) then
			_, _, mob, StackNumber = string.find ( arg1, "(.+) is afflicted by Ignite %((%d)%)%." )
			
			if ( mob == UnitName("target") ) then
				for i = 1,16 do
					BDTex, itest = UnitDebuff("target", i);
					if BDTex == "Interface\\Icons\\Spell_Fire_Incinerate" then
						Burn_igniteStacksUpdate = itest;
					end
				end	
				intStackNumber = StackNumber + 0;
				if ( Burn_igniteStacksUpdate == intStackNumber ) then 			
						
					Burn_igniteStacks = Burn_igniteStacksUpdate;
					Burn_igniteOn = true;
					if ( Burn_Timer < 2 ) then
						Burn_Timer = Burn_Timer + 2;	
					end
					
					Burn_igniteSplashtimer = 1;
					if ( Burn_igniteStacks == 2 ) then	
						BurnguiMiddleIgnite:SetTexCoord(0,0.44,0,1);
						Burn_Ignite_Splash:SetTexCoord(0,0.44,0,1);
					elseif ( Burn_igniteStacks == 3 ) then	
						BurnguiMiddleIgnite:SetTexCoord(0,0.55,0,1);
						Burn_Ignite_Splash:SetTexCoord(0,0.55,0,1);
					elseif ( Burn_igniteStacks == 4 ) then	
						BurnguiMiddleIgnite:SetTexCoord(0,0.66,0,1);
						Burn_Ignite_Splash:SetTexCoord(0,0.66,0,1);
					elseif ( Burn_igniteStacks == 5 ) then	
						BurnguiMiddleIgnite:SetTexCoord(0,1,0,1);
						Burn_Ignite_Splash:SetTexCoord(0,1,0,1);
						Burn_5_ignite:Show();
					end	
				end
			end
		end	
		
		if ( string.find ( arg1, "(.+) suffers (%d+) Fire damage from your Ignite%." ) ) then
			_, _, mob, tick = string.find ( arg1, "(.+) suffers (%d+) Fire damage from your Ignite%." )

			if ( mob == UnitName("target") ) then
				Burn_isTarget = false;
				for i = 1,16 do
					BDTex, itest = UnitDebuff("target", i);
					if BDTex == "Interface\\Icons\\Spell_Fire_Incinerate" then
						Burn_isTarget = true;
					end
				end
				if ( Burn_isTarget == true ) then
					Burn_total = Burn_total + tick;
					NTTs[1][1] = UnitName("player");
					NTTs[1][2] = tick+0;			
					NTTs[1][3] = Burn_total+0;
					TotalTick = TotalTick+1
					if ( Burn_infoNum == 1 ) then
						Burn_DisplayCurrent()
					end	
					Burn_igniteOn = true;
					ticked = true;
					
					Burn_buTimer = 2.5;
				end
			end	
			
		elseif ( string.find ( arg1, "(.+) suffers (%d+) Fire damage from (.+)'s Ignite%." ) ) then
			_, _, _, tick, player = string.find ( arg1, "(.+) suffers (%d+) Fire damage from (.+)'s Ignite%." )
			
			if ( mob == UnitName("target") ) then
				if ( Burn_group == "raid" ) then
					for i = 1, 40 do
						if ( Burn_mageList[i][1] == player ) then
							BunitID = "raid" .. Burn_mageList[i][2] .. "target";
							
							
						end
					end
				end
				if ( Burn_group == "party" ) then
					for i = 1, 4 do
						if ( Burn_mageList[i][1] == player ) then
							BunitID = "party" .. Burn_mageList[i][2] .. "target";
							
							
						end
					end
				end				
				
				if ( Burn_group == "none" or UnitIsUnit("target", BunitID) ) then
					Burn_total = Burn_total + tick;
					NTTs[1][1] = player;
					NTTs[1][2] = tick+0;			
					NTTs[1][3] = Burn_total+0;
					TotalTick = TotalTick+1
					if ( Burn_infoNum == 1 ) then
						Burn_DisplayCurrent()	
					end
					Burn_igniteOn = true;
					ticked = true;
					
					Burn_buTimer = 2.5;
				end
			end	
		end			
	elseif ( event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" ) then
		if ( string.find ( arg1, "Ignite fades from (.+)%." ) ) then
			_, _, mob = string.find ( arg1, "Ignite fades from (.+)%." ) 
			if ( mob == UnitName("target") ) then
				diedyet = true
				for i = 1,16 do
					BDTex, _ = UnitDebuff("target", i);
					if BDTex == "Interface\\Icons\\Spell_Fire_Incinerate" then	
						diedyet = false;						 
					end
				end
				if ( diedyet == true ) then
					Burn_IgniteOver();
				end	
			end
		end
	elseif ( event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
		if ( string.find ( arg1, "(.+) dies%." ) ) then
			_, _, mob = string.find ( arg1, "(.+) dies%." ) 				
			if ( UnitHealth("target") == 0 ) then 
				Burn_IgniteOver();
			end
		end
	elseif ( event == "PLAYER_DEAD") then
		BurnguiMiddleCombust:SetTexCoord(0,0,0,1);
		CombustN = 0;
	
	elseif ( event == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS" ) then
		if ( string.find ( arg1, "(.+) gains Combustion%." ) ) then
			Burn_alpha = Burn_alpha + 1;	
		end
	elseif ( event == "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS" ) then
		if ( string.find ( arg1, "(.+) gains Combustion%." ) ) then
			Burn_alpha = Burn_alpha + 1;	
		end
	elseif ( event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" ) then
		if ( string.find ( arg1, "You gain Combustion%." ) ) then
			Burn_alpha = Burn_alpha + 1;	
			CombustN=3;
			BurnguiMiddleCombust:SetTexCoord(0,1,0,1);
		end
	elseif ( event == "CHAT_MSG_SPELL_AURA_GONE_SELF" ) then
		if ( string.find ( arg1, "Combustion fades from you%." ) ) then
			BurnguiMiddleCombust:SetTexCoord(0,0,0,1);
			CombustN = 0;
		end
	elseif (event == "VARIABLES_LOADED") then 
		Burngui1:SetVertexColor ( Burn_r1, Burn_g1, Burn_b1,1 );
		Burnguimin1:SetVertexColor ( Burn_r1, Burn_g1, Burn_b1,1 );
		Burngui2:SetVertexColor ( Burn_r2, Burn_g2, Burn_b2,1 );
		Burnguimin2:SetVertexColor ( Burn_r2, Burn_g2, Burn_b2,1 );
		Burnguicombust:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2, Burn_alpha);
		Burnguicombustmin:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2, Burn_alpha);
		Burnguioptions:SetVertexColor( Burn_r1, Burn_g1, Burn_b1,1 );
		Burn_SetTextColor (Burn_rt, Burn_gt, Burn_bt)	
		BurnFrame:SetScale(Burn_size);
		Burn_MinMax(Burn_min)
		ChatFrame1:AddMessage(Burn_min);
		DisplayNTTs();
		if ( Burn_on == false ) then
			BurnFrame:Hide();
		elseif ( Burn_on == true ) then
			BurnFrame:Show();	
		end
		
		if ( UnitPlayerOrPetInRaid("player") == 1 ) then
			Burn_group = "raid";
			for i = 1, 40 do
				local BIDname, _, _, _, BClass, _, _, _, _ = GetRaidRosterInfo(i);
				if ( BClass == "Mage" ) then	
					Burn_mageList[i] = {BIDname, i};
				else
					Burn_mageList[i] = {"", i};
				end	
			end			
		elseif ( GetPartyMember(1) ~= nil ) then
			Burn_group = "party";
			for i = 1, 4 do
				local Burn_party = "party" .. i;
				local BClass = UnitClass(Burn_party);
				if ( BClass == "Mage" ) then	
					Burn_mageList[i] = {BIDname, i};
				else
					Burn_mageList[i] = {"", i};
				end	
			end 			
		else
			Burn_group = "none";
		end
	
	elseif ( event == "RAID_ROSTER_UPDATE" ) then
		Burn_group = "raid";
		for i = 1, 40 do
			local BIDname, _, _, _, BClass, _, _, _, _ = GetRaidRosterInfo(i);
			if ( BClass == "Mage" ) then	
				Burn_mageList[i] = {BIDname, i};
			else
				Burn_mageList[i] = {"", i};
			end	
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		if ( UnitPlayerOrPetInRaid("player") == 1 ) then
			Burn_group = "raid";
			for i = 1, 40 do
				local BIDname, _, _, _, BClass, _, _, _, _ = GetRaidRosterInfo(i);
				if ( BClass == "Mage" ) then	
					Burn_mageList[i] = {BIDname, i};
				else
					Burn_mageList[i] = {"", i};
				end	
			end			
		elseif ( GetPartyMember(1) ~= nil ) then
			Burn_group = "party";
			for i = 1, 4 do
				local Burn_party = "party" .. i;
				local BClass = UnitClass(Burn_party);
				if ( BClass == "Mage" ) then	
					Burn_mageList[i] = {BIDname, i};
				else
					Burn_mageList[i] = {"", i};
				end	
			end 			
		else
			Burn_group = "none";
		end			
	end
end



function Burn_MinMax(Burn_min)
	if ( Burn_min == false ) then
		BurnFrameNameTitle:Show();
		BurnFrameTickTitle:Show();
		BurnFrameTotalTitle:Show();
		BurnFrameName1:Show();
		BurnFrameTick1:Show();
		BurnFrameTotal1:Show();
		BurnFrameName2:Show();
		BurnFrameTick2:Show();
		BurnFrameTotal2:Show();
		BurnFrameName3:Show();
		BurnFrameTick3:Show();
		BurnFrameTotal3:Show();
		BurnFrameName4:Show();
		BurnFrameTick4:Show();
		BurnFrameTotal4:Show();
		Burngui1:Show();
		Burngui2:Show();
		Burnguicombust:Show();
		BurnguiMiddleBack:Show()
		BurnguiMiddleBack1:Show()
		BurnguiMiddleBack2:Show()
		Burnshadow:Show()
		BurnFrameWarn:Show()
		BurningName:Show()
		BurningTickTitle:Show()
		BurningTotalTitle:Show()
		BurningTick:Show()
		BurningTotal:Show()
		Burn_Crit_5_1:Show()
		Burn_Crit_5_2:Show()

		Burnshadowmin:Hide()
		BurnFrame:SetHitRectInsets(10, 10, 10, 40)--(left, right, top, bottom)
		
		
		
		
		BurnguiMiddleBackmin:Hide()
		BurnguiMiddleBackmin1:Hide()
		Burnguicombustmin:Hide();
		Burnguimin1:Hide();
		Burnguimin2:Hide();
		
	elseif ( Burn_min == true ) then
		BurnFrameNameTitle:Hide();
		BurnFrameTickTitle:Hide();
		BurnFrameTotalTitle:Hide();
		BurnFrameName1:Hide();
		BurnFrameTick1:Hide();
		BurnFrameTotal1:Hide();
		BurnFrameName2:Hide();
		BurnFrameTick2:Hide();
		BurnFrameTotal2:Hide();
		BurnFrameName3:Hide();
		BurnFrameTick3:Hide();
		BurnFrameTotal3:Hide();
		BurnFrameName4:Hide();
		BurnFrameTick4:Hide();
		BurnFrameTotal4:Hide();
		Burngui1:Hide();
		Burngui2:Hide();
		Burnguicombust:Hide();
		BurnguiMiddleBack:Hide()
		BurnguiMiddleBack1:Hide()
		BurnguiMiddleBack2:Hide()	
		Burnshadow:Hide()
		BurnFrameWarn:Hide()
		BurningName:Hide()
		BurningTickTitle:Hide()
		BurningTotalTitle:Hide()
		BurningTick:Hide()
		BurningTotal:Hide()
		Burn_Crit_5_1:Hide()
		Burn_Crit_5_2:Hide()
	
		
		Burnshadowmin:Show()
		BurnFrame:SetHitRectInsets(10, 10, 10, 70)--(left, right, top, bottom)
		
		BurnguiMiddleBackmin:Show()
		BurnguiMiddleBackmin1:Show()		
		Burnguicombustmin:Show();
		Burnguimin1:Show();
		Burnguimin2:Show();	
	end	
		
end

function Burn_Warn()
	Burn_warnAlpha = 1;
	if ( Burn_igniteOn == true ) then
		SendAddonMessage ( "Burn", "Threat Warning", "RAID" );
	end	
end



function Burn_Combust_5 ( t )
	size = 128+100*((1-t)^(1/4))
	size2 = 128+65*((1-t)^(1/4))
	alpha = (Burn_igniteStacks/5)*t
	Burn_Crit_5_1:SetVertexColor(Burn_r1, Burn_g1, Burn_b1,alpha)
	Burn_Crit_5_1:SetHeight(size);
	Burn_Crit_5_1:SetWidth(size);
	Burn_Crit_5_2:SetVertexColor(Burn_r2, Burn_g2, Burn_b2,alpha)
	Burn_Crit_5_2:SetHeight(size2);
	Burn_Crit_5_2:SetWidth(size2);
	
end


function Burn_OnUpdate(Burn_deltat)

	if ( Burn_critFlash > 0 ) then
	  	this.TimeDelta5 = this.TimeDelta5 + arg1; 	
	  	while (this.TimeDelta5 > Burn_UpdateInterval) do
	  		BurnguiMiddleBack1:SetVertexColor(Burn_r1*Burn_r2*Burn_critFlash, Burn_g1*Burn_g2*Burn_critFlash,
	  						Burn_b1*Burn_b2*Burn_critFlash, Burn_critFlash);
	  		BurnguiMiddleBackmin1:SetVertexColor(Burn_r1*Burn_r2*Burn_critFlash, Burn_g1*Burn_g2*Burn_critFlash,
	  						Burn_b1*Burn_b2*Burn_critFlash, Burn_critFlash);	
	  		Burn_critFlash = Burn_critFlash - 0.02;
	    		this.TimeDelta5 = this.TimeDelta5 - Burn_UpdateInterval;
	  	end	
	end  
	
	if ( Burn_critOwnerTest > 0 ) then
	  	this.TimeDelta6 = this.TimeDelta6 + arg1; 	
	  	while (this.TimeDelta6 > Burn_UpdateInterval) do
	  		Burn_Combust_5 ( Burn_critOwnerTest );
	  		Burn_critOwnerTest = Burn_critOwnerTest - 0.02;
	    		this.TimeDelta6 = this.TimeDelta6 - Burn_UpdateInterval;
	  	end	
	end	
	
	if ( Burn_alpha > 0 ) then
	  	this.TimeDelta1 = this.TimeDelta1 + arg1; 	
	  	while (this.TimeDelta1 > Burn_UpdateInterval) do	  	
	  		Burnguicombust:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2, Burn_alpha);
	  		Burnguicombustmin:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2, Burn_alpha);
	  		Burn_alpha = Burn_alpha - 0.005;
	    		this.TimeDelta1 = this.TimeDelta1 - Burn_UpdateInterval;
	  	end
	end 
	
	if ( Burn_warnAlpha > 0 ) then
	  	this.TimeDelta2 = this.TimeDelta2 + arg1; 	
	  	while (this.TimeDelta2 > Burn_UpdateInterval) do
	  		BurnguiMiddleBack2:SetVertexColor(Burn_warnAlpha, 0, 0, (Burn_warnAlpha));
	  		Burn_warnAlpha = Burn_warnAlpha - 0.005;
	    		this.TimeDelta2 = this.TimeDelta2 - Burn_UpdateInterval;	
	  	end
	end	
		
	if ( Burn_igniteOn == true ) then
		BurnguiMiddleBack:SetVertexColor(Burn_r1*Burn_r2/2, Burn_g1*Burn_g2/2, Burn_b1*Burn_b2/2, 0.6);
		BurnguiMiddleBackmin:SetVertexColor(Burn_r1*Burn_r2/2, Burn_g1*Burn_g2/2, Burn_b1*Burn_b2/2, 0.5);
	  	this.TimeDelta3 = this.TimeDelta3 + arg1; 	
	  	while (this.TimeDelta3 > Burn_UpdateInterval) do	  		
	  		if ( Burn_Timer < 0 ) then
	  			if ( Burn_buTimer < 0 ) then
	  				Burn_IgniteOver();
	  			end
	  		end	
	  		Burn_buTimer = Burn_buTimer - Burn_UpdateInterval;
	  		Burn_Timer = Burn_Timer - Burn_UpdateInterval;
	  		BurnguiBar:SetTexCoord(0,0.1 + (Burn_Timer/5),0,1);	  		
	    		this.TimeDelta3 = this.TimeDelta3 - Burn_UpdateInterval;
	  	end
	end  
	
	if ( Burn_igniteSplashtimer > 0 ) then
	  	this.TimeDelta4 = this.TimeDelta4 + arg1; 	
	  	while (this.TimeDelta4 > Burn_UpdateInterval) do
	  		Burn_IgniteSplash( Burn_igniteSplashtimer );
	  		Burn_igniteSplashtimer = Burn_igniteSplashtimer - 0.02;
	    		this.TimeDelta4 = this.TimeDelta4 - Burn_UpdateInterval;
	
	  	end
	end  	
		
end

function Burn_IgniteSplash (t)
	var = 1-t 
	Burn_Ignite_Splash:SetVertexColor(t,0,0,t)
	Burn_Ignite_Splash:SetHeight(128+(var*50));
end
	
	

function Burn_SetTextColor (rt, gt, bt)
	BurnFrameNameTitle:SetTextColor(rt-0.2, gt-0.2, bt-0.2);
	BurnFrameTickTitle:SetTextColor(rt-0.2, gt-0.2, bt-0.2);	
	BurnFrameTotalTitle:SetTextColor(rt-0.2, gt-0.2, bt-0.2);
	BurningName:SetTextColor(rt-0.2, gt-0.2, bt-0.2);
	Burn_5_ignite:SetVertexColor(rt-0.2, gt-0.2, bt-0.2, 0.5);
	BurnFrameName1:SetTextColor(rt, gt, bt);
	BurnFrameTick1:SetTextColor(rt, gt, bt);
	BurnFrameTotal1:SetTextColor(rt, gt, bt);
	if ( rt >= gt and rt >= bt ) then
		rti = 0.8; gti = 1; bti = 1
	elseif ( gt >= bt and gt >= rt ) then
		rti = 1; gti = 0.8; bti = 1
	elseif ( bt >= rt and bt >= gt ) then
		rti = 1; gti = 1 bti = 0.8
	end		
	BurnFrameName2:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurnFrameTick2:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurnFrameTotal2:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurningTickTitle:SetTextColor( rti*rt, gti*gt, bti*bt );	
	BurningTick:SetTextColor( rti*rt, gti*gt, bti*bt );
	if ( rt >= gt and rt >= bt ) then
		rti = 0.6; gti = 1; bti = 1
	elseif ( gt >= bt and gt >= rt ) then
		rti = 1; gti = 0.6; bti = 1
	elseif ( bt >= rt and bt >= gt ) then
		rti = 1; gti = 1 bti = 0.6
	end	
	BurnFrameName3:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurnFrameTick3:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurnFrameTotal3:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurningTotalTitle:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurningTotal:SetTextColor( rti*rt, gti*gt, bti*bt );
	if ( rt >= gt and rt >= bt ) then
		rti = 0.4; gti = 1; bti = 1
	elseif ( gt >= bt and gt >= rt ) then
		rti = 1; gti = 0.4; bti = 1
	elseif ( bt >= rt and bt >= gt ) then
		rti = 1; gti = 1 bti = 0.4
	end	

	BurnFrameName4:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurnFrameTick4:SetTextColor( rti*rt, gti*gt, bti*bt );
	BurnFrameTotal4:SetTextColor( rti*rt, gti*gt, bti*bt );	
end

function Burn_DisplayCurrent()
	BurnFrameName1:SetWidth(45);
	BurnFrameNameTitle:SetText("")
	BurnFrameTickTitle:SetText("")
	BurnFrameTotalTitle:SetText("")
	BurnFrameName1:SetText("")
	BurnFrameTick1:SetText("")
	BurnFrameTotal1:SetText("")
	BurnFrameName2:SetText("")
	BurnFrameTick2:SetText("")
	BurnFrameTotal2:SetText("")
	BurnFrameName3:SetText("")
	BurnFrameTick3:SetText("")
	BurnFrameTotal3:SetText("")
	BurnFrameName4:SetText("")
	BurnFrameTick4:SetText("")
	BurnFrameTotal4:SetText("")
	
	BurningName:SetText(NTTs[1][1]);
	BurningTickTitle:SetText("Tick x " .. TotalTick .. ":");
	BurningTotalTitle:SetText("Total:")
	BurningTick:SetText(NTTs[1][2]);
	BurningTotal:SetText(NTTs[1][3]);

end	
	

function DisplayNTTs()
	BurningName:SetText("")
	BurningTickTitle:SetText("")
	BurningTotalTitle:SetText("")
	BurningTick:SetText("")
	BurningTotal:SetText("")

	
	BurnFrameName1:SetWidth(45);
	BurnFrameNameTitle:SetText("Name:");
	BurnFrameTickTitle:SetText("Tick:");	
	BurnFrameTotalTitle:SetText("Total:");
	BurnFrameName1:SetText(NTTs[2][1]);
	BurnFrameTick1:SetText(NTTs[2][2]);
	BurnFrameTotal1:SetText(NTTs[2][3]);
	BurnFrameName2:SetText(NTTs[3][1]);
	BurnFrameTick2:SetText(NTTs[3][2]);
	BurnFrameTotal2:SetText(NTTs[3][3]);
	BurnFrameName3:SetText(NTTs[4][1]);
	BurnFrameTick3:SetText(NTTs[4][2]);
	BurnFrameTotal3:SetText(NTTs[4][3]);
	BurnFrameName4:SetText(NTTs[5][1]);
	BurnFrameTick4:SetText(NTTs[5][2]);
	BurnFrameTotal4:SetText(NTTs[5][3]);
end

function Burn_DisplayTick()
	BurnFrameName1:SetWidth(400);
	BurnFrameName1:SetText("Highest Tick:" );	
	BurnFrameTick1:SetText("");
	BurnFrameTotal1:SetText("");
	BurnFrameName2:SetText(Burn_highTick[1][1]);
	BurnFrameTick2:SetText(Burn_highTick[1][2]);
	BurnFrameTotal2:SetText(Burn_highTick[1][3]);	
	BurnFrameName3:SetText(Burn_highTick[2][1]);
	BurnFrameTick3:SetText(Burn_highTick[2][2]);
	BurnFrameTotal3:SetText(Burn_highTick[2][3]);
	BurnFrameName4:SetText(Burn_highTick[3][1]);
	BurnFrameTick4:SetText(Burn_highTick[3][2]);
	BurnFrameTotal4:SetText(Burn_highTick[3][3]);
end	

function Burn_DisplayTotal()
	BurnFrameName1:SetWidth(400);
	BurnFrameName1:SetText("Highest Total:" );
	BurnFrameTick1:SetText("");
	BurnFrameTotal1:SetText("");
	BurnFrameName2:SetText(Burn_highTotal[1][1]);
	BurnFrameTick2:SetText(Burn_highTotal[1][2]);
	BurnFrameTotal2:SetText(Burn_highTotal[1][3]);
	BurnFrameName3:SetText(Burn_highTotal[2][1]);
	BurnFrameTick3:SetText(Burn_highTotal[2][2]);
	BurnFrameTotal3:SetText(Burn_highTotal[2][3]);	
	BurnFrameName4:SetText(Burn_highTotal[3][1]);
	BurnFrameTick4:SetText(Burn_highTotal[3][2]);
	BurnFrameTotal4:SetText(Burn_highTotal[3][3]);
end	

	
function BurnCF1()
	Burn_r1, Burn_g1, Burn_b1 = ColorPickerFrame:GetColorRGB();
	Burngui1:SetVertexColor ( Burn_r1, Burn_g1, Burn_b1,1 );
	Burnguicombustmin:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2);
	Burnguimin1:SetVertexColor ( Burn_r1, Burn_g1, Burn_b1,1 );
	Burnguicombust:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2);	
	Burnguioptions:SetVertexColor( Burn_r1, Burn_g1, Burn_b1,1 );
end

function BurnCF2()
	Burn_r2, Burn_g2, Burn_b2 = ColorPickerFrame:GetColorRGB();
	Burngui2:SetVertexColor ( Burn_r2, Burn_g2, Burn_b2,1 );
	Burnguicombust:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2);
	Burnguimin2:SetVertexColor ( Burn_r2, Burn_g2, Burn_b2,1 );
	Burnguicombustmin:SetVertexColor(Burn_r1*Burn_r2, Burn_g1*Burn_g2, Burn_b1*Burn_b2);	
end

function TextCF()
	Burn_rt, Burn_gt, Burn_bt = ColorPickerFrame:GetColorRGB();
	BurnFrameName1:SetWidth(400);BurnFrameName2:SetWidth(400);BurnFrameName3:SetWidth(400);BurnFrameName4:SetWidth(400);
	BurnFrameName1:SetText("Burn by Smizzle");BurnFrameTick1:SetText("");BurnFrameTotal1:SetText("");
	BurnFrameName2:SetText("Mostly Harmless-Elune");BurnFrameTick2:SetText("");BurnFrameTotal2:SetText("");
	BurnFrameName3:SetText("Special thanks to: Dalara ");BurnFrameTick3:SetText("");BurnFrameTotal3:SetText("");
	BurnFrameName4:SetText("Maskevic, Polyjuice, Xerxes");BurnFrameTick4:SetText("");BurnFrameTotal4:SetText("");
	Burn_SetTextColor (Burn_rt, Burn_gt, Burn_bt)
end	


function BurnSlash(command)
	if ( command == "off") then
		ChatFrame1:AddMessage("Burn unloaded");
		this:UnregisterEvent("VARIABLES_LOADED");
		this:UnregisterEvent("PARTY_MEMBERS_CHANGED");
		this:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
		this:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
		this:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
		this:UnregisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
		this:UnregisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER");
		this:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
		this:UnregisterEvent("PLAYER_DEAD");
		this:UnregisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF");	
		this:UnregisterEvent("RAID_ROSTER_UPDATE");
		this:UnregisterEvent("PARTY_MEMBERS_CHANGED");
		this:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
		this:UnregisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
		this:UnregisterEvent("CHAT_MSG_ADDON");
		this:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
		this:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
		Burn_on = false
		BurnFrame:Hide();	
	elseif ( command == "minmax" ) then
		if ( Burn_min == false ) then
			Burn_min = true;
			Burn_MinMax(Burn_min)
		elseif ( Burn_min == true ) then
			Burn_min = false;
			Burn_MinMax(Burn_min)
		end		
	elseif ( command == "reset" ) then	
		BurnFrame:ClearAllPoints();
		BurnFrame:SetPoint("CENTER", "UIParent", "CENTER");
		for i = 1,4 do
			NTTs[i][1] = "";
			NTTs[i][2] = "";
			NTTs[i][3] = "";
		end	
		BurnguiMiddleCombust:SetTexCoord(0,0,0,1);
		BurnguiMiddleIgnite:SetTexCoord(0,0,0,1);	
		BurnguiBar:SetTexCoord(0,0.,0,1);
		Burn_size = 1.8;
		BurnFrame:SetScale(Burn_size);
	elseif ( command == "data" ) then
		for i = 1, 5 do
			NTTs[i][1] = "";
			NTTs[i][2] = "";
			NTTs[i][3] = "";
		end
		for i = 1, 3 do
			Burn_highTick[i][1] = "None";
			Burn_highTick[i][2] = 0;
			Burn_highTick[i][3] = 0;
			Burn_highTotal[i][1] = "None";
			Burn_highTotal[i][2] = 0;
			Burn_highTotal[i][3] = 0;
		end
		if ( Burn_infoNum == 1 ) then
			DisplayNTTs();
		elseif ( Burn_infoNum == 2 ) then
			Burn_DisplayTick();
		elseif ( Burn_infoNum == 3 ) then
			Burn_DisplayTotal();
		end
	elseif ( command == "big" ) then
		Burn_size = Burn_size + 0.1;
		BurnFrame:SetScale(Burn_size);
	elseif ( command == "small" ) then
		Burn_size = Burn_size - 0.1	
		BurnFrame:SetScale(Burn_size);
	elseif ( command == "" ) then
		if ( Burn_on == true ) then
			if ( Burnguihelp1:IsShown() ) then
				Burnguihelp1:Hide();
				Burnguihelp2:Hide();
				Burnguihelp3:Hide();
				Burnguihelp4:Hide();
			else						
				Burnguihelp1:Show();
				Burnguihelp2:Show();
				Burnguihelp3:Show();
				Burnguihelp4:Show();
				ChatFrame1:AddMessage("/burn       : toggles help and turns Burn on");
				ChatFrame1:AddMessage("/burn reset : resets Burns position");
				ChatFrame1:AddMessage("/burn data  : resets Burns data");
				ChatFrame1:AddMessage("/burn big   : increases Burn size");
				ChatFrame1:AddMessage("/burn small : decreases Burn size");
				ChatFrame1:AddMessage("/burn off   : close Burn");
			end
		else
			ChatFrame1:AddMessage("Burn loaded");
			this:RegisterEvent("VARIABLES_LOADED");	
			this:RegisterEvent("PARTY_MEMBERS_CHANGED");
			this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
			this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");
			this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
			this:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH");
			this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER");
			this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
			this:RegisterEvent("PLAYER_DEAD");
			this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF");
			this:RegisterEvent("RAID_ROSTER_UPDATE");
			this:RegisterEvent("PARTY_MEMBERS_CHANGED");
			this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
			this:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE");
			this:RegisterEvent("CHAT_MSG_ADDON");
			this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
			this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
			BurnFrame:Show();
			Burn_on = true;		
		end	
	end
end	

function Burn_CycleInfo ()
	Burn_infoNum = Burn_infoNum + 1;
	if ( Burn_infoNum == 4 ) then
		Burn_infoNum = 1;
	end
	if ( Burn_infoNum == 1 ) then
		DisplayNTTs();
	elseif ( Burn_infoNum == 2 ) then
		Burn_DisplayTick();
	elseif ( Burn_infoNum == 3 ) then
		Burn_DisplayTotal();
	end
end	
	
	


function Burn_IgniteOver()

	
	if ( Burn_igniteOn == true ) then
		if ( ticked == true ) then
			if ( NTTs[1][2] > Burn_highTick[1][2] ) then
				for i = 1, 2 do
					Burn_highTick[4-i][1] = Burn_highTick[3-i][1]
					Burn_highTick[4-i][2] = Burn_highTick[3-i][2]
					Burn_highTick[4-i][3] = Burn_highTick[3-i][3]
				end	
				Burn_highTick[1][1] = NTTs[1][1];
				Burn_highTick[1][2] = NTTs[1][2];
				Burn_highTick[1][3] = NTTs[1][3];
			elseif ( NTTs[1][2] > Burn_highTick[2][2] ) then
				Burn_highTick[3][1] = Burn_highTick[2][1]
				Burn_highTick[3][2] = Burn_highTick[2][2]
				Burn_highTick[3][3] = Burn_highTick[2][3]
				Burn_highTick[2][1] = NTTs[1][1];
				Burn_highTick[2][2] = NTTs[1][2];
				Burn_highTick[2][3] = NTTs[1][3];
			elseif 	( NTTs[1][2] > Burn_highTick[3][2] ) then
				Burn_highTick[3][1] = NTTs[1][1];
				Burn_highTick[3][2] = NTTs[1][2];
				Burn_highTick[3][3] = NTTs[1][3];
			end	

			if ( NTTs[1][3] > Burn_highTotal[1][3] ) then
				for i = 1, 2 do
					Burn_highTotal[4-i][1] = Burn_highTotal[3-i][1]
					Burn_highTotal[4-i][2] = Burn_highTotal[3-i][2]
					Burn_highTotal[4-i][3] = Burn_highTotal[3-i][3]
				end
				Burn_highTotal[1][1] = NTTs[1][1];
				Burn_highTotal[1][2] = NTTs[1][2];
				Burn_highTotal[1][3] = NTTs[1][3];
			elseif ( NTTs[1][3] > Burn_highTotal[2][3] ) then
				Burn_highTotal[3][1] = Burn_highTotal[2][1]
				Burn_highTotal[3][2] = Burn_highTotal[2][2]
				Burn_highTotal[3][3] = Burn_highTotal[2][3]
				Burn_highTotal[2][1] = NTTs[1][1];
				Burn_highTotal[2][2] = NTTs[1][2];
				Burn_highTotal[2][3] = NTTs[1][3];
			elseif 	( NTTs[1][3] > Burn_highTotal[3][3] ) then
				Burn_highTotal[3][1] = NTTs[1][1];
				Burn_highTotal[3][2] = NTTs[1][2];
				Burn_highTotal[3][3] = NTTs[1][3];
			end	
			
		
			for i = 0,3 do
				NTTs[5-i][1] = NTTs[4-i][1];
				NTTs[5-i][2] = NTTs[4-i][2];
				NTTs[5-i][3] = NTTs[4-i][3];
			end
			NTTs[1][1] ="";
			NTTs[1][2] ="";
			NTTs[1][3] ="";
			ticked = false;
			TotalTick = 0
		end	
		Burn_igniteOn = false;
	end
	BurnguiMiddleBack:SetVertexColor(0, 0, 0, 0.6);
	BurnguiMiddleBackmin:SetVertexColor(0, 0, 0, 0.5);
	BurnguiBar:SetTexCoord(0,0,0,1);
	BurnguiBar:SetVertexColor(1,1,1,1);
	BurnguiMiddleIgnite:SetTexCoord(0,0,0,1);
	Burn_Timer = 0;
	if ( Burn_infoNum == 1 ) then
		DisplayNTTs();
	elseif ( Burn_infoNum == 2 ) then
		Burn_DisplayTick();
	elseif ( Burn_infoNum == 3 ) then
		Burn_DisplayTotal();
	end
	Burn_total = 0;
	Burn_igniteStacks = 0;
	Burn_5_ignite:Hide();
end	


	