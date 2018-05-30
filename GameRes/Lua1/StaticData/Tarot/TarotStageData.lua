
require "Class"

local TarotStageData = Class()

function TarotStageData:Ctor(stage, itemId, itemNum, propertyId, propertyValue)
    self.stage = stage
    self.itemId = itemId
    self.itemNum = itemNum
    self.propertyId = propertyId
    self.propertyValue = propertyValue
end

function TarotStageData:GetStage()
    return self.stage
end

function TarotStageData:GetItemId()
    return self.itemId
end

function TarotStageData:GetItemNum()
    return self.itemNum
end

function TarotStageData:GetPropertyId()
    return self.propertyId
end

function TarotStageData:GetPropertyValue()
    return self.propertyValue
end

return TarotStageData
