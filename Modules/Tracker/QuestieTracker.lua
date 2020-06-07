---@class QuestieTracker
QuestieTracker = QuestieLoader:CreateModule("QuestieTracker")
local _QuestieTracker = QuestieTracker.private
-------------------------
--Import modules.
-------------------------
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule("QuestieLib")
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer")
---@type QuestieOptions
local QuestieOptions = QuestieLoader:ImportModule("QuestieOptions")
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule("QuestieJourney")
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")
---@type QuestieQuestTimers
local QuestieQuestTimers = QuestieLoader:ImportModule("QuestieQuestTimers")
---@type QuestieCombatQueue
local QuestieCombatQueue = QuestieLoader:ImportModule("QuestieCombatQueue")

-- Local Vars
local trackerLineCount = 60
local trackerLineWidth = 1
local trackerSpaceBuffer = 1
local trackerFontSizeHeader = 1
local trackerFontSizeZone = 1
local trackerFontSizeQuest = 1
local trackerFontSizeObjective = 1
local lineIndex = 0
local buttonIndex = 0
local lastAQW = GetTime()
local durabilityInitialPosition = nil
local LSM30 = LibStub("LibSharedMedia-3.0", true)

-- Private Global Vars
_QuestieTracker.LineFrames = {}
_QuestieTracker.ItemButtons = {}
_QuestieTracker.FadeTickerValue = 0
_QuestieTracker.FadeTickerDirection = false
_QuestieTracker.IsFirstRun = true
_QuestieTracker.trackerFontSize = 1
_QuestieTracker.trackerSpaceBuffer = 1
_QuestieTracker.trackerFontSizeHeader = 1
_QuestieTracker.trackerFontSizeZone = 1
_QuestieTracker.trackerFontSizeQuest = 1
_QuestieTracker.trackerFontSizeObjective = 1
_QuestieTracker.QuestFrameIndent = 1

-- Forward declaration
local _OnClick, _OnEnter, _OnLeave
local _AQW_Insert, _RemoveQuestWatch
local _PlayerPosition, _QuestProximityTimer
local _GetDistanceToClosestObjective, _GetContinent

function QuestieTracker:Initialize()
    if QuestieTracker.started or (not Questie.db.global.trackerEnabled) then
        return
    end
    if (not Questie.db.char.TrackerHiddenQuests) then
        Questie.db.char.TrackerHiddenQuests = {}
    end
    if (not Questie.db.char.TrackerHiddenObjectives) then
        Questie.db.char.TrackerHiddenObjectives = {}
    end
    if (not Questie.db.char.TrackedQuests) then
        Questie.db.char.TrackedQuests = {}
    end
    if (not Questie.db.char.AutoUntrackedQuests) then
        Questie.db.char.AutoUntrackedQuests = {}
    end
    if (not Questie.db.char.collapsedZones) then
        Questie.db.char.collapsedZones = {}
    end
    if (not Questie.db.char.collapsedQuests) then
        Questie.db.char.collapsedQuests = {}
    end
    if (not Questie.db[Questie.db.global.questieTLoc].TrackerWidth) then
        Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0
    end
    if (not Questie.db[Questie.db.global.questieTLoc].trackerSetpoint) then
        Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"
    end

    -- Create tracker frames and assign them to a var
    _QuestieTracker.baseFrame = _QuestieTracker:CreateBaseFrame()
    _QuestieTracker.activeQuestsHeader = _QuestieTracker:CreateActiveQuestsHeader()
    _QuestieTracker.trackedQuestsFrame = _QuestieTracker:CreateTrackedQuestsFrame()

    -- Quest and Item button tables
    _QuestieTracker:CreateTrackedQuestItemButtons()
    _QuestieTracker:CreateTrackedQuestButtons()

    -- Tracker right click menu
    _QuestieTracker.menuFrame = LQuestie_Create_UIDropDownMenu("QuestieTrackerMenuFrame", UIParent)

    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    -- Atach durability frame to the tracker if shown and Sticky Durability Frame is enabled
    if not durabilityInitialPosition then
        durabilityInitialPosition = {DurabilityFrame:GetPoint()}
    end

    C_Timer.After(0.2, function()

        -- Hide the durability frame
        DurabilityFrame:Hide()

        -- Load Objective Sorting and Tracker Layout Vars
        _QuestieTracker:UpdateLayout()
    end)

    -- Santity checks and settings applied at login
    C_Timer.After(0.4, function()
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation == nil then return end

        -- Make sure the saved tracker location cords are on the players screen
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and Questie.db[Questie.db.global.questieTLoc].TrackerLocation[2] and Questie.db[Questie.db.global.questieTLoc].TrackerLocation[2] == "MinimapCluster" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[2] == "UIParent" then
            local baseFrame = QuestieTracker:GetBaseFrame()
            local verifyBaseFrame = {unpack(Questie.db[Questie.db.global.questieTLoc].TrackerLocation)}

            -- Max X values
            local maxLeft = -GetScreenWidth()/2
            if verifyBaseFrame[4] < 0 and verifyBaseFrame[4] < maxLeft then
               verifyBaseFrame[4] = maxLeft
            end

            local maxRight = GetScreenWidth()/2
            if verifyBaseFrame[4] > 0 and verifyBaseFrame[4] > maxRight then
                verifyBaseFrame[4] = maxRight
            end

            -- Max Y values
            local maxBottom = -GetScreenHeight()/2
            if verifyBaseFrame[5] < 0 and verifyBaseFrame[5] < maxBottom then
                verifyBaseFrame[5] = maxBottom
            end

            local maxTop = GetScreenHeight()/2
            if verifyBaseFrame[5] > 0 and verifyBaseFrame[5] > maxTop then
                verifyBaseFrame[5] = maxTop
            end

            -- Just in case we're in combat upon login - yeah, like that doesn't happen.
            QuestieCombatQueue:Queue(function()
                baseFrame:ClearAllPoints()
                baseFrame:SetPoint(unpack(verifyBaseFrame))
                verifyBaseFrame = nil
            end)
        end
    end)

    C_Timer.After(2.0, function()

        -- This is the best way to not check 19238192398 events which might reset the position of the DurabilityFrame
        hooksecurefunc("UIParent_ManageFramePositions", QuestieTracker.MoveDurabilityFrame)

        -- Attach DurabilityFrame to tracker
        DurabilityFrame:Show()
        QuestieTracker:MoveDurabilityFrame()

        -- Font's and cooldowns can occationally not apply upon login
        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end)
end

function _QuestieTracker:UpdateLayout()
    _QuestieTracker.trackerFontSize = math.max(Questie.db.global.trackerFontSizeQuest, Questie.db.global.trackerFontSizeObjective)
    _QuestieTracker.trackerSpaceBuffer = trackerFontSizeQuest+2+trackerFontSizeObjective

    trackerSpaceBuffer = _QuestieTracker.trackerSpaceBuffer

    trackerFontSizeHeader = Questie.db.global.trackerFontSizeHeader
    trackerFontSizeZone = Questie.db.global.trackerFontSizeZone
    trackerFontSizeQuest = Questie.db.global.trackerFontSizeQuest
    trackerFontSizeObjective = Questie.db.global.trackerFontSizeObjective

    _QuestieTracker.QuestFrameIndent = _QuestieTracker.trackerFontSize*2.75

    _QuestieTracker.trackerFontSizeHeader = trackerFontSizeHeader*2.75
    _QuestieTracker.trackerFontSizeZone = trackerFontSizeZone*2.75
    _QuestieTracker.trackerFontSizeQuest = trackerFontSizeQuest*2.75
    _QuestieTracker.trackerFontSizeObjective = trackerFontSizeObjective*2.75
end

