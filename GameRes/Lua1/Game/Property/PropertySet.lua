 
require "Collection.OrderedDictionary"
local PropertyClass = require "Game.Property.Property"

local PropertySet = Class()

function PropertySet:Ctor()
	self.dict = OrderedDictionary.New()
end

local function GetProperty(self, id, createIsMissing)
	local entry = self.dict:GetEntryByKey(id)
	if entry == nil and createIsMissing then
		entry = PropertyClass.New(id)
		self.dict:Add(id, entry)
	end
	return entry
end

function PropertySet:AddValue(id, value)
	if id ~= nil and type(value) == "number" and value ~= 0 then
		GetProperty(self, id, true):AddValue(value)
	end
end

function PropertySet:GetValue(id)
	if id ~= nil then
		local property = GetProperty(self, id, false)
		if property ~= nil then
			return property:GetValue()
		end
	end
	return 0
end

function PropertySet:Clear(id)
	return self.dict:Remove(id)
end

function PropertySet:ClearAll()
	self.dict:Clear()
end

function PropertySet:Foreach(func)
	local count = self.dict:Count()
	for i = 1, count do
		local id = self.dict:GetKeyFromIndex(i)
		func(id, self:GetValue(id))
	end
end

function PropertySet:ToString()
	return string.format(
		"the number of property is %d",
		self.dict:Count()
	)
end

return PropertySet
