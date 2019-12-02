
---@class QuestieFrameNew
local QuestieFrameNew = QuestieLoader:CreateModule("QuestieFrameNew");
---@type QuestieQuest
local QuestieQuest = QuestieLoader:ImportModule("QuestieQuest");
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap");
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule("QuestiePlayer");
---@type QuestieSerializer
local QuestieSerializer = QuestieLoader:ImportModule("QuestieSerializer");

local HBD = LibStub("HereBeDragonsQuestie-2.0")

local enumerator = 0; -- DO EDIT.
QuestieFrameNew.stringEnum = setmetatable({}, {
  __index = function(stringEnum, key)
     if not stringEnum[key] then
        DEFAULT_CHAT_FRAME:AddMessage("stringEnum settings enum:"..key.. " enumID:".. enumerator);
        rawset(stringEnum, key, enumerator);
        rawset(stringEnum, enumerator, key);
        enumerator = enumerator + 1;
        return stringEnum[key]
     else
        return stringEnum[key]
     end
  end
})


local typeLookup = {}
typeLookup[QuestieFrameNew.stringEnum["available"]] = {};
typeLookup[QuestieFrameNew.stringEnum["available"]].GetIcon = function(questId)
  local questObject = QuestieDB:GetQuest(questId);
  if(questObject) then
    if questObject.requiredLevel > QuestiePlayer.GetPlayerLevel() then
        return ICON_TYPE_AVAILABLE_GRAY
    elseif questObject.Repeatable then
        return ICON_TYPE_REPEATABLE
    elseif(questObject:IsTrivial()) then
        return ICON_TYPE_AVAILABLE_GRAY
    else
        return ICON_TYPE_AVAILABLE
    end
  end
  return ICON_TYPE_AVAILABLE;
end
typeLookup[QuestieFrameNew.stringEnum["available"]].GetIconScale = function()
  return Questie.db.global.availableScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["available"]].GetDrawLayer = function()
  return 1;
end

typeLookup[QuestieFrameNew.stringEnum["complete"]] = {};
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetIcon = function()
  return ICON_TYPE_COMPLETE;
end
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetIconScale = function()
  return Questie.db.global.availableScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["complete"]].GetDrawLayer = function()
  return 2;
end

typeLookup[QuestieFrameNew.stringEnum["event"]] = {};
typeLookup[QuestieFrameNew.stringEnum["event"]].GetIcon = function()
  return ICON_TYPE_EVENT;
end
typeLookup[QuestieFrameNew.stringEnum["event"]].GetIconScale = function()
  return Questie.db.global.eventScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["event"]].GetDrawLayer = function()
  return 0;
end

typeLookup[QuestieFrameNew.stringEnum["item"]] = {};
typeLookup[QuestieFrameNew.stringEnum["item"]].GetIcon = function()
  return ICON_TYPE_LOOT;
end
typeLookup[QuestieFrameNew.stringEnum["item"]].GetIconScale = function()
  return Questie.db.global.lootScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["item"]].GetDrawLayer = function()
  return 0;
end

typeLookup[QuestieFrameNew.stringEnum["monster"]] = {};
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetIcon = function()
  return ICON_TYPE_SLAY;
end
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetIconScale = function()
  return Questie.db.global.monsterScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["monster"]].GetDrawLayer = function()
  return 0;
end

typeLookup[QuestieFrameNew.stringEnum["object"]] = {};
typeLookup[QuestieFrameNew.stringEnum["object"]].GetIcon = function()
  return ICON_TYPE_OBJECT;
end
typeLookup[QuestieFrameNew.stringEnum["object"]].GetIconScale = function()
  return Questie.db.global.objectScale or 1.3;
end
typeLookup[QuestieFrameNew.stringEnum["object"]].GetDrawLayer = function()
  return 0;
end


local texturePool = CreateTexturePool(WorldMapFrame:GetCanvas());
texturePool.creationFunc = function(texPool)
  local texture = texPool.parent:CreateTexture(nil, "OVERLAY", nil, 0);
  texture.OLDSetVertexColor = texture.SetVertexColor;
  function texture:SetVertexColor(r, g, b, a)
      self:OLDSetVertexColor(r,g,b,a);
      --We save the colors to the texture object, this way we don't need to use GetVertexColor
      self.r = r or 1;
      self.g = g or 1;
      self.b = b or 1;
      self.a = a or 1;
  end
  texture:SetTexture(136235); --Samwise is our god.
  --We save the colors to the texture object, this way we don't need to use GetVertexColor
  texture:SetVertexColor(1,1,1,1);
  texture:SetTexelSnappingBias(0)
  texture:SetSnapToPixelGrid(false)

  return texture