function _QuestieTracker:CreateBaseFrame()
    local frm = CreateFrame("Frame", "Questie:BaseFrame", UIParent)
    frm:SetWidth(1)
    frm:SetHeight(1)

    frm:EnableMouse(true)
    frm:SetMovable(true)
    frm:SetResizable(true)
    frm:SetMinResize(1, 1)

    frm:SetScript("OnMouseDown", _QuestieTracker.OnDragStart)
    frm:SetScript("OnMouseUp", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

    frm:SetBackdrop( {
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    frm:SetBackdropColor(0, 0, 0, 0)
    if Questie.db.global.trackerBorderEnabled then
        frm:SetBackdropBorderColor(1, 1, 1, 0)
    end

    frm.Update = function(self)
        if Questie.db.char.isTrackerExpanded then
            if Questie.db.global.trackerBackdropEnabled then
                if not Questie.db.global.trackerBackdropFader then
                    _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
                    if Questie.db.global.trackerBorderEnabled then
                        _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
                    end
                end

            else
                _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
                _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
            end

        else
            _QuestieTracker.baseFrame.sizer:SetAlpha(0)
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, 0)
            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, 0)
        end

        -- Enables Click-Through when the tracker is locked
        if IsControlKeyDown() or not Questie.db.global.trackerLocked then
            self:SetMovable(true)
            QuestieCombatQueue:Queue(function(self)
                if IsMouseButtonDown() then
                    return
                end
                self:EnableMouse(true)
                self:SetResizable(true)
            end, self)

        else
            self:SetMovable(false)
            QuestieCombatQueue:Queue(function(self)
                if IsMouseButtonDown() then
                    return
                end
                self:EnableMouse(false)
                self:SetResizable(false)
            end, self)
        end
    end

    local sizer = CreateFrame("Frame", nil, frm)
    sizer:SetPoint("BOTTOMRIGHT", 0, 0)
    sizer:SetWidth(25)
    sizer:SetHeight(25)
    sizer:SetAlpha(0)

    sizer:EnableMouse()
    sizer:SetFrameStrata("MEDIUM")

    sizer:SetScript("OnMouseDown", _QuestieTracker.OnResizeStart)
    sizer:SetScript("OnMouseUp", _QuestieTracker.OnResizeStop)
    sizer:SetScript("OnEnter", _OnEnter)
    sizer:SetScript("OnLeave", _OnLeave)

    frm.sizer = sizer

    local line1 = sizer:CreateTexture(nil, "BACKGROUND")
    line1:SetWidth(14)
    line1:SetHeight(14)
    line1:SetPoint("BOTTOMRIGHT", -4, 4)
    line1:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    local x = 0.1 * 14/17
    line1:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    local line2 = sizer:CreateTexture(nil, "BACKGROUND")
    line2:SetWidth(11)
    line2:SetHeight(11)
    line2:SetPoint("BOTTOMRIGHT", -4, 4)
    line2:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    local x = 0.1 * 11/17
    line2:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    local line3 = sizer:CreateTexture(nil, "BACKGROUND")
    line3:SetWidth(8)
    line3:SetHeight(8)
    line3:SetPoint("BOTTOMRIGHT", -4, 4)
    line3:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    local x = 0.1 * 8/17
    line3:SetTexCoord(1/32 - x, 0.5, 1/32, 0.5 + x, 1/32, 0.5 - x, 1/32 + x, 0.5)

    if Questie.db[Questie.db.global.questieTLoc].TrackerLocation then
        -- we need to pcall this because it can error if something like MoveAnything is used to move the tracker
        local result, error = pcall(frm.SetPoint, frm, unpack(Questie.db[Questie.db.global.questieTLoc].TrackerLocation))

        if not result then
            Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
            print(QuestieLocale:GetUIString("TRACKER_INVALID_LOCATION"))

            if QuestWatchFrame then
                local result, error = pcall(frm.SetPoint, frm, unpack({QuestWatchFrame:GetPoint()}))
                Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"
                if not result then
                    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                    _QuestieTracker:SetSafePoint(frm)
                end
            else
                _QuestieTracker:SetSafePoint(frm)
            end
        end

    else
        if QuestWatchFrame then
            local result, error = pcall(frm.SetPoint, frm, unpack({QuestWatchFrame:GetPoint()}))
            Questie.db[Questie.db.global.questieTLoc].trackerSetpoint = "AUTO"

            if not result then
                Questie.db[Questie.db.global.questieTLoc].TrackerLocation = nil
                print(QuestieLocale:GetUIString("TRACKER_INVALID_LOCATION"))
                _QuestieTracker:SetSafePoint(frm)
            end
        else
            _QuestieTracker:SetSafePoint(frm)
        end
    end

    frm:Hide()

    return frm
end

function _QuestieTracker:CreateActiveQuestsHeader()
    local _, numQuests = GetNumQuestLogEntries()
    local frm = CreateFrame("Button", "Questie:ActiveQuestsHeader", _QuestieTracker.baseFrame)

    frm.label = frm:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frm.label:SetPoint("TOPLEFT", frm, "TOPLEFT", 18, 0)
    frm:SetWidth(frm.label:GetUnboundedStringWidth())
    frm:SetHeight(trackerFontSizeHeader)

    -- Used for debugging purposes (can remove prior to v6.0 release)
    --frm:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background"})
    --frm:SetBackdropColor(0, 0, 0, 1)

    if Questie.db.global.trackerHeaderAutoMove then
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
            frm:SetPoint("BOTTOMLEFT", _QuestieTracker.baseFrame, "BOTTOMLEFT", trackerSpaceBuffer/2.6, 10)
        else
            frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer/2.6, -10)
        end
    else
        frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer/2.6, -10)
    end

    frm.Update = function(self)
        if Questie.db.global.trackerHeaderEnabled then
            local _, activeQuests = GetNumQuestLogEntries()
            self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontHeader) or STANDARD_TEXT_FONT, trackerFontSizeHeader)
            self.label:SetText(QuestieLocale:GetUIString("TRACKER_ACTIVE_QUESTS") .. tostring(activeQuests) .. "/20")
            self.label:SetPoint("TOPLEFT", self, "TOPLEFT", 18, 0)
            self.label:Show()

            self:SetWidth(self.label:GetUnboundedStringWidth())
            self:SetHeight(trackerFontSizeHeader)

            self:ClearAllPoints()
            if Questie.db.global.trackerHeaderAutoMove then
                if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
                    self:SetPoint("BOTTOMLEFT", _QuestieTracker.baseFrame, "BOTTOMLEFT", trackerSpaceBuffer/2.6, 10)
                else
                    self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer/2.6, -10)
                end
            else
                self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer/2.6, -10)
            end
            _QuestieTracker.baseFrame:SetMinResize(trackerSpaceBuffer + self.label:GetUnboundedStringWidth(), trackerSpaceBuffer)
        else
            self.label:Hide()
            _QuestieTracker.baseFrame:SetMinResize(trackerSpaceBuffer, trackerSpaceBuffer)
        end
    end

    frm.SetMode = function(self, mode)
        if mode ~= self.mode then
            self.mode = mode
        end
    end

    if Questie.db.char.isTrackerExpanded then
        frm:SetMode(1)
    else
        frm:SetMode(0)
    end

    frm:EnableMouse(true)

    frm:RegisterForDrag("LeftButton")
    frm:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    frm:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
    frm:RegisterEvent("BANKFRAME_CLOSED")

    frm:SetScript("OnClick", function(self)
        if InCombatLockdown() then
            return
        end
        if self.mode == 1 then
            self:SetMode(0)
            Questie.db.char.isTrackerExpanded = false
            if Questie.db.global.stickyDurabilityFrame then
                DurabilityFrame:Hide()
            end

        else
            self:SetMode(1)
            Questie.db.char.isTrackerExpanded = true
            if Questie.db.global.stickyDurabilityFrame then
                DurabilityFrame:Show()
                QuestieTracker:MoveDurabilityFrame()
                QuestieTracker:ResetLinesForChange()
                QuestieTracker:Update()
            end

            _QuestieTracker.baseFrame.sizer:SetAlpha(1)
            _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, Questie.db.global.trackerBackdropAlpha)
            if Questie.db.global.trackerBorderEnabled then
                _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, Questie.db.global.trackerBackdropAlpha)
            end
        end

        QuestieTracker:Update()
    end)

    frm:SetScript("OnEvent", function(self, event, ...)
        if (event == "BAG_NEW_ITEMS_UPDATED" or event == "BANKFRAME_CLOSED") then
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end
    end)

    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

    -- Questie Icon
    local questieIcon = CreateFrame("Button", nil, frm)
    questieIcon:SetPoint("TOPLEFT", frm, "TOPLEFT", 0, 2)
    questieIcon:SetWidth(16)
    questieIcon:SetHeight(16)

    local texture = questieIcon:CreateTexture(nil, "OVERLAY", nil, 0)
    texture:SetWidth(16)
    texture:SetHeight(16)
    texture:SetPoint("TOPLEFT", 0, 0)
    texture:SetTexture(ICON_TYPE_COMPLETE)

    questieIcon:EnableMouse(true)
    questieIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    questieIcon:SetScript("OnClick", function (self, button)
        print("OnClick")
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                QuestieQuest:ToggleNotes(not Questie.db.char.enabled);

                -- CLose config window if it's open to avoid desyncing the Checkbox
                QuestieOptions:HideFrame();
                return;
            elseif IsControlKeyDown() then
                QuestieQuest:SmoothReset()
                return
            end

            if InCombatLockdown() then
                QuestieOptions:HideFrame()
            else
                QuestieOptions:OpenConfigWindow()
            end

            if QuestieJourney:IsShown() then
                QuestieJourney.ToggleJourneyWindow();
            end
            return;

        elseif button == "RightButton" then
            if not IsModifierKeyDown() then
                -- CLose config window if it's open to avoid desyncing the Checkbox
                QuestieOptions:HideFrame();

                QuestieJourney.ToggleJourneyWindow();
                return;
            elseif IsControlKeyDown() then
                Questie.db.profile.minimap.hide = true;
                Questie.minimapConfigIcon:Hide("Questie");
                return;
            end
        end
    end)

    questieIcon:SetScript("OnEnter", function (self)
        print("OnEnter")
        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Questie ".. QuestieLib:GetAddonVersionString(), 1, 1, 1)
        GameTooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString("ICON_LEFT_CLICK") , "gray") .. ": " .. QuestieLocale:GetUIString("ICON_TOGGLE"))
        GameTooltip:AddLine(Questie:Colorize(QuestieLocale:GetUIString("ICON_RIGHT_CLICK") , "gray") .. ": " .. QuestieLocale:GetUIString("ICON_JOURNEY"))
        GameTooltip:AddLine(Questie:Colorize("Left-Click-Hold" , "gray") .. ": " .. "Drag while Unlocked")
        GameTooltip:AddLine(Questie:Colorize("CTRL-Left-Click-Hold", "gray") .. ": " .. "Drag while Locked")
        GameTooltip:Show()

        _OnEnter(self)
    end)

    questieIcon:SetScript("OnLeave", function (self)
        print("OnLeave")
        if GameTooltip:IsShown() then
            GameTooltip:Hide()
        end

        _OnLeave(self)
    end)

    frm.questieIcon = questieIcon

    frm:Show()

    return frm
end

function _QuestieTracker:CreateTrackedQuestsFrame()
    local frm = CreateFrame("Frame", "Questie:TrackedQuestsFrame", _QuestieTracker.baseFrame)
    frm:SetWidth(1)
    frm:SetHeight(1)

    if Questie.db.global.trackerHeaderEnabled then
        if Questie.db.global.trackerHeaderAutoMove then
            if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
                -- Auto move tracker header to the bottom
                frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -10)
            else
                -- Auto move tracker header to the top
                frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -26)
            end
        else
            -- No Automove. Tracker header always up top
            frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -26)
        end
    else
        -- No header. TrackedQuestsFrame always up top
        frm:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -10)
    end

    frm.Update = function(self)
        self:ClearAllPoints()
        if Questie.db.global.trackerHeaderEnabled then
            if Questie.db.global.trackerHeaderAutoMove then
                if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
                    -- Auto move tracker header to the bottom
                    self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -10)
                else
                    -- Auto move tracker header to the top
                    self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -26)
                end
            else
                -- No Automove. Tracker header always up top
                self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -26)
            end
        else
            -- No header. TrackedQuestsFrame always up top
            self:SetPoint("TOPLEFT", _QuestieTracker.baseFrame, "TOPLEFT", trackerSpaceBuffer*1.625, -10)
        end
    end

    frm:EnableMouse(true)
    frm:RegisterForDrag("LeftButton")

    frm:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
    frm:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
    frm:SetScript("OnEnter", _OnEnter)
    frm:SetScript("OnLeave", _OnLeave)

    frm:Hide()

    return frm
