local mainTankLastStatus = 0
local mainAssistLastStatus = 0
local tankErrorMessage = false
local addonToggle = true
local addonDebug = false

local function ToggleOops(msg, editbox)
    if addonToggle == true then
        addonToggle = false
        print("Addon Disabled")
    else
        addonToggle = true
        print("Addon Enabled")
    end
end

local function ToggleDebug(msg, editbox)
    if addonDebug == true then
        addonDebug = false
        print("Debug Mode Disabled")
    else
        addonDebug = true
        print("Debug Mode Enabled")
    end
end
  
SLASH_TOGGLEOOPS1, SLASH_TOGGLEOOPS2 = '/oopstog', '/oopstoggle'
SLASH_TOGGLEDEBUG1 = '/oopsdebug'

SlashCmdList["TOGGLEOOPS"] = ToggleOops
SlashCmdList["TOGGLEDEBUG"] = ToggleDebug


local function eventHandler(self, event, ...)
    
    -- Checks that the player is both in a raid group and is the raid leader
    if not (UnitInRaid("player") == nil) and (select(2, GetRaidRosterInfo(UnitInRaid("player")))) == 2 and (addonToggle == true) then
        -- Fires whenever the threat table is updated
        if event == "UNIT_THREAT_LIST_UPDATE" then
            local mainTankID = GetPartyAssignment("MAINTANK")
            local mainAssistID = GetPartyAssignment("MAINASSIST")

            -- Check both main and offtanks are assigned
            if not (mainTankID == nil or mainAssistID == nil) then

                local mainTankStatus = UnitThreatSituation("raid" .. mainTankID)
                local mainAssistStatus = UnitThreatSituation("raid" .. mainAssistID)

                -- Check status of main tank
                if (mainTankLastStatus == 3 or mainTankLastStatus == 2) and (mainTankStatus == 0 or mainTankStatus == 1) then

                    if addonDebug == true then
                        print("Main tank lost aggro")
                    end

                    for i = 1, GetNumGroupMembers()
                    do
                        if (UnitThreatSituation("raid" .. i) == 3 or UnitThreatSituation("raid" .. i) == 2) and i ~= mainAssistID then
                            SendChatMessage("<Oops> " .. (select(1,GetRaidRosterInfo(i))) .. " pulled the boss!", "RAID_WARNING", nil)
                        end 
                    end

                elseif(mainTankLastStatus == 0 or mainTankLastStatus == 1) and (mainTankStatus == 2 or mainTankStatus == 3) and addonDebug == true then
                    print("Main tank took aggro")
                end
                
                mainTankLastStatus = mainTankStatus


                --Check status of main assist
                if (mainAssistLastStatus == 3 or mainAssistLastStatus == 2) and (mainAssistStatus == 0 or mainAssistStatus == 1) then

                    if addonDebug == true then
                        print("Assist tank lost aggro")
                    end

                    for i = 1, GetNumGroupMembers()
                    do
                        if (UnitThreatSituation("raid" .. i) == 3 or UnitThreatSituation("raid" .. i) == 2) and i ~= mainTankID then
                            SendChatMessage("<Oops> " .. (select(1,GetRaidRosterInfo(i))) .. " pulled the boss!", "RAID_WARNING", nil)
                        end 
                    end

                elseif(mainAssistLastStatus == 0 or mainAssistLastStatus == 1) and (mainAssistStatus == 2 or mainAssistStatus == 3) and addonDebug == true then
                    print("Main assist took aggro")
                end

                mainAssistLastStatus = mainAssistStatus

            else
                if not tankErrorMessage then
                    if mainTankID == nil and mainAssistID == nil then
                        print("Please assign both a main and assist tank.")
                    elseif mainAssistID == nil then
                        print("Please assign an assist tank.")
                    else
                        print("Please assign a main tank.")
                    end
                end

                tankErrorMessage = true
            end

        -- Fires when player enters combat    
        elseif event == "PLAYER_REGEN_DISABLED" then
            tankErrorMessage = false
        end
    end
end

local frame1 = CreateFrame("Frame")
frame1:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame1:RegisterEvent("PLAYER_REGEN_DISABLED")
frame1:SetScript("OnEvent", eventHandler)