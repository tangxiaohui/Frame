require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.ContinueTotalAward.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("连续充值奖励，ID：%s 不存在",id))
		return
	end
end

function  ActiveData:GetID()
	return self.data.id
end

function ActiveData:GetDays()
	return self.data.days
end

function ActiveData:GetPriceType()
	return self.data.priceType
end

function ActiveData:GetItemID()
	return self.data.itemID
end

function ActiveData:GetItemNum()
	return self.data.itemNum
end


local ActiveManager = Class(DataManager)

local ActiveDataMgr = ActiveManager.New(ActiveData)

function ActiveDataMgr:GetKeys()
	return Data.ContinueTotalAward.Manager.Instance():GetKeys()
end

return ActiveDataMgr