end

function _QuestieTracker:CreateTrackedQuestItemButtons()
    -- create buttons for quest items
    for i = 1, 20 do
        local buttonName = "QuestieItemButton"..i
        local btn = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
        local cooldown = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
        btn.range = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
        btn.count = btn:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
        btn:SetAttribute("type1", "item")
        btn:SetAttribute("type2", "stop")
        btn:Show()

        btn.SetItem = function(self, quest, size)
            local validTexture = nil
            for bag = 0 , 5 do -- maybe keyring still acts like a bag
                for slot = 0 , 24 do
                    local texture, count, locked, quality, readable, lootable, link, filtered, noValue, itemID = GetContainerItemInfo(bag, slot)
                    if quest.sourceItemId == itemID then
                        validTexture = texture
                        itemID = tonumber(itemID)
                        break
                    end
                end
            end

            if validTexture then
                self.itemID = quest.sourceItemId
                self.questID = quest.Id
                self.charges = GetItemCount(self.itemID, nil, true)
                self.rangeTimer = -1

                self:SetAttribute("item", "item:" .. tostring(self.itemID))
                self:SetNormalTexture(validTexture)
                self:SetPushedTexture(validTexture)
                self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                self:SetSize(size, size)

                self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

                self:HookScript("OnClick", self.OnClick)
                self:SetScript("OnEvent", self.OnEvent)
                self:SetScript("OnShow", self.OnShow)
                self:SetScript("OnHide", self.OnHide)
                self:SetScript("OnEnter", self.OnEnter)
                self:SetScript("OnLeave", self.OnLeave)

                -- Cooldown Updates
                cooldown:ClearAllPoints()
                cooldown:SetSize(size-4, size-4)
                cooldown:SetPoint("CENTER", self, "CENTER", 0, 0)
                cooldown:Hide()

                -- Range Updates
                self.range:SetText("●")
                self.range:SetPoint("TOPRIGHT", self, "TOPRIGHT", 3, 0)
                self.range:Hide()

                -- Charges Updates
                self.count:Hide()
                self.count:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontSizeObjective), trackerSpaceBuffer*0.40)
                if self.charges > 1 then
                    self.count:SetText(self.charges)
                    self.count:Show()
                end
                self.count:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 3)

                self.UpdateButton(self)

                return true
            end

            return false
        end

        btn.UpdateButton = function(self)
            if not self.itemID or not self:IsVisible() then
                return
            end

            local start, duration, enabled = GetItemCooldown(self.itemID)

            if enabled and duration > 3 and self.IsOnCoolDown ~= true then
                cooldown:Show()
                cooldown:SetCooldown(start, duration)
            else
                cooldown:Hide()
            end
        end

        btn.OnClick = function(self, button)
            if InCombatLockdown() then
                return
            end

            if button == "LeftButton" then
                return
            end

            if button == "RightButton" then
                ClearCursor()
                if self.questID then
                    if Questie.db.char.collapsedQuests[self.questID] ~= true then
                        Questie.db.char.collapsedQuests[self.questID] = true
                        QuestieTracker:ResetLinesForChange()
                        QuestieTracker:Update()
                    end
                else

                    return
                end
            end
        end

        btn.OnEvent = function(self, event, ...)
            if (event == "PLAYER_TARGET_CHANGED") then
                self.rangeTimer = -1

            elseif (event == "BAG_UPDATE_COOLDOWN") then
                self.UpdateButton(self)
            end
        end

        btn.OnUpdate = function(self, elapsed)
            if not self.itemID or not self:IsVisible() then
                return
            end

            local valid = nil
            local rangeTimer = self.rangeTimer

            if UnitExists("target") then

                if not self.itemName then
                    self.itemName = GetItemInfo(self.itemID)
                end

                if (rangeTimer) then
                    rangeTimer = rangeTimer - elapsed

                    if (rangeTimer <= 0) then
                        local charges = GetItemCount(self.itemID, nil, true)

                        if (not charges or charges ~= self.charges) then
                            return
                        end

                        valid = IsItemInRange(self.itemName, "target")

                        if valid == false then
                            self.range:SetVertexColor(1.0, 0.1, 0.1)
                            self.range:Show()

                        elseif valid == true then
                            self.range:SetVertexColor(0.6, 0.6, 0.6)
                            self.range:Hide()
                        end

                        rangeTimer = 0.3
                    end

                    self.rangeTimer = rangeTimer
                end
            end
        end

        btn.OnShow = function(self)
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterEvent("BAG_UPDATE_COOLDOWN")
        end

        btn.OnHide = function(self)
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        end

        btn.OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink("item:"..tostring(self.itemID)..":0:0:0:0:0:0:0")
            GameTooltip:Show()

            _OnEnter(self)
        end

        btn.OnLeave = function(self)
            GameTooltip:Hide()

            _OnLeave(self)
        end

        btn.FakeHide = function(self)
            self:RegisterForClicks(nil)
            self:SetScript("OnEnter", nil)
            self:SetScript("OnLeave", nil)

            self:SetNormalTexture(nil)
            self:SetPushedTexture(nil)
            self:SetHighlightTexture(nil)
        end

        btn:HookScript("OnUpdate", btn.OnUpdate)

        btn:FakeHide()

        _QuestieTracker.ItemButtons[i] = btn
        _QuestieTracker.ItemButtons[i]:Hide()
        --_QuestieTracker.ItemButtons[i]:SetAlpha(0)
    end
end

