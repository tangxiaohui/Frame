
require "StaticData.Manager"

local EmailStringData = Class()

function EmailStringData:Ctor(id)
	local emailStringMgr = Data.EmailString.Manager.Instance()
	self.data = emailStringMgr:GetObject(id)
	if self.data == nil then
		error(string.format("邮件文本 ID: %s 不存在", id))
	end
end

function EmailStringData:GetContent()
	return self.data.content
end

return Class(DataManager).New(EmailStringData)
