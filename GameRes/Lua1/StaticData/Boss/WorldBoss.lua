require "StaticData.Manager"
require "Collection.OrderedDictionary"

WorldBossData = Class(LuaObject)
function WorldBossData:Ctor(id)
    local WorldBossMgr = Data.WorldBoss.Manager.Instance()
    self.data = WorldBossMgr:GetObject(id)
    if self.data == nil then
        error(string.format("Boss信息不存在，ID: %s 不存在", id))
        return
    end
end
function WorldBossData:GetID()
    return self.data.id
end

function WorldBossData:GetChallengetimes()
    return self.data.challengetimes
end

function WorldBossData:GetRecovertime()
    return self.data.recovertime
end

function WorldBossData:GetChargedya()
    return self.data.chargedya
end

function WorldBossData:GetDailyDungeonTimes()
    return self.data.dailydungeontimes
end

function WorldBossData:GetDailyDungeonFrequency()
    return self.data.dailydungeonfrequency
end

function WorldBossData:GetDailyDungeonSweepTime()
    return self.data.dailydungeonsweeptime
end

function WorldBossData:GetRandomEventTimes()
    return self.data.randomeventtimes
end

function WorldBossData:GetRandomEventFrequency()
    return self.data.randomeventfrequency
end


function WorldBossData:GetRandomEventSweepTime()
    return self.data.randomeventsweeptime
end

function WorldBossData:GetSceneId()
    return self.data.sceneId
end



local WorldBossManager = Class(DataManager)

local WorldBossMgr = WorldBossManager.New(WorldBossData)
return WorldBossMgr