function _QuestieTracker:CreateTrackedQuestButtons()
    -- create buttons for quests
    local lastFrame = nil
    for i = 1, trackerLineCount do
        local btn = CreateFrame("Button", "QuestieQuestButton"..i, _QuestieTracker.trackedQuestsFrame)
        btn.label = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        btn.label:SetJustifyH("LEFT")
        btn.label:SetPoint("TOPLEFT", btn)
        btn.label:Hide()

        -- autoadjust parent size for clicks
        btn.label._SetText = btn.label.SetText
        btn.label.frame = btn
        btn.label.SetText = function(self, text)
            self:_SetText(text)
            self.frame:SetWidth(self:GetWidth())
            self.frame:SetHeight(self:GetHeight())
        end

        btn:SetWidth(1)
        btn:SetHeight(1)

        if lastFrame then
            btn:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0,0)
        else
            btn:SetPoint("TOPLEFT", _QuestieTracker.trackedQuestsFrame, "TOPLEFT", 0,0)
        end

        function btn:SetMode(mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == "zone" then
                    self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontZone) or STANDARD_TEXT_FONT, trackerFontSizeZone)
                    self.label:SetHeight(trackerFontSizeZone)
                elseif mode == "quest" then
                    self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontQuest) or STANDARD_TEXT_FONT, trackerFontSizeQuest)
                    self.label:SetHeight(trackerFontSizeQuest)
                    self.button = nil
                else
                    self.label:SetFont(LSM30:Fetch("font", Questie.db.global.trackerFontObjective) or STANDARD_TEXT_FONT, trackerFontSizeObjective)
                    self.label:SetHeight(trackerFontSizeObjective)
                end
            end
        end

        function btn:SetZone(ZoneId)
            self.ZoneId = QuestieTracker.utils:GetZoneNameByID(ZoneId)
            self.expandZone.zoneId = ZoneId
        end

        function btn:SetQuest(Quest)
            self.Quest = Quest
            self.expandQuest.questId = Quest.Id
        end

        function btn:SetObjective(Objective)
            self.Objective = Objective
        end

        function btn:SetVerticalPadding(amount)
            if self.mode == "zone" then
                self:SetHeight(trackerFontSizeZone + amount)
            elseif self.mode == "quest" then
                self:SetHeight(trackerFontSizeQuest + amount)
            else
                self:SetHeight(trackerFontSizeObjective + amount)
            end
        end

        btn:SetMode("quest")
        btn:EnableMouse(true)
        btn:RegisterForDrag("LeftButton")
        btn:RegisterForClicks("RightButtonUp", "LeftButtonUp")

        btn:SetScript("OnClick", _OnClick)
        btn:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        btn:SetScript("OnDragStop", _QuestieTracker.OnDragStop)
        btn:SetScript("OnEnter", _OnEnter)
        btn:SetScript("OnLeave", _OnLeave)

        if lastFrame then
            btn:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0,0)
        else
            btn:SetPoint("TOPLEFT", _QuestieTracker.trackedQuestsFrame, "TOPLEFT", 0,0)
        end

        -- Used for debugging purposes (can remove prior to v6.0 release)
        --btn:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background"})
        --btn:SetBackdropColor(0, 0, 0, 1)

        _QuestieTracker.LineFrames[i] = btn
        lastFrame = btn

        -- create expanding zone headers for quests sorted by zones
        local expandZone = CreateFrame("Button", nil, btn)
        expandZone:SetWidth(1)
        expandZone:SetHeight(1)
        expandZone:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)

        expandZone.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
            end
        end

        expandZone:SetMode(1) -- maximized

        expandZone:SetMovable(true)
        expandZone:EnableMouse(true)
        expandZone:RegisterForDrag("LeftButton")
        expandZone:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expandZone:SetScript("OnClick", function(self)
            if InCombatLockdown() then
                return
            end
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedZones[self.zoneId] == true then
                Questie.db.char.collapsedZones[self.zoneId] = nil
            else
                Questie.db.char.collapsedZones[self.zoneId] = true
            end
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        expandZone:SetScript("OnEnter", _OnEnter)
        expandZone:SetScript("OnLeave", _OnLeave)
        expandZone:SetScript("OnDragStart", _QuestieTracker.OnDragStart)
        expandZone:SetScript("OnDragStop", _QuestieTracker.OnDragStop)

        expandZone:Hide()

        btn.expandZone = expandZone

        -- create expanding buttons for quests with objectives
        local expandQuest = CreateFrame("Button", nil, btn)
        expandQuest.texture = expandQuest:CreateTexture(nil, "OVERLAY", nil, 0)
        expandQuest.texture:SetWidth(trackerFontSizeQuest)
        expandQuest.texture:SetHeight(trackerFontSizeQuest)
        expandQuest.texture:SetAllPoints(expandQuest)

        expandQuest:SetWidth(trackerFontSizeQuest)
        expandQuest:SetHeight(trackerFontSizeQuest)
        expandQuest:SetPoint("RIGHT", btn, "LEFT", -trackerSpaceBuffer*6.80, 0)

        expandQuest.SetMode = function(self, mode)
            if mode ~= self.mode then
                self.mode = mode
                if mode == 1 then
                    self.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
                else
                    self.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-Up")
                end
                self:SetWidth(trackerFontSizeQuest+3)
                self:SetHeight(trackerFontSizeQuest+3)
            end
        end

        expandQuest:SetMode(1) -- maximized

        expandQuest:EnableMouse(true)
        expandQuest:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        expandQuest:SetScript("OnClick", function(self)
            if InCombatLockdown() then
                return
            end
            if self.mode == 1 then
                self:SetMode(0)
            else
                self:SetMode(1)
            end
            if Questie.db.char.collapsedQuests[self.questId] then
                Questie.db.char.collapsedQuests[self.questId] = nil
            else
                Questie.db.char.collapsedQuests[self.questId] = true
            end
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end)

        expandQuest:SetScript("OnEnter", _OnEnter)
        expandQuest:SetScript("OnLeave", _OnLeave)

        expandQuest:Hide()

        btn.expandQuest = expandQuest
    end
    QuestieTracker.started = true
end

function QuestieTracker:GetBaseFrame()
    return _QuestieTracker.baseFrame
end

function QuestieTracker:ResetLocation()
    if _QuestieTracker.trackerLineWidth == nil then
        return
    end
    _QuestieTracker.activeQuestsHeader:SetMode(1) -- maximized
    Questie.db.char.isTrackerExpanded = true
    Questie.db.char.AutoUntrackedQuests = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerLocation = {}
    Questie.db.char.collapsedQuests = {}
    Questie.db.char.collapsedZones = {}
    Questie.db[Questie.db.global.questieTLoc].TrackerWidth = 0

    QuestieTracker:ResetLinesForChange()

    if _QuestieTracker.baseFrame then
        _QuestieTracker:SetSafePoint(_QuestieTracker.baseFrame)
        _QuestieTracker.baseFrame:Show()
    end
end

function QuestieTracker:ResetDurabilityFrame()
    DurabilityFrame:ClearAllPoints()
    DurabilityFrame:SetPoint(unpack(durabilityInitialPosition))
end

function QuestieTracker:MoveDurabilityFrame()
    if Questie.db.global.trackerEnabled and Questie.db.global.stickyDurabilityFrame and DurabilityFrame:IsShown() and QuestieTracker.started and Questie.db[Questie.db.global.questieTLoc].TrackerLocation ~= nil then
        if Questie.db[Questie.db.global.questieTLoc].TrackerLocation and Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "TOPLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" then
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("LEFT", _QuestieTracker.baseFrame, "TOPRIGHT", 0, -30)
        else
            DurabilityFrame:ClearAllPoints()
            DurabilityFrame:SetPoint("RIGHT", _QuestieTracker.baseFrame, "TOPLEFT", 0, -30)
        end
    else
        QuestieTracker:ResetDurabilityFrame()
    end
end

function _QuestieTracker:SetSafePoint(frm)
    frm:ClearAllPoints()
    local xOff, yOff = frm:GetWidth()/2, frm:GetHeight()/2
    local resetCords = {["BOTTOMLEFT"] = {x = -xOff, y = -yOff}, ["BOTTOMRIGHT"] = {x = xOff, y = -yOff}, ["TOPLEFT"] = {x = -xOff, y =  yOff}, ["TOPRIGHT"] = {x = xOff, y =  yOff}}

    if Questie.db[Questie.db.global.questieTLoc].trackerSetpoint == "AUTO" then
        frm:SetPoint("TOPLEFT", UIParent, "CENTER", resetCords["TOPLEFT"].x, resetCords["TOPLEFT"].y)
    else
        frm:SetPoint(Questie.db[Questie.db.global.questieTLoc].trackerSetpoint, UIParent, "CENTER", resetCords[Questie.db[Questie.db.global.questieTLoc].trackerSetpoint].x, resetCords[Questie.db[Questie.db.global.questieTLoc].trackerSetpoint].y)
    end
end

function QuestieTracker:Enable()
    Questie.db.global.trackerEnabled = true

    -- may not have been initialized yet
    if Questie.db.global.hookTracking then
        QuestieTracker:HookBaseTracker()
    end

    QuestieQuestTimers:HideBlizzardTimer()
    QuestieTracker:Initialize()
    QuestieTracker:MoveDurabilityFrame()
    QuestieTracker:Update()
end

function QuestieTracker:Disable()
    Questie.db.global.trackerEnabled = false

    if Questie.db.global.hookTracking then
        QuestieTracker:Unhook()
    end

    QuestieQuestTimers:ShowBlizzardTimer()
    QuestieTracker:ResetDurabilityFrame()
    QuestieTracker:Update()
end

function QuestieTracker:Toggle(value)
    if value == nil then
        value = not Questie.db.global.trackerEnabled
    end

    Questie.db.global.trackerEnabled = value

    if value then
        QuestieTracker:Enable()
    else
        QuestieTracker:Disable()
    end
end

function QuestieTracker:Collapse()
    if _QuestieTracker.activeQuestsHeader and Questie.db.char.isTrackerExpanded then
        _QuestieTracker.activeQuestsHeader:Click()
    end
end

function QuestieTracker:Expand()
    if _QuestieTracker.activeQuestsHeader and (not Questie.db.char.isTrackerExpanded) then
        _QuestieTracker.activeQuestsHeader:Click()
    end
end

function QuestieTracker:Update()
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: Update")
    if (not QuestieTracker.started) or InCombatLockdown() then
        return
    end

    trackerLineWidth = 0

    -- Tracker has started but not enabled
    if (not Questie.db.global.trackerEnabled) then
        if _QuestieTracker.baseFrame and _QuestieTracker.baseFrame:IsShown() then
            QuestieCombatQueue:Queue(function()
                _QuestieTracker.baseFrame:Hide()
            end)
        end

        return
    end

    -- Update primary frames and layout
    _QuestieTracker.baseFrame:Update()
    _QuestieTracker.activeQuestsHeader:Update()
    _QuestieTracker:UpdateLayout()

    lineIndex = 0
    buttonIndex = 0

    local line = nil
    local order = {}
    QuestieTracker._order = order
    local questCompletePercent = {}

    -- Update quest objectives
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if quest:IsComplete() == 1 or (not quest.Objectives) or (not next(quest.Objectives)) then
                questCompletePercent[quest.Id] = 1
            else
                local percent = 0
                local count = 0
                for _, Objective in pairs(quest.Objectives) do
                    percent = percent + (Objective.Collected / Objective.Needed)
                    count = count + 1
                end
                percent = percent / count
                questCompletePercent[quest.Id] = percent
            end
            table.insert(order, questId)
        end
    end

    -- Quests and objectives sort
    if Questie.db.global.trackerSortObjectives == "byComplete" then
        table.sort(order, function(a, b)
            local vA, vB = questCompletePercent[a], questCompletePercent[b]
            if vA == vB then
                local qA = QuestieDB:GetQuest(a)
                local qB = QuestieDB:GetQuest(b)
                return qA and qB and qA.level < qB.level
            end
            return vB < vA
        end)

    elseif Questie.db.global.trackerSortObjectives == "byLevel" then
        table.sort(order, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level < qB.level
        end)

    elseif Questie.db.global.trackerSortObjectives == "byLevelReversed" then
        table.sort(order, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            return qA and qB and qA.level > qB.level
        end)

    elseif Questie.db.global.trackerSortObjectives == "byZone" then
        table.sort(order, function(a, b)
            local qA = QuestieDB:GetQuest(a)
            local qB = QuestieDB:GetQuest(b)
            local qAZone, qBZone
            if qA.zoneOrSort > 0 then
                qAZone = QuestieTracker.utils:GetZoneNameByID(qA.zoneOrSort)
            elseif qA.zoneOrSort < 0 then
                qAZone = QuestieTracker.utils:GetCatagoryNameByID(qA.zoneOrSort)
            else
                qAZone = qA.zoneOrSort
                Questie:Error("SortID: |cffffbf00"..qA.zoneOrSort.."|r was not found in the Database. Please file a bugreport at:")
                Questie:Error("|cff00bfffhttps://github.com/AeroScripts/QuestieDev/issues|r")
            end

            if qB.zoneOrSort > 0 then
                qBZone = QuestieTracker.utils:GetZoneNameByID(qB.zoneOrSort)
            elseif qB.zoneOrSort < 0 then
                qBZone = QuestieTracker.utils:GetCatagoryNameByID(qB.zoneOrSort)
            else
                qBZone = qB.zoneOrSort
                Questie:Error("SortID: |cffffbf00"..qB.zoneOrSort.."|r was not found in the Database. Please file a bugreport at:")
                Questie:Error("|cff00bfffhttps://github.com/AeroScripts/QuestieDev/issues|r")
            end

            -- Sort by Zone then by Level to mimic QuestLog sorting
            if qAZone == qBZone then
                return qA.level < qB.level
            else
                if qAZone ~= nil and qBZone ~= nil then
                    return qAZone < qBZone
                else
                    return qAZone and qBZone
                end
            end
        end)

    elseif Questie.db.global.trackerSortObjectives == "byProximity" then
        local toSort = {}
        local continent = _GetContinent(C_Map.GetBestMapForUnit("player"))
        for index, questId in pairs(order) do
            local sortData = {}
            sortData.questId = questId
            sortData.distance = _GetDistanceToClosestObjective(questId)
            sortData.q = QuestieDB:GetQuest(questId)
            local _, zone, _ = QuestieMap:GetNearestQuestSpawn(sortData.q)
            sortData.zone = zone
            sortData.continent = _GetContinent(ZoneDataAreaIDToUiMapID[zone])
            toSort[questId] = sortData
        end
        QuestieTracker._sorter = function(a, b)
            a = toSort[a]
            b = toSort[b]
            if ((continent == a.continent) and (continent == b.continent)) or ((continent ~= a.continent) and (continent ~= b.continent)) then
                if a.distance == b.distance then
                    return a.q and b.q and a.q.level < b.q.level;
                end
                if not a.distance and b.distance then
                    return false;
                elseif a.distance and not b.distance then
                    return true;
                end
                return a.distance < b.distance;
            elseif (continent == a.continent) and (continent ~= b.continent) then
                return true
            elseif (continent ~= a.continent) and (continent == b.continent) then
                return false
            end
        end
        table.sort(order, QuestieTracker._sorter)

        if not _QuestProximityTimer then
            QuestieTracker:UpdateQuestProximityTimer()
        end
    end

    if (Questie.db.global.trackerSortObjectives ~= "byProximity") and _QuestProximityTimer and (_QuestProximityTimer:IsCancelled() ~= "true") then
        _QuestProximityTimer:Cancel()
        _QuestProximityTimer = nil
    end

    local hasQuest = false
    local firstQuestInZone = false
    local zoneCheck

    -- Begin populating the tracker with quests
    for _, questId in pairs (order) do
        local quest = QuestieDB:GetQuest(questId)
        local complete = quest:IsComplete()
        local zoneName

        -- Valid ZoneID
        if (quest.zoneOrSort) > 0 then
            zoneName = QuestieTracker.utils:GetZoneNameByID(quest.zoneOrSort)

        -- Valid CatagoryID
        elseif (quest.zoneOrSort) < 0 then
            zoneName = QuestieTracker.utils:GetCatagoryNameByID(quest.zoneOrSort)

        -- Probobly not in the Database. Assign zoneOrSort ID so Questie doesn't error
        else
            zoneName = quest.zoneOrSort
            Questie:Error("SortID: |cffffbf00"..quest.zoneOrSort.."|r was not found in the Database. Please file a bugreport at:")
            Questie:Error("|cff00bfffhttps://github.com/AeroScripts/QuestieDev/issues|r")
        end

        -- Look for any updated objectives since last update
        if quest and quest.Objectives then
            for _,Objective in pairs(quest.Objectives) do
                if Objective.Update then
                    Objective:Update()
                end
            end
        end

        -- Check for valid quests
        quest.timedBlizzardQuest = nil
        local questLogIndex = GetQuestLogIndexByID(questId)
        if questLogIndex then
            local questTimers = GetQuestTimers()
            if questTimers then
                local numTimers = select("#", questTimers)
                for i=1, numTimers do
                    local timerIndex = GetQuestIndexForTimer(i)
                    -- This is a timed quest - flag it to zero
                    if (timerIndex == questLogIndex) and not Questie.db.global.showBlizzardQuestTimer then
                        QuestieQuestTimers:HideBlizzardTimer()
                        quest.timedBlizzardQuest = false
                        complete = 0
                    elseif (timerIndex == questLogIndex) and Questie.db.global.showBlizzardQuestTimer then
                        QuestieQuestTimers:ShowBlizzardTimer()
                        quest.timedBlizzardQuest = true
                        QuestieQuestTimers:GetQuestTimerByQuestId(questId, nil, true)
                        complete = 0
                    else
                        complete = quest:IsComplete()
                    end
                end
            else
                complete = quest:IsComplete()
            end
        end

        if ((complete ~= 1 or Questie.db.global.trackerShowCompleteQuests) and not quest.timedBlizzardQuest) and ((GetCVar("autoQuestWatch") == "1" and not Questie.db.char.AutoUntrackedQuests[questId]) or (GetCVar("autoQuestWatch") == "0" and Questie.db.char.TrackedQuests[questId]))  then -- maybe have an option to display quests in the list with (Complete!) in the title
            hasQuest = true

            -- Add zones
            if Questie.db.global.trackerSortObjectives == "byZone" then
                if zoneCheck ~= zoneName then
                    firstQuestInZone = true
                end

                if firstQuestInZone then
                    line = _QuestieTracker:GetNextLine()
                    line:SetMode("zone")
                    line:SetZone(quest.zoneOrSort)
                    line.expandQuest:Hide()
                    line.expandZone:Show()

                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", -(trackerSpaceBuffer*1.24), 0)


                    if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                        line.expandZone:SetMode(0)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. " +|r")
                    else
                        line.expandZone:SetMode(1)
                        line.label:SetText("|cFFC0C0C0" .. zoneName .. "|r")
                    end

                    line.label:SetWidth(math.min(math.max(Questie.db[Questie.db.global.questieTLoc].TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - ((_QuestieTracker.QuestFrameIndent + trackerSpaceBuffer) - trackerSpaceBuffer), line.label:GetUnboundedStringWidth()))
                    line:SetWidth(line.label:GetWidth() - trackerSpaceBuffer)
                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() - trackerSpaceBuffer)

                    line.expandZone:ClearAllPoints()
                    line.expandZone:SetWidth(line.label:GetWidth())
                    line.expandZone:SetHeight(trackerFontSizeZone)
                    line.expandZone:SetPoint("TOPLEFT", line.label, "TOPLEFT", 0, 0)

                    line:SetVerticalPadding(4)
                    line:Show()
                    line.label:Show()

                    firstQuestInZone = false
                    zoneCheck = zoneName
                end
            end

            -- Add quests
            line = _QuestieTracker:GetNextLine()
            line:SetMode("quest")
            line:SetQuest(quest)
            line:SetObjective(nil)
            line.expandZone:Hide()
            line.expandQuest:Show()

            line.label:ClearAllPoints()
            line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 0, 0)
            local questName = (quest.LocalizedName or quest.name)
            local coloredQuestName = QuestieLib:GetColoredQuestName(quest.Id, questName, quest.level, Questie.db.global.trackerShowQuestLevel, complete)
            line.label:SetText(coloredQuestName)
            line.label:SetWidth(math.min(math.max(Questie.db[Questie.db.global.questieTLoc].TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent + trackerSpaceBuffer), line.label:GetUnboundedStringWidth()))
            line:SetWidth(line.label:GetWidth())

            if Questie.db.global.collapseCompletedQuests and (complete == 1 or complete == -1) then
                if Questie.db.char.collapsedQuests[quest.Id] == nil then
                    Questie.db.char.collapsedQuests[quest.Id] = true
                    line.expandQuest:SetMode(1)
                end
            else
                if Questie.db.char.collapsedQuests[quest.Id] then
                    line.expandQuest:SetMode(0)
                else
                    line.expandQuest:SetMode(1)
                end
            end

            if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                line:Hide()
                line.label:Hide()
                line.expandQuest:Hide()
                lineIndex = lineIndex - 1
            else
                trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth())
            end

            -- Add quest items
            if quest.sourceItemId and questCompletePercent[quest.Id] ~= 1 then
                local fontSizeCompare = trackerFontSizeQuest + trackerFontSizeObjective + Questie.db.global.trackerQuestPadding -- hack to allow refreshing when changing font size
                local button = _QuestieTracker:GetNextItemButton()
                button.itemID = quest.sourceItemId
                button.fontSize = fontSizeCompare
                line.button = button
                button.line = line
                QuestieCombatQueue:Queue(function(self)
                    if self:SetItem(quest, trackerFontSizeQuest+2+trackerFontSizeObjective) then
                        local height = 0
                        local frame = line

                        while frame and frame ~= _QuestieTracker.trackedQuestsFrame do
                            local _, parent, _, xOff, yOff = frame:GetPoint()
                            height = height - (frame:GetHeight() - yOff)
                            frame = parent
                        end

                        self:SetPoint("TOPRIGHT", self.line, "TOPLEFT", -trackerSpaceBuffer/4.4, -1)
                        self:SetParent(self.line)
                        self:Show()

                        if Questie.db.char.collapsedQuests[quest.Id] == nil then
                            self.line.expandQuest:SetFrameStrata("LOW")
                            self.line.expandQuest:Hide()
                        else
                            self.line.expandQuest:SetFrameStrata("MEDIUM")
                            self:SetParent(UIParent)
                            self:Hide()
                        end

                        if Questie.db.char.collapsedZones[quest.zoneOrSort] then
                            self.line.expandQuest:SetFrameStrata("MEDIUM")
                            self:SetParent(UIParent)
                            self:Hide()
                        end

                    else
                        self.line.expandQuest:SetFrameStrata("MEDIUM")
                        self:SetParent(UIParent)
                        self:Hide()
                    end

                end, button)
            end

            if Questie.db.global.collapseCompletedQuests and complete == 1 then
                line.expandQuest:Hide()
            end

            line:Show()
            line.label:Show()
            line:SetVerticalPadding(2)

            -- Add quest timers (if applicable)
            local seconds
            line = _QuestieTracker:GetNextLine()
            if not quest.timedBlizzardQuest then
                seconds = QuestieQuestTimers:GetQuestTimerByQuestId(questId, line)
            end
            if (seconds) then
                local prevLineIndex = lineIndex - 1
                local prevLine = _QuestieTracker.LineFrames[prevLineIndex]
                line:SetMode("objective")
                line:SetQuest(quest)
                line.expandZone:Hide()

                line.label:ClearAllPoints()
                line.label:SetPoint("TOPLEFT", line, "TOPLEFT", 5, 0)
                line.label:SetText(seconds)
                line.label:SetWidth(math.min(math.max(Questie.db[Questie.db.global.questieTLoc].TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent), trackerSpaceBuffer + prevLine.label:GetUnboundedStringWidth()))
                line:SetWidth(line.label:GetWidth())
                line:SetVerticalPadding(2)
                line:Show()
                line.label:Show()

                if Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id] then
                    lineIndex = lineIndex - 1
                    line:Hide()
                    line.label:Hide()
                    QuestieQuestTimers:GetQuestTimerByQuestId(questId, nil, true)
                else
                    trackerLineWidth = math.max(trackerLineWidth, prevLine.label:GetUnboundedStringWidth())
                end
            else

                lineIndex = lineIndex - 1
            end

            -- Add quest objectives (if applicable)
            if not (Questie.db.char.collapsedZones[quest.zoneOrSort] or Questie.db.char.collapsedQuests[quest.Id]) then
                if (quest.Objectives and complete == 0) then
                    for _, objective in pairs(quest.Objectives) do
                        line = _QuestieTracker:GetNextLine()
                        line:SetMode("objective")
                        line:SetQuest(quest)
                        line:SetObjective(objective)
                        line.expandZone:Hide()

                        line.label:ClearAllPoints()
                        line.label:SetPoint("TOPLEFT", line, "TOPLEFT", trackerSpaceBuffer/1.50, 0)
                        local lineEnding = ""
                        local objDesc = objective.Description:gsub("%.", "")
                        if objective.Needed > 0 then lineEnding = tostring(objective.Collected) .. "/" .. tostring(objective.Needed) end
                        line.label:SetText(QuestieLib:GetRGBForObjective(objective) .. objDesc .. ": " .. lineEnding)
                        line.label:SetWidth(math.min(math.max(Questie.db[Questie.db.global.questieTLoc].TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent + trackerSpaceBuffer*1.50), trackerSpaceBuffer + line.label:GetUnboundedStringWidth()))
                        line:SetWidth(line.label:GetWidth())

                        trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerSpaceBuffer)
                        line:SetVerticalPadding(1)
                        line:Show()
                        line.label:Show()
                    end

                -- Tags quest as either complete or failed so as to always have at least one objective.
                -- (TODO: change tags to reflect NPC to turn a quest into or in the case of a failure
                -- which NPC to obtain the quest from again...)
                elseif (complete == 1 or complete == -1) then
                    line = _QuestieTracker:GetNextLine()
                    line:SetMode("objective")
                    line:SetQuest(quest)
                    line:SetObjective(objective)
                    line.expandZone:Hide()

                    line.label:ClearAllPoints()
                    line.label:SetPoint("TOPLEFT", line, "TOPLEFT", trackerSpaceBuffer/1.50, 0)

                    if (complete == 1) then
                        line.label:SetText("|cFF40C040Quest Complete!|r")
                    elseif (complete == -1) then
                        line.label:SetText("|cffff0000Quest Failed!|r")
                    end

                    line.label:SetWidth(math.min(math.max(Questie.db[Questie.db.global.questieTLoc].TrackerWidth, _QuestieTracker.baseFrame:GetWidth()) - (_QuestieTracker.QuestFrameIndent + trackerSpaceBuffer*1.50), trackerSpaceBuffer + line.label:GetUnboundedStringWidth()))
                    line:SetWidth(line.label:GetWidth())

                    trackerLineWidth = math.max(trackerLineWidth, line.label:GetUnboundedStringWidth() + trackerSpaceBuffer)
                    line:SetVerticalPadding(1)
                    line:Show()
                    line.label:Show()
                end
            else
                line = _QuestieTracker:GetNextLine()
                lineIndex = lineIndex - 1
                line.mode = nil
                line.Quest = nil
                line.Objective = nil
                line.label.frame.expandQuest.questId = nil
                line.label:ClearAllPoints()
                line:Hide()
            end

            line:SetVerticalPadding(Questie.db.global.trackerQuestPadding)
        end
    end

    -- Begin post clean up of unused frameIndexes
    _QuestieTracker.highestIndex = lineIndex
    local startUnusedFrames = 1
    local startUnusedButtons = 1

    if Questie.db.char.isTrackerExpanded then
        startUnusedFrames = lineIndex + 1
        startUnusedButtons = buttonIndex + 1
    end

    -- Hide unused quest buttons
    for i = startUnusedFrames, trackerLineCount do
        _QuestieTracker.LineFrames[i]:Hide()
        if _QuestieTracker.LineFrames[i].expandQuest then
            _QuestieTracker.LineFrames[i].expandQuest:Hide()
        end
        if _QuestieTracker.LineFrames[i].expandZone then
            _QuestieTracker.LineFrames[i].expandZone:Hide()
        end
    end

    -- Hide unused item buttons
    for i = startUnusedButtons, 20 do
        local button = _QuestieTracker.ItemButtons[i]
        if button.itemID then
            button:FakeHide()
            button.itemID = nil
            button.itemName = nil
            button.lineID = nil
            button.fontSize = nil
            button:SetParent(UIParent)
            button:Hide()
        end
    end

    -- Auto adjust tracker size and visibility
    local activeQuestsHeaderTotal = trackerSpaceBuffer + _QuestieTracker.activeQuestsHeader.label:GetUnboundedStringWidth()
    local trackerVARScombined = trackerLineWidth + trackerSpaceBuffer + _QuestieTracker.QuestFrameIndent
    local trackerBaseFrame = _QuestieTracker.baseFrame:GetWidth()

    if not Questie.db.char.isTrackerExpanded then
        _QuestieTracker.baseFrame:SetHeight(trackerSpaceBuffer)

        if Questie.db[Questie.db.global.questieTLoc].TrackerWidth > 0 then
            _QuestieTracker.baseFrame:SetWidth(Questie.db[Questie.db.global.questieTLoc].TrackerWidth)
        else
            _QuestieTracker.baseFrame:SetWidth(trackerVARScombined)
        end

        _QuestieTracker.trackedQuestsFrame:Hide()

    elseif line then
        if Questie.db[Questie.db.global.questieTLoc].TrackerWidth > 0 then
            if (Questie.db[Questie.db.global.questieTLoc].TrackerWidth < activeQuestsHeaderTotal and _QuestieTracker.isSizing ~= true) then
                _QuestieTracker.baseFrame:SetWidth(activeQuestsHeaderTotal)
                Questie.db[Questie.db.global.questieTLoc].TrackerWidth = activeQuestsHeaderTotal
            elseif (Questie.db[Questie.db.global.questieTLoc].TrackerWidth ~= trackerBaseFrame and _QuestieTracker.isSizing ~= true) then
                _QuestieTracker.baseFrame:SetWidth(Questie.db[Questie.db.global.questieTLoc].TrackerWidth)
            end
        else

            if (trackerVARScombined < activeQuestsHeaderTotal) then
                _QuestieTracker.baseFrame:SetWidth(activeQuestsHeaderTotal)
            elseif (trackerVARScombined ~= trackerBaseFrame) then
                _QuestieTracker.baseFrame:SetWidth(trackerVARScombined)
            end
        end

        -- Trims the bottom of the tracker (overall height) based on min/max'd zones and/or quests
        local trackerBottomPadding = nil
        if Questie.db.global.trackerHeaderEnabled and Questie.db.global.trackerHeaderAutoMove and Questie.db[Questie.db.global.questieTLoc].TrackerLocation and (Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMLEFT" or Questie.db[Questie.db.global.questieTLoc].TrackerLocation[1] == "BOTTOMRIGHT") then
            trackerBottomPadding = 15
        else
            trackerBottomPadding = 0
        end

        if line:IsVisible() or lineIndex == 1 then
            if lineIndex == 1 then
                _QuestieTracker.baseFrame:SetHeight(_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + trackerBottomPadding - 5)
            else
                _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + trackerBottomPadding) + trackerSpaceBuffer/2  - Questie.db.global.trackerQuestPadding + 2)
            end
        else

            local lineNum = lineIndex - 1
            line = _QuestieTracker.LineFrames[lineNum]
            _QuestieTracker.baseFrame:SetHeight((_QuestieTracker.baseFrame:GetTop() - line:GetBottom() + trackerBottomPadding) + trackerSpaceBuffer)
        end

        _QuestieTracker.baseFrame:SetMaxResize(GetScreenWidth()/2, GetScreenHeight())
        _QuestieTracker.baseFrame:SetMinResize(trackerSpaceBuffer + _QuestieTracker.activeQuestsHeader.label:GetUnboundedStringWidth(), _QuestieTracker.baseFrame:GetHeight())
        _QuestieTracker.trackerLineWidth = trackerLineWidth
        _QuestieTracker.trackedQuestsFrame:Show()
    end

    -- First run clean up
    if _QuestieTracker.IsFirstRun then
        for questId in pairs (QuestiePlayer.currentQuestlog) do
            local quest = QuestieDB:GetQuest(questId)
            if quest then
                if Questie.db.char.TrackerHiddenQuests[questId] then
                    quest.HideIcons = true
                end
                if Questie.db.char.TrackerFocus then
                    if Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == quest.Id then -- quest focus
                        QuestieTracker:FocusQuest(quest)
                    end
                end
                if quest.Objectives then
                    for _,Objective in pairs(quest.Objectives) do
                        if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(Objective.Index)] then
                            Objective.HideIcons = true
                        end
                        if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(Objective.Index) then
                            QuestieTracker:FocusObjective(quest, Objective)
                        end
                    end
                end
                if quest.SpecialObjectives then
                    for _, objective in pairs(quest.SpecialObjectives) do
                        if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                            objective.HideIcons = true
                        end
                        if  Questie.db.char.TrackerFocus and type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus == tostring(quest.Id) .. " " .. tostring(objective.Index) then
                            QuestieTracker:FocusObjective(quest, objective)
                        end
                    end
                end
            end
        end
        C_Timer.After(2.0, function()
            _QuestieTracker.baseFrame:Show()
            _QuestieTracker.IsFirstRun = nil
        end)
    end

    if hasQuest and _QuestieTracker.IsFirstRun == nil then
        _QuestieTracker.baseFrame:Show()
    else
        _QuestieTracker.baseFrame:Hide()
    end
