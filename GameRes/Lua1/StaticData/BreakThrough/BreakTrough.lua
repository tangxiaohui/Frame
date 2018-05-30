require "StaticData.Manager"

local BreakTroughData = Class(LuaObject)
function BreakTroughData:Ctor(id)
    local BreakTroughMgr = Data.BreakTrough.Manager.Instance()
    -- 数据本身
    self.data = BreakTroughMgr:GetObject(id)
    if self.data == nil then
        error(string.format("突破数据不存在, ID: %s 不存在", id))
        return
    end
    -- 本地化
    self.infoData = require "StaticData.BreakThrough.BreakTroughInfo":GetData(self.data.breakTroughInfo)
end

function BreakTroughData:GetId()
    return self.data.id
end

function BreakTroughData:GetName()
    return self.infoData:GetTalentName()
end

function BreakTroughData:GetCardLevel()
    return self.data.cardLevel
end

function BreakTroughData:GetMaxExp()
    return self.data.maxExp
end

function BreakTroughData:GetMinAdd()
    return self.data.minAdd
end

function BreakTroughData:GetRange()
    return self.data.range
end

function BreakTroughData:GetSuccessRate()
    return self.data.successRate
end

function BreakTroughData:GetStatusType()
    return self.data.statusType
end

function BreakTroughData:GetStatusNum()
    return self.data.statusNum
end

function BreakTroughData:GetNeedType()
    return self.data.needType
end

function BreakTroughData:GetAllProperties(propertySet)
    propertySet = propertySet or require "Game.Property.PropertySet".New()
    local powerTypes = self:GetStatusType()
    local powerValues = self:GetStatusNum()
    local count = powerTypes.Count - 1
    for i = 0, count do
        local propertyId = powerTypes[i]
        if propertyId > 0 then
            propertySet:AddValue(propertyId, powerValues[i])
        end
    end
    return propertySet
end

local BreakTroughDataManager = Class(DataManager)

local BreakTroughDataMgr = BreakTroughDataManager.New(BreakTroughData)
return BreakTroughDataMgr