require "StaticData.Manager"
require "Collection.OrderedDictionary"

WorldBossChallengtimesData = Class(LuaObject)
function WorldBossChallengtimesData:Ctor(id)
    local WorldBossChallengtimesDataMgr = Data.WorldBossChallengtimes.Manager.Instance()
    self.data = WorldBossChallengtimesDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("WorldBossChallengtimes信息不存在，ID: %s 不存在", id))
        return
    end
end
function WorldBossChallengtimesData:GetID()
    return self.data.id

end

function WorldBossChallengtimesData:GetTimes()
    return self.data.times
end

function WorldBossChallengtimesData:GetAttackRate()

    return self.data.attackrate
end

function WorldBossChallengtimesData:GetAdditem()
    return self.data.additem
end

function WorldBossChallengtimesData:GetAddItemNum()
    return self.data.additemnum
end

function WorldBossChallengtimesData:GetAddItemPrice()
    return self.data.additemprice
end



local WorldBossChallengtimesManager = Class(DataManager)

local WorldBossChallengtimesMgr = WorldBossChallengtimesManager.New(WorldBossChallengtimesData)
return WorldBossChallengtimesMgr