end

texturePool.resetterFunc = function(texPool, texture)
  texture.textureData = nil;
  texture:SetTexture(136235)
  texture:SetVertexColor(1,1,1,1);
  TexturePool_HideAndClearAnchors(texPool, texture)
end


local function AcquireTextures(frame)

    --Different settings depending on noteType
    local globalScale = Questie.db.global.globalScale or 0.7

    --Count the number of pins to place them in the correct place.
    local count = 0;
    
    for pinType, typeData in pairs(frame.questData) do
      for index, questData in pairs(typeData) do
        --This count is used for positioning of the icons later.
        count = count + 1;
      end
    end

    --Increase the width to match the number of icons.
    frame:SetWidth(16+(count*(16/2)));

    --What icon are we currently drawing.
    local iconIndex = 0;

    for rawPinType, typeData in pairs(frame.questData) do
      --Here we fetch the texture for each used pinType
      local textures = {}
      for index, questData in pairs(typeData) do
        --Fetch the color used for the objective.
        ---@class TextureData
        local textureData = {}

        --Populate data for the texture
        textureData.pinTypeId = QuestieFrameNew.stringEnum[rawPinType];
        textureData.questId = questData.questId;

        textureData.textureId = QuestieFrameNew.stringEnum[typeLookup[textureData.pinTypeId]:GetIcon(questData.questId)];


        if(questData.objectiveIndex) then
          --Fetch the generated color
          local quest = QuestieDB:GetQuest(questData.questId);
          if(quest and quest.Objectives and quest.Objectives[questData.objectiveIndex].Color) then
            textureData.color = quest.Objectives[questData.objectiveIndex].Color;
          else
            textureData.color = {1, 1, 1, 1};
          end

          --We do this because tooltip needs this data to generate.
          textureData.objectiveIndex = questData.objectiveIndex;
        end

        if(questData.targetType) then
          textureData.targetType = questData.targetType;
        end
        if(questData.targetId) then
          textureData.targetId = questData.targetId;
        end
        if(not textures[textureData.questId]) then
          textures[textureData.questId] = {}
        end
        if(questData.objectiveIndex) then
          textures[textureData.questId][questData.objectiveIndex] = textureData;
        else
          textures[textureData.questId][0] = textureData;
        end
      end

      --Here we draw all the textures that exist on the icon.
      for questId, questDataList in pairs(textures) do
        ---@param textureData TextureData
        for objectiveIndex, textureData in pairs(questDataList) do
          --- Textures
          --We want the textureData to be Serialized to save space.
          ---@class IconTextureNew
          local newTexture = setmetatable(texturePool:Acquire(), {
            __index = function(textureTable, key)
              if key == "textureData" and textureTable[key] then
                  return QuestieSerializer:Deserialize(textureTable[key]);
              else
                  return textureTable[key]
              end
            end,
            __newindex = function(textureTable, key, value)
              if(key == "textureData") then
                rawset(textureTable, key, QuestieSerializer:Serialize(value))
              else
                rawset(textureTable, key, value)
              end
            end
          })
          newTexture.textureData = textureData;


          local iconPos = 0
          local glowPos = 0;
          if(count > 1) then
            iconPos = ((count * (16/2))*-1)+(count * (16/2))*iconIndex;
            glowPos = (((count * (16/2))*-1)+(count * (16/2))*iconIndex);
          else
            iconPos = 0;
            glowPos = 0;
          end

          newTexture:SetTexture(typeLookup[textureData.pinTypeId]:GetIcon(textureData.questId));
          newTexture:SetParent(frame);
          newTexture:SetDrawLayer("OVERLAY", typeLookup[textureData.pinTypeId]:GetDrawLayer())
          newTexture:SetPoint("CENTER", frame, "CENTER", iconPos, 0);
          if(Questie.db.global.questObjectiveColors) then
            newTexture:SetVertexColor(unpack(textureData.color));
          end
          newTexture:SetSize((16 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale, (16 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale)
          newTexture:Show();

          if(textureData.pinTypeId ~= QuestieFrameNew.stringEnum["available"] and textureData.pinTypeId ~= QuestieFrameNew.stringEnum["complete"] and Questie.db.global.alwaysGlowMap) then
            local glowt = texturePool:Acquire();
            glowt:SetTexture(ICON_TYPE_GLOW)
            glowt:SetVertexColor(unpack(textureData.color));
            glowt:SetDrawLayer("OVERLAY", -1)
            glowt:SetParent(frame);
            glowt:SetPoint("CENTER", frame, "CENTER", glowPos, 0);
            glowt:SetSize((18 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale, (18 * typeLookup[textureData.pinTypeId]:GetIconScale())*globalScale)
            glowt:Show();

            newTexture.glowTexture = glowt
          end

          iconIndex = iconIndex +1;
          table.insert(frame.textures, newTexture);
        end
      end
    end

end

local function ReleaseTextures(frame)
  if(frame.glowTexture) then
    texturePool:Release(frame.glowTexture);
    frame.glowTexture = nil;
  end
  if(frame.texture) then
    texturePool:Release(frame.texture);
    frame.texture = nil;
  end
  if(frame.textures) then
    for index, tex in pairs(frame.textures) do
      if(tex.glowTexture) then
        texturePool:Release(tex.glowTexture);
      end
      texturePool:Release(tex);
    end
    frame.textures = {};
  end
end



local iconPool = CreateFramePool("BUTTON");
local worldmapProvider     = CreateFromMixins(MapCanvasDataProviderMixin)
local worldmapProviderPin  = CreateFromMixins(MapCanvasPinMixin)

-------------------------------------------------------------------------------------------
-- WorldMap data provider
local frameId = 0;
-- setup pin pool
--AcquirePin runs framepool:Acquire which runs this function
iconPool.parent = WorldMapFrame:GetCanvas()
iconPool.creationFunc = function(framePool)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] Creating frame from pool");
    local frame = CreateFrame(framePool.frameType, nil, framePool.parent)
    frame:SetSize(16,16);
    frame.frameId = frameId;

    --- Data members
    frame.questData = {}
    frame.textures = {}

    ---Functions



    frameId = frameId + 1;
    return Mixin(frame, worldmapProviderPin)
end

iconPool.resetterFunc = function(pinPool, pin)
    FramePool_HideAndClearAnchors(pinPool, pin)
    pin:OnReleased()

    pin.pinTemplate = nil
    pin.owningMap = nil
end

-- register pin pool with the world map
WorldMapFrame.pinPools["PinsTemplateQuestie"] = iconPool

-- provider base API
function worldmapProvider:RemoveAllData()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] RemoveAllData");
  self:GetMap():RemoveAllPinsByTemplate("PinsTemplateQuestie")
end

function worldmapProvider:RemovePinByIcon(icon)
  for pin in self:GetMap():EnumeratePinsByTemplate("PinsTemplateQuestie") do
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew]", pin);
    --self:GetMap():RemovePin(pin)
  end
