require "StaticData.Manager"

TowerSecretShopData = Class(LuaObject)

function TowerSecretShopData:Ctor(id)
    local TowerShopMgr = Data.TowerSecretShop.Manager.Instance()
    self.data = TowerShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("爬塔神秘商店信息不存在，ID: %s 不存在", id))
        return
    end
end

function TowerSecretShopData:GetId()
    return self.data.id
end

function TowerSecretShopData:GetItemID()
    return self.data.itemID
end

function TowerSecretShopData:GetItemNum()
    return self.data.itemNum
end

function TowerSecretShopData:GetItemColor()
    return self.data.itemColor
end

function TowerSecretShopData:GetNeedItemID()
    return self.data.needItemID
end

function TowerSecretShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function TowerSecretShopData:GetShowMsg()
    return self.data.showMsg
end

function TowerSecretShopData:GetType()
    return self.data.type
end

function TowerSecretShopData:GetProp()
    return self.data.prop
end

function TowerSecretShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



TowerShopManager = Class(DataManager)

local TowerShopDataMgr = TowerShopManager.New(TowerSecretShopData)
return TowerShopDataMgr