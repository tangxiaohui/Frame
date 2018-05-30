require "StaticData.Manager"
require "Collection.OrderedDictionary"

AdventureAwardData = Class(LuaObject)
function AdventureAwardData:Ctor(id)
    local AdventureAwardMgr = Data.AdventureAward.Manager.Instance()
    self.data = AdventureAwardMgr:GetObject(id)
    if self.data == nil then
        error(string.format("AdventureAwardData信息不存在，ID: %s 不存在", id))
        return
    end
end
function AdventureAwardData:GetID()
    return self.data.id
end

function AdventureAwardData:GetInfo()
    return self.data.info
end

function AdventureAwardData:GetAwardType()
    return self.data.awardtype
end

function AdventureAwardData:GetItemType()
    return self.data.itemType
end

function AdventureAwardData:GetItemNum()
    return self.data.itemNum
end

function AdventureAwardData:GetChallengeType()
    return self.data.challengeType
end

function AdventureAwardData:GetChallengeNum()
    return self.data.challengeNum
end

function AdventureAwardData:GetProp()
    return self.data.prop
end

function AdventureAwardData:GetMaxTimes()
    return self.data.maxTimes
end



local AdventureAwardManager = Class(DataManager)

local AdventureAwardMgr = AdventureAwardManager.New(AdventureAwardData)
return AdventureAwardMgr