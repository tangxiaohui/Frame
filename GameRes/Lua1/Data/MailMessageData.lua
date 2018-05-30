MailMessageData = Class(LuaObject)

function MailMessageData:Ctor()
	self.data = {}
end

function MailMessageData:SetBaseInfo(data)
	self.data = data
end



function MailMessageData:GetData()
	return self.data
end 

local function GetMailMessageById(id)
	local messageData = nil
	for k,v in ipairs(self.data) do
		if v.timeStamp == id then
		    messageData = v
		end
	end
	return messageData
end

function MailMessageData:UpdateMailMessageReadType(ids,readTime)
	print('ids'..ids)
	
	for k,v in ipairs(self.data) do
		if v.timeStamp == ids then
		    v.readTime = readTime
			print('ids'..ids .. 'success' .. 'readTime ' ..v.readTime)
		end
	end
end

function MailMessageData:RemoveMailMessageById(ids)
	--É¾³ýÄ³Ò»IDÓÊ¼þ
	for i = #self.data, 1, -1 do
		if self.data[i].timeStamp == ids then
            table.remove(self.data, i)
		end
    end
end

function MailMessageData:AddMailMessage(mailMessage)
	for i = 1,#mailMessage do
		table.insert(self.data,mailMessage[i])
	end
end

function MailMessageData:GetLength()
	return #self.data
end

