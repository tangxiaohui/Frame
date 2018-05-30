
require "Class"

-- id value 类

local Property = Class()

function Property:Ctor(id)
	self.id = id
	self:Clear()
end

function Property:GetId()
	return self.id
end

function Property:GetValue()
	return self.value
end

function Property:AddValue(value)
	self.value = self.value + value
end

function Property:Clear()
	self.value = 0
end

function Property:ToString()
	return string.format(
		"@property id: %d, value: %d",
		self:GetId(),
		self:GetValue()
	)
end

return Property

