require "StaticData.Manager"

BigLibraryCollectionAwardInfoData = Class(LuaObject)
function BigLibraryCollectionAwardInfoData:Ctor(id)
	local BigLibraryCollectionAwardInfoMgr = Data.BigLibraryCollectionAwardInfo.Manager.Instance()
	self.data = BigLibraryCollectionAwardInfoMgr:GetObject(id)
	
	if self.data == nil then
		error(string.format("奖励称号不存在，ID:：%s 不存在",id))
		return
	end
end

function BigLibraryCollectionAwardInfoData:GetID()
	return self.data.id
end

function BigLibraryCollectionAwardInfoData:GetName()
	return self.data.name
end

BigLibraryCollectionAwardInfoDataManager = Class(DataManager)

local BigLibraryCollectionAwardInfoDataMgr = BigLibraryCollectionAwardInfoDataManager.New(BigLibraryCollectionAwardInfoData)

function BigLibraryCollectionAwardInfoDataMgr:GetKeys()
	return Data.BigLibraryCollectionAwardInfo.Manager.Instance():GetKeys()
end

return BigLibraryCollectionAwardInfoDataMgr