end

function _QuestieTracker:GetNextLine()
    lineIndex = lineIndex + 1
    if _QuestieTracker.LineFrames[lineIndex].expandQuest then
        _QuestieTracker.LineFrames[lineIndex].expandQuest:Hide()

    elseif _QuestieTracker.LineFrames[lineIndex].expandZone then
        _QuestieTracker.LineFrames[lineIndex].expandZone:Hide()
    end

    return _QuestieTracker.LineFrames[lineIndex]
end

function _QuestieTracker:GetNextItemButton()
    buttonIndex = buttonIndex + 1
    return _QuestieTracker.ItemButtons[buttonIndex]
end

function _QuestieTracker:StartFadeTicker()
    if (not _QuestieTracker.FadeTicker) and QuestieTracker.started then
        _QuestieTracker.FadeTicker = C_Timer.NewTicker(0.02, function()
            if _QuestieTracker.FadeTickerDirection then
                if _QuestieTracker.FadeTickerValue < 0.3 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue + 0.02

                    -- Un-fade the background and border(if enabled)
                    if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                        if Questie.db.global.trackerBorderEnabled then
                            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                        end
                    end

                    -- Un-fade the resizer
                    if Questie.db.char.isTrackerExpanded then
                        _QuestieTracker.baseFrame.sizer:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                    end

                    -- Un-fade the minimize buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandQuest:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                        end
                    end

                    -- Un-fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                        for i=1, _QuestieTracker.highestIndex do
                            if _QuestieTracker.LineFrames[i].button then
                                _QuestieTracker.LineFrames[i].button:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                            end
                        end
                    end

                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            else
                if _QuestieTracker.FadeTickerValue > 0 then
                    _QuestieTracker.FadeTickerValue = _QuestieTracker.FadeTickerValue - 0.02

                    -- Fade the background and border(if enabled)
                    if Questie.db.char.isTrackerExpanded and Questie.db.global.trackerBackdropEnabled and Questie.db.global.trackerBackdropFader then
                        _QuestieTracker.baseFrame:SetBackdropColor(0, 0, 0, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                        if Questie.db.global.trackerBorderEnabled then
                            _QuestieTracker.baseFrame:SetBackdropBorderColor(1, 1, 1, math.min(Questie.db.global.trackerBackdropAlpha, _QuestieTracker.FadeTickerValue*3.3))
                        end
                    end

                    -- Fade the resizer
                    if Questie.db.char.isTrackerExpanded then
                        _QuestieTracker.baseFrame.sizer:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                    end

                    -- Fade the minimuze buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeMinMaxButtons) then
                        for i=1, _QuestieTracker.highestIndex do
                            _QuestieTracker.LineFrames[i].expandQuest:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                        end
                    end

                    -- Fade the quest item buttons
                    if (Questie.db.char.isTrackerExpanded and Questie.db.global.trackerFadeQuestItemButtons) then
                        for i=1, _QuestieTracker.highestIndex do
                            if _QuestieTracker.LineFrames[i].button then
                                _QuestieTracker.LineFrames[i].button:SetAlpha(_QuestieTracker.FadeTickerValue*3.3)
                            end
                        end
                    end

                else
                    _QuestieTracker.FadeTicker:Cancel()
                    _QuestieTracker.FadeTicker = nil
                end
            end
        end)
    end
