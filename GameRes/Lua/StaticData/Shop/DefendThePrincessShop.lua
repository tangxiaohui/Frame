require "StaticData.Manager"

DefendThePrincessShopData = Class(LuaObject)

function DefendThePrincessShopData:Ctor(id)
    local DefendThePrincessShopMgr = Data.DefendThePrincessShop.Manager.Instance()
    self.data = DefendThePrincessShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("保护公主信息不存在，ID: %s 不存在", id))
        return
    end
end

function DefendThePrincessShopData:GetId()
    return self.data.id
end

function DefendThePrincessShopData:GetItemID()
    return self.data.itemID
end

function DefendThePrincessShopData:GetItemNum()
    return self.data.itemNum
end

function DefendThePrincessShopData:GetItemColor()
    return self.data.itemColor
end

function DefendThePrincessShopData:GetNeedItemID()
    return self.data.needItemID
end

function DefendThePrincessShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function DefendThePrincessShopData:GetShowMsg()
    return self.data.showMsg
end

function DefendThePrincessShopData:GetType()
    return self.data.type
end

function DefendThePrincessShopData:GetProp()
    return self.data.prop
end

function DefendThePrincessShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



DefendThePrincessShopManager = Class(DataManager)

local DefendThePrincessShopDataMgr = DefendThePrincessShopManager.New(DefendThePrincessShopData)
return DefendThePrincessShopDataMgr