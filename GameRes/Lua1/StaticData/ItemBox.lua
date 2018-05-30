require "StaticData.Manager"

ItemInfoData = Class(LuaObject)

function ItemInfoData:Ctor(id)
    local itemInfoMgr = Data.ItemBox.Manager.Instance()
    self.data = itemInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("任意宝箱，ID: %s 不存在", id))
        return
    end
end

function ItemInfoData:GetId()
    return self.data.id
end

function ItemInfoData:GetBoxid()
    return self.data.Boxid
end

function ItemInfoData:GetItemID()
    return self.data.itemID
end

function ItemInfoData:GetItemNum()
    return self.data.itemNum
end

function ItemInfoData:GetResource()
    return self.data.resource
end

ItemInfoManager = Class(DataManager)

local itemInfoManager = ItemInfoManager.New(ItemInfoData)

function itemInfoManager:GetKeys()
	return Data.ItemBox.Manager.Instance():GetKeys()
end

return itemInfoManager