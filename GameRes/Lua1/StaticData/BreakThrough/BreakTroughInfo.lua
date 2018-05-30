require "StaticData.Manager"

BreakTroughInfoData = Class(LuaObject)
function BreakTroughInfoData:Ctor(id)
    local TalentInfoDataMgr = Data.BreakTroughInfo.Manager.Instance()
    self.data = TalentInfoDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("突破信息数据不存在，ID: %s 不存在", id))
        return
    end
end

function BreakTroughInfoData:GetTalentName()
    return self.data.tarotName
end

TalentInfoDataManager = Class(DataManager)

local TalentInfoDataMgr = TalentInfoDataManager.New(BreakTroughInfoData)
return TalentInfoDataMgr