
local MarqueeItem = Class()

function MarqueeItem:Ctor(msg)
	self.repeatTimes = msg.repeatTimes
	self.intervalInSeconds = msg.intervalInSeconds
	self.priority = msg.priority
	self.content = msg.content
end

function MarqueeItem:GetRepeatTimes()
	return self.repeatTimes
end

function MarqueeItem:GetIntervalInSeconds()
	return self.intervalInSeconds
end

function MarqueeItem:GetPriority()
	return self.priority
end

function MarqueeItem:GetContent()
	return self.content
end

return MarqueeItem