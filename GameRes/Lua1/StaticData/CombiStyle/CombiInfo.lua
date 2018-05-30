require "StaticData.Manager"

CombiInfoData = Class(LuaObject)

function CombiInfoData:Ctor(id)
    local CombiInfoMgr = Data.CombiInfo.Manager.Instance()
    self.data = CombiInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("流派信息不存在，ID: %s 不存在", id))
        return
    end
end

function CombiInfoData:GetId()
    return self.data.id
end

function CombiInfoData:GetTitle()
    return self.data.title
end
function CombiInfoData:GetDescription()
    return self.data.description
end


CombiInfoManager = Class(DataManager)

local CombiInfoDataMgr = CombiInfoManager.New(CombiInfoData)
return CombiInfoDataMgr