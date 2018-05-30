require "StaticData.Manager"

local ActivityData = Class(LuaObject)

function ActivityData:Ctor(id)
	local ActivityMgr = Data.TopUpProgressAward.Manager.Instance()
	self.data = ActivityMgr:GetObject(id)
	if self.data == nil then
		error(string.format("逐额充值奖励，ID：%s 不存在",id))
		return
	end
end 

function ActivityData:GetID()
	return self.data.id
end

function ActivityData:GetBuyNum()
	return self.data.buyNum
end

function ActivityData:GetItemID()
	return self.data.bugNumAward
end

function ActivityData:GetItemNum()
	return self.data.bugAwardNum
end


local ActivityManagerClass = Class(DataManager)

local ActivityDataMgr = ActivityManagerClass.New(ActivityData)

function ActivityDataMgr:GetKeys()
    return Data.TopUpProgressAward.Manager.Instance():GetKeys()
end

return ActivityDataMgr