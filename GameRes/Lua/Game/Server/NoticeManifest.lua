
require "Collection.OrderedDictionary"
local NoticeDataClass = require "Game.Server.NoticeData"

local NoticeManifest = Class()

local function OnCompareServerNotices(data1, data2)
	-- 1. 先按优先级
	if data1:GetPriority() > data2:GetPriority() then
		return true
	elseif data1:GetPriority() < data2:GetPriority() then
		return false
	end

	-- 2. 再按id
	return data1:GetId() > data2:GetId()
end

local function Set(self, notices)
	self.allNotices:Clear()
	for i = 1, #notices do
		local data = NoticeDataClass.New(notices[i])
		self.allNotices:Add(data:GetId(), data)
	end
	self.allNotices:Sort(OnCompareServerNotices)
end

function NoticeManifest:Ctor()
	self.allNotices = OrderedDictionary.New()
end

function NoticeManifest:Set(jsonData)
	Set(self, jsonData)
end

function NoticeManifest:Clear()
	self.allNotices:Clear()
end

-- 取得公告的数量
function NoticeManifest:Count()
	return self.allNotices:Count()
end

-- 取得公告的内容
function NoticeManifest:GetNoticeByIndex(pos)
	return self.allNotices:GetEntryByIndex(pos)
end

return NoticeManifest