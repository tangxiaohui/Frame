require "StaticData.Manager"

DrawPointShopData = Class(LuaObject)

function DrawPointShopData:Ctor(id)
    local DrawPointShopMgr = Data.DrawPointShop.Manager.Instance()
    self.data = DrawPointShopMgr:GetObject(id)
    if self.data == nil then
        error(string.format("爬塔神秘商店信息不存在，ID: %s 不存在", id))
        return
    end
end

function DrawPointShopData:GetId()
    return self.data.id
end

function DrawPointShopData:GetItemID()
    return self.data.itemID
end


function DrawPointShopData:GetItemNum()
    return self.data.itemNum
end



function DrawPointShopData:GetItemColor()
    return self.data.itemColor
end

function DrawPointShopData:GetNeedItemID()
    return self.data.needItemID
end


function DrawPointShopData:GetNeedItemNum()
    return self.data.needItemNum
end

function DrawPointShopData:GetShowMsg()
    return self.data.showMsg
end


function DrawPointShopData:GetType()
    return self.data.type
end

function DrawPointShopData:GetProp()
    return self.data.prop
end
function DrawPointShopData:GetBuyOnlyOne()
    return self.data.buyOnlyOne
end



DrawPointShopManager = Class(DataManager)

local DrawPointShopDataMgr = DrawPointShopManager.New(DrawPointShopData)
return DrawPointShopDataMgr