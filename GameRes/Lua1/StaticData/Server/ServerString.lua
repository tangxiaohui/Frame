
require "StaticData.Manager"

local ServerStringData = Class()

function ServerStringData:Ctor(id)
	local serverStringMgr = Data.ServerString.Manager.Instance()
	self.data = serverStringMgr:GetObject(id)
	if self.data == nil then
		error(string.format("服务器提示文本 ID: %s 不存在", id))
	end
end

function ServerStringData:GetContent()
	return self.data.content
end

return Class(DataManager).New(ServerStringData)
