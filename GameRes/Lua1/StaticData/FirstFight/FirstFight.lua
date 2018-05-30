
require "StaticData.Manager"

local FirstFightData = Class(LuaObject)

function FirstFightData:Ctor(id)
    local firstFightMgr = Data.FirstFight.Manager.Instance()
    self.data = firstFightMgr:GetObject(id)
    if self.data == nil then
        error(string.format("第一场战斗副本地图不存在: %d", id))
    end
end

function FirstFightData:GetId()
    return self.data.id
end

function FirstFightData:GetMapID()
    return self.data.mapid
end

function FirstFightData:GetAbleSkillWave()
    return self.data.AbleSkillWave
end


local FirstFightManager = Class(DataManager)
return FirstFightManager.New(FirstFightData)
