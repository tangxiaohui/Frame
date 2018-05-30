require "StaticData.Manager"

BigLibraryCollectionPointsData = Class(LuaObject)
function BigLibraryCollectionPointsData:Ctor(id)
	local BigLibraryCollectionPointsMgr = Data.BigLibraryCollectionPoints.Manager.Instance()
	self.data = BigLibraryCollectionPointsMgr:GetObject(id)
	
	if self.data == nil then
		error(string.format("图鉴奖励点不存在，ID：%S不存在",id))
		return
	end
end

function BigLibraryCollectionPointsData:GetID()
	return self.data.id
end

function BigLibraryCollectionPointsData:GetAwardNum()
	return self.data.awardNum
end

BigLibraryCollectionPointsDataManager = Class(DataManager)

local BigLibraryCollectionPointsDataMgr = BigLibraryCollectionPointsDataManager.New(BigLibraryCollectionPointsData)

function BigLibraryCollectionPointsDataMgr:GetKeys()
	return Data.BigLibraryCollectionPoints.Manager.Instance():GetKeys()
end

return BigLibraryCollectionPointsDataMgr