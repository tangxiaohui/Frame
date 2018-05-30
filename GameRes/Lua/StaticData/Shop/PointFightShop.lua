require "StaticData.Manager"

PointFightShopData = Class(LuaObject)

function PointFightShopData:Ctor(id)
    local PointFightShopMgr = Data.PointFightShop.Manager.Instance()
    self.data = PointFightShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("公会积分战商店信息不存在，ID: %s 不存在", id))
        return
    end
end

function PointFightShopData:GetId()
    return self.data.id
end

function PointFightShopData:GetItemID()
    return self.data.itemID
end

function PointFightShopData:GetItemNum()
    return self.data.itemNum
end

function PointFightShopData:GetItemColor()
    return self.data.itemColor
end

function PointFightShopData:GetNeedItemID()
    return self.data.needItemID
end

function PointFightShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function PointFightShopData:GetShowMsg()
    return self.data.showMsg
end

function PointFightShopData:GetType()
    return self.data.type
end

function PointFightShopData:GetProp()
    return self.data.prop
end

function PointFightShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



PointFightShopManager = Class(DataManager)

local PointFightShopDataMgr = PointFightShopManager.New(PointFightShopData)
return PointFightShopDataMgr