end

function worldmapProvider:RefreshAllData(fromOnShow)
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] RefreshAllData : ", fromOnShow);
  local mapId = self:GetMap():GetMapID()
  self:RemoveAllData()

  --Map icons are disabled.
  if(not Questie.db.global.enableMapIcons) then return; end

  local enableAvailable = Questie.db.global.enableAvailable;
  local enableTurnins = Questie.db.global.enableTurnins;
  local enableObjectives = Questie.db.global.enableObjectives;

  --temporary should be moved.
  if(not QuestieFrameNew.utils.zoneList) then
    QuestieFrameNew.utils:GenerateCloseZones();
  end

  local closeZones = QuestieFrameNew.utils.zoneList[mapId];

  local allPins = {};

  --Available quests
  if (enableAvailable) then
    for questId, _ in pairs(QuestieQuest.availableQuests) do
      local quest = QuestieDB:GetQuest(questId);
      for index, position in pairs(quest.starterLocations) do
        if(closeZones[position.UIMapId]) then
          local x, y = HBD:TranslateZoneCoordinates(position.x/100, position.y/100, position.UIMapId, mapId);
          if(x and y) then
            table.insert(allPins, position);
          end
        end
      end
    end
  end

  for questId, questData in pairs(QuestiePlayer.currentQuestlog) do
    Questie:Print("--Adding quest -> ", questId)
    local quest = questData;
    if(type(questData) == "number") then
      quest = QuestieDB:GetQuest(questId);
    end

    --Complete quests
    if (enableTurnins) then
        if(quest.finisherLocations) then
          for index, position in pairs(quest.finisherLocations) do
            if(closeZones[position.UIMapId]) then
              local x, y = HBD:TranslateZoneCoordinates(position.x/100, position.y/100, position.UIMapId, mapId);
              if(x and y) then
                table.insert(allPins, position);
              end
            end
          end
        end
    end

    --Objectives
    if(enableObjectives) then
      if(quest.objectiveIcons) then
        for objectiveIndex, spawnData in pairs(quest.objectiveIcons) do
          Questie:Print("---->", objectiveIndex)
          for index, spawn in pairs(spawnData) do
            if(closeZones[spawn.UIMapId]) then
              local x, y = HBD:TranslateZoneCoordinates(spawn.x/100, spawn.y/100, spawn.UIMapId, mapId);
              if(x and y) then
                Questie:Print("------->ADDED PIN:", x,y);
                table.insert(allPins, spawn);
              end
            end
          end
        end
      end
    end
  end

  Questie:Print("--------------------------------------------------------------------")
  Questie:Debug(DEBUG_ELEVATED, "Drawing icons, current size of icon list:", #allPins);
  local hotzones = QuestieMap.utils:CalcHotzones(allPins, 70, #allPins);

  for _, positions in pairs(hotzones) do
      local center = QuestieMap.utils:CenterPoint(positions)

      local questData = {}
      for _, positionData in pairs(positions) do
        --Questie:Print(positionData.pinType, positionData)
        if(not questData[positionData.pinType] ) then
          questData[positionData.pinType] = {}
        end
        table.insert(questData[positionData.pinType], positionData);
      end

      local x, y = HBD:TranslateZoneCoordinates(center.x/100, center.y/100, positions[1].UIMapId, mapId);

      if(x and y) then

        Questie:Print(x, y, center.x/100, center.y/100, positions[1].UIMapId, mapId);
        --Hide unexplored logic
        if(not QuestieMap.utils:IsExplored(mapId, x, y) and Questie.db.global.hideUnexploredMapIcons) then
          self:GetMap():AcquirePin("PinsTemplateQuestie", "NotUsed", questData, x, y);--data.frameLevelType)
        elseif(not Questie.db.global.hideUnexploredMapIcons) then
          self:GetMap():AcquirePin("PinsTemplateQuestie", "NotUsed", questData, x, y);--data.frameLevelType)
        end
      end
  end

  --self:GetMap():AcquirePin("PinsTemplateQuestie", "objective", {}, 0.5, 0.5);--data.frameLevelType)
