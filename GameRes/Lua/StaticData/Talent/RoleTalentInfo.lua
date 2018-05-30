require "StaticData.Manager"

RoleTalentInfoData = Class(LuaObject)
function RoleTalentInfoData:Ctor(id)
    local TalentInfoDataMgr = Data.RoleTalentInfo.Manager.Instance()
    self.data = TalentInfoDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("角色天赋信息数据不存在，ID: %s 不存在", id))
        return
    end
end

function RoleTalentInfoData:GetTalentName()
    return self.data.talentName
end

function RoleTalentInfoData:GetTalentDes()
    return self.data.talentDes
end

TalentInfoDataManager = Class(DataManager)

local TalentInfoDataMgr = TalentInfoDataManager.New(RoleTalentInfoData)
return TalentInfoDataMgr