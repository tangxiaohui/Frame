require "StaticData.Manager"

SkininfoData = Class(LuaObject)

function SkininfoData:Ctor(id)
    local SkininfoMgr = Data.Skininfo.Manager.Instance()
    
    self.data = SkininfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌皮肤描述信息不存在，ID: %s 不存在", id))
        return
    end
end

function SkininfoData:GetId()
    return self.data.id
end

function SkininfoData:GetInfo()
    return self.data.info
end

function SkininfoData:GetDescription()
    return self.data.description
end

SkininfoManager = Class(DataManager)

local SkininfoDataMgr = SkininfoManager.New(SkininfoData)
return SkininfoDataMgr