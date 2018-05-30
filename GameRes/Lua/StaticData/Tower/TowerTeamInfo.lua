require "StaticData.Manager"

local TowerTeamData = Class(LuaObject)

function TowerTeamData:Ctor(id)
	local TowerMgr = Data.TowerTeamInfo.Manager.Instance()
	self.data = TowerMgr:GetObject(id)
	if self.data == nil then
		error(string.format("爬塔队伍描述，ID：%s 不存在",id))
		return
	end
end

function  TowerTeamData:GetID()
	return self.data.id
end

function  TowerTeamData:GetContent()
	return self.data.content
end

local TowerDataManager = Class(DataManager)
local TowerDataMgr = TowerDataManager.New(TowerTeamData)

return TowerDataMgr