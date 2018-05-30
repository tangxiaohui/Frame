require "StaticData.Manager"

local TarotProgressData = Class()

function TarotProgressData:Ctor(id)
    local TarotProgressManager = Data.TarotProgress.Manager.Instance()
    self.data = TarotProgressManager:GetObject(id)
    if self.data == nil then
        error(string.format("塔罗牌进度表数据不存在, ID: %s 不存在", id))
    end
end

function TarotProgressData:GetId()
    return self.data.id
end

function TarotProgressData:GetNextId()
    return self.data.nextId
end

function TarotProgressData:GetConditionTarotNum()
    return self.data.progressNum
end

function TarotProgressData:GetItemId()
    return self.data.itemType
end

function TarotProgressData:GetItemNum()
    return self.data.needNum
end

function TarotProgressData:GetProperties(propertySet)
    propertySet = propertySet or require "Game.Property.PropertySet".New()
    local count = self.data.powerType.Count-1
    for i = 0, count do
        -- debug_print("塔罗牌进度光环ID:", self:GetId(), "属性ID:", self.data.powerType[i], "属性值:", self.data.powerNum[i])
        propertySet:AddValue(self.data.powerType[i], self.data.powerNum[i])
    end
    return propertySet
end

local TarotProgressDataManager = Class(DataManager)
return TarotProgressDataManager.New(TarotProgressData)
