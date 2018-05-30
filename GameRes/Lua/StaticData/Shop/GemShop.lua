require "StaticData.Manager"

GemShopData = Class(LuaObject)

function GemShopData:Ctor(id)
    local GemShopMgr = Data.GemShop.Manager.Instance()
    self.data = GemShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("宝石信息不存在，ID: %s 不存在", id))
        return
    end
end

function GemShopData:GetId()
    return self.data.id
end

function GemShopData:GetItemID()
    return self.data.itemID
end

function GemShopData:GetItemNum()
    return self.data.itemNum
end

function GemShopData:GetItemColor()
    return self.data.itemColor
end

function GemShopData:GetNeedItemID()
    return self.data.needItemID
end

function GemShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function GemShopData:GetShowMsg()
    return self.data.showMsg
end

function GemShopData:GetType()
    return self.data.type
end

function GemShopData:GetProp()
    return self.data.prop
end

function GemShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



GemShopManager = Class(DataManager)

local GemShopDataMgr = GemShopManager.New(GemShopData)
return GemShopDataMgr