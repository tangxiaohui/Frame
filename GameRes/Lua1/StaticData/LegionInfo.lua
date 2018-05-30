require "StaticData.Manager"

LegionInfoData = Class(LuaObject)

function LegionInfoData:Ctor(id)
    local LegionInfoMgr = Data.LegionInfo.Manager.Instance()
    self.data = LegionInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团信息不存在，ID: %s 不存在", id))
        return
    end
end

function LegionInfoData:GetId()
    return self.data.id
end

function LegionInfoData:GetName()
    return self.data.name
end

LegionInfoManager = Class(DataManager)

local LegionInfoDataMgr = LegionInfoManager.New(LegionInfoData)
return LegionInfoDataMgr