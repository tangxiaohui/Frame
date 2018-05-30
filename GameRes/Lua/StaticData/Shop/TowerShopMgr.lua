require "StaticData.Manager"

TowerShopData = Class(LuaObject)

function TowerShopData:Ctor(id)
    local TowerShopMgr = Data.TowerShop.Manager.Instance()
    self.data = TowerShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("爬塔商店信息不存在，ID: %s 不存在", id))
        return
    end
end

function TowerShopData:GetId()
    return self.data.id
end

function TowerShopData:GetItemID()
    return self.data.itemID
end

function TowerShopData:GetItemNum()
    return self.data.itemNum
end

function TowerShopData:GetItemColor()
    return self.data.itemColor
end

function TowerShopData:GetNeedItemID()
    return self.data.needItemID
end

function TowerShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function TowerShopData:GetShowMsg()
    return self.data.showMsg
end

function TowerShopData:GetType()
    return self.data.type
end

function TowerShopData:GetProp()
    return self.data.prop
end

function TowerShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



TowerShopManager = Class(DataManager)

local TowerShopDataMgr = TowerShopManager.New(TowerShopData)
return TowerShopDataMgr