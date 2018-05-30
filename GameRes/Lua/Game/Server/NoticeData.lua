
local NoticeData = Class()

function NoticeData:Ctor(jsonData)
	self.id = jsonData.id
    self.title = jsonData.title
    self.content = jsonData.content
    self.priority = jsonData.priority
end

function NoticeData:GetId()
	return self.id
end

function NoticeData:GetTitle()
	return self.title
end

function NoticeData:GetContent()
	return self.content
end

function NoticeData:GetPriority()
	return self.priority
end

return NoticeData
