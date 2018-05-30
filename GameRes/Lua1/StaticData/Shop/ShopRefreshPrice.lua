require "StaticData.Manager"

ShopRefreshPriceData = Class(LuaObject)

function ShopRefreshPriceData:Ctor(id)
    local ShopRefreshPriceMgr = Data.ShopRefreshPrice.Manager.Instance()
    self.data = ShopRefreshPriceMgr:GetObject(id)
    if self.data == nil then
        error(string.format("商店刷新消耗规则信息不存在，ID: %s 不存在", id))
        return
    end
end
--普通商店  公主  竞技场 黑市  军团  国战  "宝石钻石" 爬塔  "碎片商店钻石"  公会积分战

function ShopRefreshPriceData:GetTimes()
    return self.data.times
end

function ShopRefreshPriceData:GetNormalShop()
    return self.data.price01
end

function ShopRefreshPriceData:GetProtectPrincessShop()
    return self.data.price02
end

function ShopRefreshPriceData:GetArenaShop()
    return self.data.price03
end

function ShopRefreshPriceData:GetBlackMarketShop()
    return self.data.price04
end

function ShopRefreshPriceData:GetArmyGroupShop()
    return self.data.price05
end

function ShopRefreshPriceData:GetGemShop()
    return self.data.price07
end

function ShopRefreshPriceData:GetTowerShop()
    return self.data.price08
end
--[[
function ShopRefreshPriceData:price06()
    return self.data.price06
end





function ShopRefreshPriceData:price09()
    return self.data.price09
end
--]]

function ShopRefreshPriceData:GetGuildPointShop()
    return self.data.price11
end
function ShopRefreshPriceData:GetIntegralShop()
    return self.data.price13
end
function ShopRefreshPriceData:GetLotteryShop()
    return self.data.price12
end



ShopRefreshPriceManager = Class(DataManager)

local ShopRefreshPriceDataMgr = ShopRefreshPriceManager.New(ShopRefreshPriceData)

function ShopRefreshPriceDataMgr:GetKeys()
    return Data.ArenaTimes.Manager.Instance():GetKeys()
end
return ShopRefreshPriceDataMgr