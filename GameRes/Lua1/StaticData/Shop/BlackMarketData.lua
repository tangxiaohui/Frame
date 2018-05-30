require "StaticData.Manager"

BlackMarketData = Class(LuaObject)

function BlackMarketData:Ctor(id)
	local BlackMarketMgr = Data.BlackMarketShop.Manager.Instance()
	self.data = BlackMarketMgr:GetObject(id)
	if self.data == nil then
		error(string.format("黑市信息不存在，ID: %s 不存在", id))
		return
	end
end

function BlackMarketData:GetId()
	return self.data.id
end

function BlackMarketData:GetItemID()
	return self.data.itemID
end

function BlackMarketData:GetItemNum()
	return self.data.itemNum
end

function BlackMarketData:GetItemColor()
	return self.data.itemColor
end

function BlackMarketData:GetNeedItemID()
    return self.data.needItemID
end

function BlackMarketData:GetNeedItemNum()
    return self.data.needItemNum
end

function BlackMarketData:GetShowMsg()
	return self.data.showMsg
end

function BlackMarketData:GetType()
	return self.data.type
end

function BlackMarketData:GetProp()
	return self.data.prop
end

function BlackMarketData:GetBuyOnlyOne()
	return self.data.buyOnlyOne
end

BlackMarketShopManager = Class(DataManager)

local BlackMarketShopMgr = BlackMarketShopManager.New(BlackMarketData)
return BlackMarketShopMgr