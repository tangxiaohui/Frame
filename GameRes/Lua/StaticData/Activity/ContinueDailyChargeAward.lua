require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.ContinueDailyChargeAward.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("单类连续充值，ID：%s 不存在",id))
		return
	end
end

function  ActiveData:GetID()
	return self.data.id
end

function ActiveData:GetInfo()
	return self.data.info
end

function ActiveData:GetType()
	return self.data.type
end

function ActiveData:GetDayNum()
	return self.data.dayNum
end

function ActiveData:GetPrice()
	return self.data.Price
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
	return Data.ContinueDailyChargeAward.Manager.Instance():GetKeys()
end

return ActiveDataMgr