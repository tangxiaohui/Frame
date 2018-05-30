require "StaticData.Manager"

BigLibraryCollectionData = Class(LuaObject)
function BigLibraryCollectionData:Ctor(id)
	local BigLibraryCollectionMgr = Data.BigLibraryCollection.Manager.Instance()
    self.data = BigLibraryCollectionMgr:GetObject(id)  
	
	if self.data == nil then
		error(string.format("图鉴信息不存在，ID：%s 不存在",id))
		return
	end
end

function BigLibraryCollectionData:GetID()
	return self.data.id
end

function BigLibraryCollectionData:GetFather()
	return self.data.father
end

function BigLibraryCollectionData:GetSon()
	return self.data.son
end

function BigLibraryCollectionData:GetType()
	return self.data.type
end

function BigLibraryCollectionData:GetParam()
	return self.data.param
end

function BigLibraryCollectionData:GetIsShow()
	return self.data.isShow
end

function BigLibraryCollectionData:GetPointsAwardID()
	return self.data.pointAwardID
end

function BigLibraryCollectionData:GetInfo()
	return self.data.info
end

function BigLibraryCollectionData:GetAllCollection()
	return self.data.AllCollection
end

BigLibraryCollectionDataManager = Class(DataManager)

local BigLibraryCollectionDataMgr = BigLibraryCollectionDataManager.New(BigLibraryCollectionData)

function BigLibraryCollectionDataMgr:GetKeys()
	return Data.BigLibraryCollection.Manager.Instance():GetKeys()
end

return BigLibraryCollectionDataMgr