end

function QuestieTracker:UnFocus()
    -- reset HideIcons to match savedvariable state
    if (not Questie.db.char.TrackerFocus) then
        return
    end
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)

        if quest then
            quest.FadeIcons = nil
            if quest.Objectives then

                if Questie.db.char.TrackerHiddenQuests[quest.Id] then
                    quest.HideIcons = true
                    quest.FadeIcons = nil
                else
                    quest.HideIcons = nil
                    quest.FadeIcons = nil
                end

                for _, objective in pairs(quest.Objectives) do
                    if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then
                        objective.HideIcons = true
                        objective.FadeIcons = nil
                    else
                        objective.HideIcons = nil
                        objective.FadeIcons = nil
                    end
                end

                if quest.SpecialObjectives then
                    for _, objective in pairs(quest.SpecialObjectives) do
                        if Questie.db.char.TrackerHiddenObjectives[tostring(questId) .. " " .. tostring(objective.Index)] then

                            objective.HideIcons = true
                            objective.FadeIcons = nil
                        else
                            objective.HideIcons = nil
                            objective.FadeIcons = nil
                        end
                    end
                end
            end
        end
    end

    Questie.db.char.TrackerFocus = nil
end

function QuestieTracker:FocusObjective(targetQuest, targetObjective)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "string" or Questie.db.char.TrackerFocus ~= tostring(targetQuest.Id) .. " " .. tostring(targetObjective.Index)) then
        QuestieTracker:UnFocus()
    end

    Questie.db.char.TrackerFocus = tostring(targetQuest.Id) .. " " .. tostring(targetObjective.Index)
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest and quest.Objectives then
            if questId == targetQuest.Id then
                quest.HideIcons = nil
                quest.FadeIcons = nil

                for _,Objective in pairs(quest.Objectives) do
                    if Objective.Index == targetObjective.Index then
                        Objective.HideIcons = nil
                        Objective.FadeIcons = nil
                    else
                        Objective.FadeIcons = true
                    end
                end

                if quest.SpecialObjectives then
                    for _, objective in pairs(quest.SpecialObjectives) do
                        if objective.Index == targetObjective.Index then
                            objective.HideIcons = nil
                            objective.FadeIcons = nil
                        else
                            objective.FadeIcons = true
                        end
                    end
                end

            else
                quest.FadeIcons = true
            end
        end
    end
