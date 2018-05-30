require "StaticData.Manager"

BigLibraryCollectionAwardData = Class(LuaObject)
function BigLibraryCollectionAwardData:Ctor(id)
	local BigLibraryCollectionAwardMgr = Data.BigLibraryCollectionAward.Manager.Instance()
	self.data = BigLibraryCollectionAwardMgr:GetObject(id)
	
	if self.data == nil then
		error(string.format("图鉴奖励信息不存在，ID：%s不存在",id))
		return
	end
end

function BigLibraryCollectionAwardData:GetID()
	return self.data.id
end

function BigLibraryCollectionAwardData:GetNeedPoint()
	return self.data.needPoint
end

function BigLibraryCollectionAwardData:GetAwardId()
	return self.data.awardId
end

function BigLibraryCollectionAwardData:GetAwardNum()
	return self.data.awardNum
end

BigLibraryCollectionAwardDataManager = Class(DataManager)

local BigLibraryCollectionAwardDataMgr = BigLibraryCollectionAwardDataManager.New(BigLibraryCollectionAwardData)

function BigLibraryCollectionAwardDataMgr:GetKeys()
	return Data.BigLibraryCollectionAward.Manager.Instance():GetKeys()
end

return BigLibraryCollectionAwardDataMgr