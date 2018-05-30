require "StaticData.Manager"

AroundShopData = Class(LuaObject)

function AroundShopData:Ctor(id)
    local AroundShopMgr = Data.AroundShop.Manager.Instance()
    debug_print("AroundShopData",id)
    self.data = AroundShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("爬塔神秘商店信息不存在，ID: %s 不存在", id))
        return
    end
end

function AroundShopData:GetId()
    return self.data.id
end

function AroundShopData:GetItemID()
    return self.data.itemID
end


function AroundShopData:GetItemNum()
    return self.data.itemNum
end



function AroundShopData:GetItemColor()
    return self.data.itemColor
end

function AroundShopData:GetNeedItemID()
    return self.data.needItemID
end


function AroundShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function AroundShopData:GetShowMsg()
    return self.data.showMsg
end


function AroundShopData:GetType()
    return self.data.type
end

function AroundShopData:GetProp()
    return self.data.prop
end
function AroundShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



AroundShopManager = Class(DataManager)

local AroundShopDataMgr = AroundShopManager.New(AroundShopData)
return AroundShopDataMgr