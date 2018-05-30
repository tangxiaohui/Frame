require "Class"
require "Collection.OrderedDictionary"

local TarotData = Class()

function TarotData:Ctor()
    self.tarotStateMap = OrderedDictionary.New()
    self.progressId = 0
end

-- 协议接口

local function UpdateAllCards(self, cards)
    self.tarotStateMap:Clear()
    for i = 1, #cards do
        local currentCard = cards[i]
        self.tarotStateMap:Add(currentCard.id, currentCard.flags)
    end
end

function TarotData:UpdateAll(msg)
    UpdateAllCards(self, msg.cards)
    self.progressId = msg.progressId
end

function TarotData:UpdateTarotCard(msg)
    self.tarotStateMap:Set(msg.newState.id, msg.newState.flags)
end

function TarotData:UpdateTarotProgress(msg)
    self.progressId = msg.newProgressId
end

-- 公有接口

-- 获取指定塔罗牌的状态
function TarotData:GetTarotFlags(tarotId)
    return self.tarotStateMap:GetEntryByKey(tarotId)
end

-- 获取一共多少张卡
function TarotData:GetNumOfTarotCards()
    local number = 0
    local count = self.tarotStateMap:Count()
    for i = 1, count do
        local flags = self.tarotStateMap:GetEntryByIndex(i)
        if flags ~= nil then
            number = number + flags
        end
    end
    return number
end

-- 获取当前进度ID
function TarotData:GetTarotProgressId()
    return self.progressId
end

-- 获取所有属性
function TarotData:GetAllProperies(propertySet)

    -- debug_print("@@@@ 开始更新塔罗牌属性 @@@@")

    propertySet = propertySet or require "Game.Property.PropertySet".New()

    -- # 加成塔罗牌本身属性
    local count = self.tarotStateMap:Count()
    for i = 1, count do
        local tarotId = self.tarotStateMap:GetKeyFromIndex(i)
        local stage = self.tarotStateMap:GetEntryByIndex(i)
        if stage ~= nil then
            local tarotData = require "StaticData.Tarot.Tarot":GetData(tarotId)
            local propertyId = tarotData:GetStagePropertyId(stage)
            if propertyId > 0 then
                -- debug_print("塔罗牌ID:", tarotId, "阶:", stage, "属性ID:", propertyId, "属性值:", tarotData:GetStagePropertyValue(stage))
                propertySet:AddValue(propertyId, tarotData:GetStagePropertyValue(stage))
            end
        end
    end

    -- # 加成塔罗牌进度属性
    local progressData = require "StaticData.Tarot.TarotProgress":GetData(self:GetTarotProgressId())
    progressData:GetProperties(propertySet)

    -- debug_print("@@@@ 完成更新塔罗牌属性 @@@@")

    return propertySet
end

return TarotData
