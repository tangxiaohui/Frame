require "StaticData.Manager"

TeamTalentInfoData = Class(LuaObject)
function TeamTalentInfoData:Ctor(id)
    local TeamTalentInfoDataMgr = Data.TeamTalentInfo.Manager.Instance()
    self.data = TeamTalentInfoDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色天赋信息数据不存在，ID: %s 不存在", id))
        return
    end
end

function TeamTalentInfoData:GetTalentName()
    return self.data.talentName
end

function TeamTalentInfoData:GetTalentDes()
    return self.data.talentDes
end

TeamTalentInfoDataManager = Class(DataManager)

local TeamTalentInfoDataMgr = TeamTalentInfoDataManager.New(TeamTalentInfoData)
return TeamTalentInfoDataMgr