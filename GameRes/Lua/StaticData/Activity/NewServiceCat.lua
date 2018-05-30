require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.NewServiceCat.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("招财猫，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetPrice()
	return self.data.price
end

function ActivityData:GetMaxDiamond()
	return self.data.maxDiamond
end

function ActivityData:GetVip()
	return self.data.vip
end

function ActivityData:GetCrit()
	return self.data.crit
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.NewServiceCat.Manager.Instance():GetKeys()
end

return ActivityDataMgr