end

--  map pin base API
function worldmapProviderPin:OnLoad()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnLoad");
  self:UseFrameLevelType("PIN_FRAME_LEVEL_AREA_POI")
  self:SetScalingLimits(1, 1.0, 1.2)
end

function worldmapProviderPin:OnAcquired(pinType, questData, x, y, frameLevelType)
    Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnAcquired", pinType, x, y, questData);
    self:UseFrameLevelType(frameLevelType or "PIN_FRAME_LEVEL_AREA_POI")
    self:SetPosition(x, y)
    self.questData = questData;
    self.pinType = pinType; --not used or correct
    self.position = {x=x, y=y, z=nil}; --Insert heightmap

    AcquireTextures(self);

    self:Show();
end

function worldmapProviderPin:OnReleased()
  Questie:Debug(DEBUG_DEVELOP, "[QuestieFrameNew] OnReleased");
  self.questData = {};
  self.pinType = "";
  self.poisition = nil;
  --Reset the width incase we've previously been a combined icon.
  self:SetWidth(16);
  ReleaseTextures(self);
  if self.icon then
      --self.icon:Hide()
      --self.icon:SetParent(UIParent)
      --self.icon:ClearAllPoints()
      --self.icon = nil
  end
end

function worldmapProviderPin:OnClick(button)
  -- Override in your mixin, called when this pin is clicked
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnClick", button);
end

---@param textureData TextureData
---@return string
local function GetName(textureData)
  if(textureData and textureData.targetId) then
    if(textureData.targetType == "monster") then
      return QuestieDB:GetNPC(textureData.targetId).name;
    elseif(textureData.targetType == "item") then
      return QuestieDB:GetItem(textureData.targetId).name;
    elseif(textureData.targetType == "object") then
      return QuestieDB:GetObject(textureData.targetId).name;
    elseif(textureData.targetType == "event") then
      return QuestieDB:GetQuest(textureData.questId).Objectives[textureData.objectiveIndex].Description or "Event Trigger";
    end
  end
  return "TYPE NOT IMPLEMENTED?";
