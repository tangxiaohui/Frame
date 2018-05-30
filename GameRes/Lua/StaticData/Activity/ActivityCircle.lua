require "StaticData.Manager"

local ActiveData = Class(LuaObject)

function  ActiveData:Ctor(id)
	local ActivityItemMgr = Data.ActivityCircle.Manager.Instance()
	self.data = ActivityItemMgr:GetObject(id)
	if self.data == nil then
		error(string.format("转转乐奖励，ID：%s 不存在",id))
		return
	end
end

function  ActiveData:GetID()
	return self.data.id
end

function ActiveData:Getinfo()
	return self.data.info
end

function ActiveData:GetAwardItemNumber()
	return self.data.AwardItemNumber
end

function ActiveData:GetAwardItemProbability()
	return self.data.AwardItemProbability
end

local ActiveManager = Class(DataManager)

local ActiveDataMgr = ActiveManager.New(ActiveData)

function ActiveDataMgr:GetKeys()
	return Data.ActivityCircle.Manager.Instance():GetKeys()
end

return ActiveDataMgr