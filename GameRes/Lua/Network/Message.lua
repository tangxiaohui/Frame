require "Object.LuaObject"

Message = Class(LuaObject)

function Message:Ctor(name, prototype)
	self.name = name
	self.prototype = prototype
end

function Message:Clone()
	if self.prototype ~= nil then
		return self.prototype()
	end

	return
end

function Message:GetName()
	return self.name
end

function Message:GetPrototype()
	return self.prototype
end

function Message:ToString()
	return "Message"
end