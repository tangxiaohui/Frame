ChatMessageCache = Class(LuaObject)

function ChatMessageCache:Ctor()
	self.dataList = {}
	self.dataList[1] = {}
	self.dataList[2] = {}
	self.dataList[3] = {}
	self.dataList[4] = {}
end

function ChatMessageCache:GetCount(type)
	return #self.dataList[type]
end

function ChatMessageCache:Contain(sendTime,msgType)

	if  tostring(self.dataList[msgType][1].sendTime) >= tostring(sendTime) then
		return true
	else
		return false
	end
end

function ChatMessageCache:AddMessage(msg)
	local lastMsg
	for i = 1 , #msg.msgItem do
		local msgType = msg.msgItem[i].type
		if msg.head.sid == 100 then
			lastMsg = msg.msgItem[i]
		end
		if msgType == 4 and msg.head.sid == 100 then
			msgType = 1
		end
		
		if self:GetCount(msgType)  == 0 then
			table.insert(self.dataList[msgType],1,msg.msgItem[i])
		end

		if not self:Contain(msg.msgItem[i].sendTime,msgType) then
			table.insert(self.dataList[msgType],1,msg.msgItem[i])
		
			if #self.dataList[msgType] > 20 then
				table.remove(self.dataList[msgType],21)
			end	
		end	
	end
	self.lastMsg = lastMsg
end

function ChatMessageCache:GetLastMsg()
	return self.lastMsg
end

function ChatMessageCache:GetData(type)
	return self.dataList[type]
end







--[[
function ChatMessageData:SetBaseInfo(baseInfo,type)
	local endIndex = 1
	if #baseInfo.msgItem - 20 > 0 then
		endIndex = #baseInfo.msgItem - 19
	end
	for i = 1,#baseInfo.msgItem  do

		local typeIndex = baseInfo.msgItem[i].type

		if #self.baseInfo[typeIndex] == 0 then
			table.insert(self.baseInfo[typeIndex],1,baseInfo.msgItem[i])
		else
			if baseInfo.msgItem[i].sendTime>self.baseInfo[typeIndex][1].sendTime then
				table.insert(self.baseInfo[typeIndex],1,baseInfo.msgItem[i])
			end
		end
	end
end

function ChatMessageData:GetLength(type)
	return #self.baseInfo[type]
end
--]]