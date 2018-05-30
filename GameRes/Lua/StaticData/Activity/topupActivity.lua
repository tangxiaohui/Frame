require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.topupActivity.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("逐额充值，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetId()
	return self.data.id
end

function ActivityData:GetPrice()
	return self.data.moneycost
end

function ActivityData:GetInfo()
	return self.data.info
end

function ActivityData:GetAwardItemNum()
	return self.data.AwardItemNum
end

function ActivityData:GetName()
	require "LUT.StringTable"
	return string.format(ActivityStringTable[7],math.floor(self:GetPrice()/100))
end

function ActivityData:GetNum()
	return self.data.baojiAwardItemNum[0]
end

function ActivityData:GetIetm()
	return self.data.AwardItem
end

local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.topupActivity.Manager.Instance():GetKeys()
end

return ActivityDataMgr