end

function QuestieTracker:FocusQuest(targetQuest)
    if Questie.db.char.TrackerFocus and (type(Questie.db.char.TrackerFocus) ~= "number" or Questie.db.char.TrackerFocus ~= targetQuest.Id) then
        QuestieTracker:UnFocus()
    end
    Questie.db.char.TrackerFocus = targetQuest.Id
    for questId in pairs (QuestiePlayer.currentQuestlog) do
        local quest = QuestieDB:GetQuest(questId)
        if quest then
            if questId == targetQuest.Id then
                quest.HideIcons = nil
                quest.FadeIcons = nil
            else
                -- if hideOnFocus
                --Quest.HideIcons = true
                quest.FadeIcons = true
            end
        end
    end
end

function QuestieTracker:Untrack(quest)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: Untrack")
    if GetCVar("autoQuestWatch") == "0" then
        Questie.db.char.TrackedQuests[quest.Id] = nil
    else
        Questie.db.char.AutoUntrackedQuests[quest.Id] = true
    end
    QuestieTracker:Update()
end

function QuestieTracker:Unhook()
    if (not QuestieTracker._alreadyHooked) then
        return
    end

    QuestieTracker._disableHooks = true
    if QuestieTracker._IsQuestWatched then
        IsQuestWatched = QuestieTracker._IsQuestWatched
        GetNumQuestWatches = QuestieTracker._GetNumQuestWatches
    end
    _QuestieTracker._alreadyHooked = nil
    QuestWatchFrame:Show()
end

