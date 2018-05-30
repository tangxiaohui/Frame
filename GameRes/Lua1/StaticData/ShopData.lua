require "StaticData.Manager"

ShopData = Class(LuaObject)

function ShopData:Ctor(id)
    local ShopMgr = Data.Shop.Manager.Instance()
    self.data = ShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function ShopData:GetId()
    return self.data.id
end

function ShopData:GetItemID()
    return self.data.itemID
end

function ShopData:GetItemNum()
    return self.data.itemNum
end

function ShopData:GetItemColor()
    return self.data.itemColor
end

function ShopData:GetNeedItemID()
    return self.data.needItemID
end

function ShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function ShopData:GetShowMsg()
    return self.data.showMsg
end

function ShopData:GetType()
    return self.data.type
end

function ShopData:GetProp()
    return self.data.prop
end

function ShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



ShopManager = Class(DataManager)

local ShopDataMgr = ShopManager.New(ShopData)
return ShopDataMgr