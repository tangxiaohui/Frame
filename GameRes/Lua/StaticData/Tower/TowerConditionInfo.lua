require "StaticData.Manager"

local TowerConditionData = Class(LuaObject)

function TowerConditionData:Ctor(id)
	local TowerMgr = Data.TowerConditionInfo.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("爬塔描述，ID：%s 不存在",id))
		return
	end
end

function  TowerConditionData:GetID()
	return self.data.id
end

function  TowerConditionData:GetContent()
	return self.data.content
end

local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(TowerConditionData)

return TowerDataMgr