function QuestieTracker:HookBaseTracker()
    if _QuestieTracker._alreadyHooked then
        return
    end
    QuestieTracker._disableHooks = nil

    if not QuestieTracker._alreadyHookedSecure then
        hooksecurefunc("AutoQuestWatch_Insert", _AQW_Insert)
        hooksecurefunc("AddQuestWatch", _AQW_Insert)
        hooksecurefunc("RemoveQuestWatch", _RemoveQuestWatch)

        -- completed/objectiveless tracking fix
        -- blizzard quest tracker

        local baseQLTB_OnClick = QuestLogTitleButton_OnClick
        QuestLogTitleButton_OnClick = function(self, button) -- I wanted to use hooksecurefunc but this needs to be a pre-hook to work properly unfortunately
            if (not self) or self.isHeader or not IsShiftKeyDown() then baseQLTB_OnClick(self, button) return end
            local questLogLineIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
            local questId = GetQuestIDFromLogIndex(questLogLineIndex)

            if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
                if (self.isHeader) then
                    return
                end
                ChatEdit_InsertLink("["..gsub(self:GetText(), " *(.*)", "%1").." ("..questId..")]")

            else
                if GetNumQuestLeaderBoards(questLogLineIndex) == 0 and not IsQuestWatched(questLogLineIndex) then -- only call if we actually want to fix this quest (normal quests already call AQW_insert)
                    _AQW_Insert(questLogLineIndex, QUEST_WATCH_NO_EXPIRE)
                    QuestWatch_Update()
                    QuestLog_SetSelection(questLogLineIndex)
                    QuestLog_Update()
                else
                    baseQLTB_OnClick(self, button)
                end
            end
        end
        -- other addons

        -- totally prevent the blizzard tracker frame from showing (BAD CODE, shouldn't be needed but some have had trouble)
        QuestWatchFrame:HookScript("OnShow", function(self) if QuestieTracker._disableHooks then return end self:Hide() end)
        QuestieTracker._alreadyHookedSecure = true
    end

    if not QuestieTracker._IsQuestWatched then
        QuestieTracker._IsQuestWatched = IsQuestWatched
        QuestieTracker._GetNumQuestWatches = GetNumQuestWatches
    end

    -- this is probably bad
    IsQuestWatched = function(index)
        if "0" == GetCVar("autoQuestWatch") then
            return Questie.db.char.TrackedQuests[select(8,GetQuestLogTitle(index)) or -1]
        else
            local qid = select(8,GetQuestLogTitle(index))
            return qid and QuestiePlayer.currentQuestlog[qid] and not Questie.db.char.AutoUntrackedQuests[qid]
        end
    end

    GetNumQuestWatches = function()
        return 0
    end

    QuestWatchFrame:Hide()
    QuestieTracker._alreadyHooked = true
end

_OnClick = function(self, button, down)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieTracker:_OnClick]")
    if _QuestieTracker.isMoving == true then
        Questie:Debug(DEBUG_DEVELOP, "[QuestieTracker:_OnClick]", "Tracker is being dragged. Don't show the menu")
        return
    end

    if self.Quest == nil then
        return
    end

    if QuestieTracker.utils:IsBindTrue(Questie.db.global.trackerbindSetTomTom, button) then
        local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(self.Quest)
        if spawn then
            QuestieTracker.utils:SetTomTomTarget(name, zone, spawn[1], spawn[2])
        end

    elseif QuestieTracker.utils:IsBindTrue(Questie.db.global.trackerbindUntrack, button) then
        if (IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then

            if Questie.db.global.trackerShowQuestLevel then
                ChatEdit_InsertLink("[["..self.Quest.level.."] "..self.Quest.name.." ("..self.Quest.Id..")]")
            else
                ChatEdit_InsertLink("["..self.Quest.name.." ("..self.Quest.Id..")]")
            end

        else
            QuestieTracker:Untrack(self.Quest)
        end

    elseif QuestieTracker.utils:IsBindTrue(Questie.db.global.trackerbindOpenQuestLog, button) then
        QuestieTracker.utils:ShowQuestLog(self.Quest)

    elseif button == "RightButton" then
        local menu = QuestieTracker.menu:GetMenuForQuest(self.Quest)
        LQuestie_EasyMenu(menu, _QuestieTracker.menuFrame, "cursor", 0 , 0, "MENU")
    end
end

_OnEnter = function()
    _QuestieTracker.FadeTickerDirection = true
    _QuestieTracker:StartFadeTicker()
end

_OnLeave = function()
    _QuestieTracker.FadeTickerDirection = false
    _QuestieTracker:StartFadeTicker()
end

function QuestieTracker:ResetLinesForChange()
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: ResetLinesForChange")
    if InCombatLockdown() or not Questie.db.global.trackerEnabled then return end
    if _QuestieTracker.highestIndex then
        for i = 1, _QuestieTracker.highestIndex do
            if _QuestieTracker.LineFrames[i] then
                _QuestieTracker.LineFrames[i].mode = nil
                _QuestieTracker.LineFrames[i].expandQuest.mode = nil
                _QuestieTracker.LineFrames[i].expandZone.mode = nil
                _QuestieTracker.LineFrames[i].expandQuest:SetFrameStrata("MEDIUM")
            end
            if _QuestieTracker.trackedQuestsFrame then
                _QuestieTracker.trackedQuestsFrame:Hide()
                _QuestieTracker.trackedQuestsFrame:Update()
            end
        end
    else
        for i = 1, trackerLineCount do
            if _QuestieTracker.LineFrames[i] then
                _QuestieTracker.LineFrames[i].mode = nil
                _QuestieTracker.LineFrames[i].expandQuest.mode = nil
                _QuestieTracker.LineFrames[i].expandZone.mode = nil
                _QuestieTracker.LineFrames[i].expandQuest:SetFrameStrata("MEDIUM")
            end
            if _QuestieTracker.trackedQuestsFrame then
                _QuestieTracker.trackedQuestsFrame:Hide()
                _QuestieTracker.trackedQuestsFrame:Update()
            end
        end
    end
    _QuestieTracker:UpdateLayout()
    QuestieTracker:Update()
end

function QuestieTracker:RemoveQuest(id)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: RemoveQuest")
    if Questie.db.char.TrackerFocus then
        if (type(Questie.db.char.TrackerFocus) == "number" and Questie.db.char.TrackerFocus == id)
        or (type(Questie.db.char.TrackerFocus) == "string" and Questie.db.char.TrackerFocus:sub(1, #tostring(id)) == tostring(id)) then
            QuestieTracker:UnFocus()
            QuestieQuest:UpdateHiddenNotes()
        end
    end
end

local hexTable = {
    "00","11","22","33","44","55","66","77","88","99","AA","BB","CC","DD","EE","FF"
}

function _QuestieTracker:PrintProgressColor(percent, text)
    local hexGreen = hexTable[5 + math.floor(percent * 10)]
    local hexRed = hexTable[8 + math.floor((1 - percent) * 6)]
    local hexBlue = hexTable[4 + math.floor(percent * 6)]

    return "|cFF"..hexRed..hexGreen..hexBlue..text.."|r"
end

_RemoveQuestWatch = function(index, isQuestie)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: RemoveQuestWatch")
    if QuestieTracker._disableHooks then
        return
    end

    if not isQuestie then
        local qid = select(8,GetQuestLogTitle(index))
        if qid then
            if "0" == GetCVar("autoQuestWatch") then
                Questie.db.char.TrackedQuests[qid] = nil
            else
                Questie.db.char.AutoUntrackedQuests[qid] = true
            end
            QuestieTracker:ResetLinesForChange()
            QuestieTracker:Update()
        end
    end
end

_AQW_Insert = function(index, expire)
    Questie:Debug(DEBUG_DEVELOP, "QuestieTracker: AQW_Insert")
    if QuestieTracker._disableHooks then
        return
    end

    local now = GetTime()
    if index and index == QuestieTracker._last_aqw and (now - lastAQW) < 0.1 then return end -- this fixes double calling due to AQW+AQW_Insert (QuestGuru fix)

    lastAQW = now
    QuestieTracker._last_aqw = index
    RemoveQuestWatch(index, true) -- prevent hitting 5 quest watch limit

    local qid = select(8,GetQuestLogTitle(index))
    if qid then
        if "0" == GetCVar("autoQuestWatch") then
            if Questie.db.char.TrackedQuests[qid] then
                Questie.db.char.TrackedQuests[qid] = nil
            else
                Questie.db.char.TrackedQuests[qid] = true
            end
        else
            if Questie.db.char.AutoUntrackedQuests[qid] then
                Questie.db.char.AutoUntrackedQuests[qid] = nil
            elseif IsShiftKeyDown() and (QuestLogFrame:IsShown() or (QuestLogExFrame and QuestLogExFrame:IsShown())) then--hack
                Questie.db.char.AutoUntrackedQuests[qid] = true
            end
        end

        -- Make sure quests or zones (re)added to the tracker isn't in a minimized state
        local quest = QuestieDB:GetQuest(qid)
        local zoneId = quest.zoneOrSort

        if Questie.db.char.collapsedQuests[qid] == true then
            Questie.db.char.collapsedQuests[qid] = nil
        end

        if Questie.db.char.collapsedZones[zoneId] == true then
            Questie.db.char.collapsedZones[zoneId] = nil
        end

        QuestieTracker:ResetLinesForChange()
        QuestieTracker:Update()
    end
end

local function _GetWorldPlayerPosition()
    -- Turns coords into 'world' coords so it can be compared with any coords in another zone
    local uiMapId = C_Map.GetBestMapForUnit("player");

    if (not uiMapId) then
        return nil;
    end

    local mapPosition = C_Map.GetPlayerMapPosition(uiMapId, "player");
    local _, worldPosition = C_Map.GetWorldPosFromMapPos(uiMapId, mapPosition);

    return worldPosition;
end

local function _GetDistance(x1, y1, x2, y2)
    -- Basic proximity distance calculation to compare two locs (normally player position and provided loc)
    return math.sqrt( (x2-x1)^2 + (y2-y1)^2 );
end

_GetDistanceToClosestObjective = function(questId)
    -- main function for proximity sorting
    local player = _GetWorldPlayerPosition();

    if (not player) then
        return nil
    end

    local coordinates = {};
    local quest = QuestieDB:GetQuest(questId);

    if (not quest) then
        return nil
    end

    local spawn, zone, name = QuestieMap:GetNearestQuestSpawn(quest)

    if (not spawn) or (not zone) or (not name) then
        return nil
    end

    local _, worldPosition = C_Map.GetWorldPosFromMapPos(ZoneDataAreaIDToUiMapID[zone], {
        x = spawn[1] / 100,
        y = spawn[2] / 100
    });

    tinsert(coordinates, {
        x = worldPosition.x,
        y = worldPosition.y
    });

    if (not coordinates) then
        return nil
    end

    local closestDistance;
    for _, coords in pairs(coordinates) do
        local distance = _GetDistance(player.x, player.y, worldPosition.x, worldPosition.y);
        if closestDistance == nil or distance < closestDistance then
            closestDistance = distance;
        end
    end

    return closestDistance;
end

_GetContinent = function(uiMapId)
    if (not uiMapId) then
        return
    end

    if (uiMapId == 947) or (uiMapId == 1459) or (uiMapId == 1460) or (uiMapId == 1461) then
        return "Azeroth"
    elseif ((uiMapId >= 1415) and (uiMapId <= 1437)) or (uiMapId == 1453) or (uiMapId == 1455) or (uiMapId == 1458) or (uiMapId == 1463) then
        return "Eastern Kingdoms"
    elseif ((uiMapId >= 1411) and (uiMapId <= 1414)) or ((uiMapId >= 1438) and (uiMapId <= 1452)) or (uiMapId == 1454) or (uiMapId == 1456) or (uiMapId == 1457) then
        return "Kalimdor"
    else

        print(uiMapId, "is unknown")
    end
end

function QuestieTracker:UpdateQuestProximityTimer()
    -- Check location often and update if you've moved
    C_Timer.After(3.0, function()
        _QuestProximityTimer = C_Timer.NewTicker(5.0, function()
            local position = _GetWorldPlayerPosition();
            if position then
                local distance = _PlayerPosition and _GetDistance(position.x, position.y, _PlayerPosition.x, _PlayerPosition.y);
                if not distance or distance > 0.01 then
                    _PlayerPosition = position;
                    --QuestieTracker:Update()
                    local orderCopy = {}
                    for index, val in pairs(QuestieTracker._order) do
                        orderCopy[index] = val
                    end
                    table.sort(orderCopy, QuestieTracker._sorter)
                    for index, val in pairs(QuestieTracker._order) do
                        if orderCopy[index] ~= val then
                            -- the order has changed
                            QuestieTracker:Update()
                            break;
                        end
                    end
                end
            end
        end)
    end)
end
