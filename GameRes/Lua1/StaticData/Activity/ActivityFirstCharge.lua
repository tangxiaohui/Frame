require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.ActivityFirstCharge.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("首冲，ID：%s 不存在",id))
		return
	end
end

function ActiveData:GetID()
	return self.data.id
end

function ActiveData:GetActivityId()
	return self.data.ActivityId
end

function ActiveData:GetActivityType()
	return self.data.activityType
end

function ActiveData:GetNeednum()
	return self.data.neednum
end

function ActiveData:GetItemID()
	return self.data.itemID
end

function ActiveData:GetItemNum()
	return self.data.itemNum
end

function ActiveData:GetItemColor()
	return self.data.itemColor
end

function ActiveData:GetFirstChargeInfo1()
	return self.data.FirstChargeInfo1
end

function ActiveData:GetFirstChargeInfo2()
	return self.data.FirstChargeInfo2
end

function ActiveData:GetFirstChargeInfo3()
	return self.data.FirstChargeInfo3
end

function ActiveData:GetFirstChargeInfo4()
	return self.data.FirstChargeInfo4
end



local ActiveManager = Class(DataManager)

local ActiveDataMgr = ActiveManager.New(ActiveData)

function ActiveDataMgr:GetKeys()
	return Data.ActivityFirstCharge.Manager.Instance():GetKeys()
end

return ActiveDataMgr