require "StaticData.Manager"

ItemInfoData = Class(LuaObject)

function ItemInfoData:Ctor(id)
    local itemInfoMgr = Data.ItemInfo.Manager.Instance()
    self.data = itemInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function ItemInfoData:GetId()
    return self.data.id
end

function ItemInfoData:GetName()
    return self.data.name
end

function ItemInfoData:GetDesc()
    return self.data.desc
end

ItemInfoManager = Class(DataManager)

local itemInfoManager = ItemInfoManager.New(ItemInfoData)
return itemInfoManager