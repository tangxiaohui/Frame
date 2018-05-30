require "StaticData.Manager"

LegionShopData = Class(LuaObject)

function LegionShopData:Ctor(id)
    local LegionShopMgr = Data.LegionShop.Manager.Instance()
    self.data = LegionShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团商品不存在，ID: %s 不存在", id))
        return
    end
end

function LegionShopData:GetId()
    return self.data.id
end

function LegionShopData:GetItemID()
    return self.data.itemID
end

function LegionShopData:GetItemNum()
    return self.data.itemNum
end

function LegionShopData:GetItemColor()
    return self.data.itemColor
end

function LegionShopData:GetNeedItemID()
    return self.data.needItemID
end

function LegionShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function LegionShopData:GetShowMsg()
    return self.data.showMsg
end

function LegionShopData:GetType()
    return self.data.type
end

function LegionShopData:GetProp()
    return self.data.prop
end

function LegionShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end

function LegionShopData:GetNeedLegionLv()
    return self.data.needLegionLv
end


LegionShopManager = Class(DataManager)

local LegionShopDataMgr = LegionShopManager.New(LegionShopData)
return LegionShopDataMgr