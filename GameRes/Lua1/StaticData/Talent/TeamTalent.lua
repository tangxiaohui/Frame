require "StaticData.Manager"

TeamTalentData = Class(LuaObject)

function TeamTalentData:Ctor(id)
    local TeamTalentDataMgr = Data.TeamTalent.Manager.Instance()
    self.data = TeamTalentDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色团队天赋信息数据不存在，ID: %s 不存在", id))
        return
    end
end

function TeamTalentData:GetID()
    return self.data.id
end

function TeamTalentData:GetInfo()
    return self.data.info
end

function TeamTalentData:GetResourceID()
    return self.data.resourceID
end
function TeamTalentData:GetRacialType()
    return self.data.racialType
end

TeamTalentDataManager = Class(DataManager)

local TeamTalentDataMgr = TeamTalentDataManager.New(TeamTalentData)
return TeamTalentDataMgr