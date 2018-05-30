require "StaticData.Manager"

SubQuestRequestData = Class(LuaObject)

function SubQuestRequestData:Ctor(id)
	local subQuestRequestDataMgr = Data.SubQuestRequest.Manager.Instance()
	self.data = subQuestRequestDataMgr:GetObject(id)
	if self.data == nil then
		error(string.format("ZodiacDraw，ID：%s 不存在",id))
		return
	end
end

function SubQuestRequestData:GetId()
	return self.data.id
end


function SubQuestRequestData:GetRequestInfo()
	return self.data.requestInfo
end


function SubQuestRequestData:GetRequestType()
	return self.data.requestType
end

function SubQuestRequestData:GetRequestParam1()
	return self.data.requestParam1
end

function SubQuestRequestData:GetRequestParam2()
	return self.data.requestParam2
end

function SubQuestRequestData:GetRequestParam3()
	return self.data.requestParam3
end

function SubQuestRequestData:GetProp()
	return self.data.prop
end

SubQuestRequestDataManager = Class(DataManager)

local SubQuestRequestMgr = SubQuestRequestDataManager.New(SubQuestRequestData)
return SubQuestRequestMgr