end

function worldmapProviderPin:OnMouseEnter()
	-- Override in your mixin, called when the mouse enters this pin
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseEnter", self.questData[1].Id, self.questData[1].name);

  
  local tooltips = {};
  ---@param texture IconTextureNew
  for _, texture in pairs(self.textures) do
    ---@type TextureData
    local textureData = texture.textureData;
    if(QuestieFrameNew.stringEnum["available"] == textureData.pinTypeId) then
      local name = GetName(textureData);
      if(not tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]][name]) then
        tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]][name] = {}
      end
      ---@type AvailableTooltip
      local tooltipData = GetAvailableOrCompleteTooltip(textureData);
      table.insert(tooltips[QuestieFrameNew.stringEnum[textureData.pinTypeId]][name], tooltipData);
    end
  end

  --[[for rawPinType, typeData in pairs(self.questData) do
    if(not tooltips[rawPinType]) then
      tooltips[rawPinType] = {}
    end
    if(rawPinType == "available" or rawPinType == "complete") then
      for index, questData in pairs(typeData) do
        local name = questData:GetName();
        if(not tooltips[rawPinType][name]) then
          tooltips[rawPinType][name] = {}
        end
        ---@type AvailableTooltip
        local tooltipData = GetAvailableOrCompleteTooltip(questData);
        table.insert(tooltips[rawPinType][name], GetAvailableOrCompleteTooltip(questData));
      end
    end
  end]]--

  local Tooltip = GameTooltip;
  Tooltip._owner = self;
  Tooltip:SetOwner(self, "ANCHOR_CURSOR"); --"ANCHOR_CURSOR" or (self, self)
  function Tooltip:_Rebuild()
    local xpString = QuestieLocale:GetUIString('XP');
    local shift = IsShiftKeyDown()
    for name, tooltipData in pairs(tooltips["available"] or {}) do
      self:AddLine(name);
      ---@param questInfo AvailableTooltip
      for _, questInfo in pairs(tooltipData) do
        self:AddDoubleLine(questInfo.title, questInfo.type);
        if(shift) then
          self:AddLine(questInfo.description)
        end
      end
    end
  end

end

--Available / Complete
--local loc = {}
--loc.x = x;
--loc.y = y;
--loc.UIMapId = ZoneDataAreaIDToUiMapID[zone];
--loc.pinType = "available" / "complete";
--loc.questId = quest.Id;
--loc.targetType = "monster" / "object"
--loc.targetId = finisher.id;
--function loc:GetName()

---@param textureData TextureData
function GetAvailableOrCompleteTooltip(textureData)
  ---@class AvailableTooltip
  local tip = {};
  local quest = QuestieDB:GetQuest(textureData.questId);
  if(quest) then

    if textureData.pinTypeId == QuestieFrameNew.stringEnum["complete"] then
        tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_COMPLETE");
    else
        local questType, questTag = GetQuestTagInfo(textureData.questId);
        if(quest.Repeatable) then
            tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_REPEATABLE");--"(Repeatable)"; --
        elseif(questType == 81 or questType == 83 or questType == 62 or questType == 41 or questType == 1) then
            -- Dungeon or Legendary or Raid or PvP or Group(Elite)
            tip.type = "("..questTag..")";
        elseif(QuestieEvent and QuestieEvent.activeQuests[quest.Id]) then
            tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_EVENT");--"(Event)";--QuestieLocale:GetUIString("TOOLTIP_QUEST_AVAILABLE");
        else
            tip.type = QuestieLocale:GetUIString("TOOLTIP_QUEST_AVAILABLE");
        end
    end
    tip.type = QuestieFrameNew.stringEnum[textureData.pinTypeId];
    tip.title = quest:GetColoredQuestName(true)
    tip.description = quest.Description
    tip.questId = quest.Id;
  end

  return tip;
end

function worldmapProviderPin:OnMouseLeave()
	-- Override in your mixin, called when the mouse leaves this pin
  Questie:Print(DEBUG_DEVELOP, "[QuestieFrameNew] OnMouseLeave", self);
end

-- register with the world map
WorldMapFrame:AddDataProvider(worldmapProvider)
