require "StaticData.Manager"

DrawPoolData = Class(LuaObject)

function DrawPoolData:Ctor(id)
    local DrawPoolMgr = Data.DrawPool.Manager.Instance()
    
    self.data = DrawPoolMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌皮肤关联信息不存在，ID: %s 不存在", id))
        return
    end
end

function DrawPoolData:GetId()
    return self.data.id
end

function DrawPoolData:GetDescription()
    return self.data.description
end

DrawPoolManager = Class(DataManager)

local DrawPoolDataMgr = DrawPoolManager.New(DrawPoolData)
return DrawPoolDataMgr