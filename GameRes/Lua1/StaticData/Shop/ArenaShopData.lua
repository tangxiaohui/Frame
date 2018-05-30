require "StaticData.Manager"

ArenaShopData = Class(LuaObject)

function ArenaShopData:Ctor(id)
    local ArenaShopMgr = Data.ArenaShop.Manager.Instance()
    self.data = ArenaShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function ArenaShopData:GetId()
    return self.data.id
end

function ArenaShopData:GetItemID()
    return self.data.itemID
end

function ArenaShopData:GetItemNum()
    return self.data.itemNum
end

function ArenaShopData:GetItemColor()
    return self.data.itemColor
end

function ArenaShopData:GetNeedItemID()
    return self.data.needItemID
end

function ArenaShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function ArenaShopData:GetShowMsg()
    return self.data.showMsg
end

function ArenaShopData:GetType()
    return self.data.type
end

function ArenaShopData:GetProp()
    return self.data.prop
end

function ArenaShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



ArenaShopManager = Class(DataManager)

local ArenaShopDataMgr = ArenaShopManager.New(ArenaShopData)
return ArenaShopDataMgr