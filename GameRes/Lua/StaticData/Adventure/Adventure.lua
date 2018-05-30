require "StaticData.Manager"
require "Collection.OrderedDictionary"

AdventureData = Class(LuaObject)
function AdventureData:Ctor(id)
    local AdventureMgr = Data.Adventure.Manager.Instance()
    self.data = AdventureMgr:GetObject(id)
    if self.data == nil then
        error(string.format("Boss信息不存在，ID: %s 不存在", id))
        return
    end
end
function AdventureData:GetID()
    return self.data.id
end
function AdventureData:GetMaxTimes()
    return self.data.maxTimes
end
function AdventureData:GetRecoverTime()
    return self.data.recoverTime
end
function AdventureData:GetBuyTime()
    return self.data.buyTime
end

function AdventureData:GetOneTime()
    return self.data.oneTime
end

function AdventureData:GetFiveTime()
    return self.data.fiveTime
end
function AdventureData:GetTenTime()
    return self.data.tenTime
end

local AdventureManager = Class(DataManager)

local AdventureMgr = AdventureManager.New(AdventureData)
return AdventureMgr