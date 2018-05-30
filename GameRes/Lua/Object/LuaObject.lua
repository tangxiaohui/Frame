require "Class"

LuaObject = Class()

function LuaObject:Ctor()
end

function LuaObject:Equals(object)
	if object == self then
		return true
	end
	
	return false
end

function LuaObject:ToString()
	return "LuaObject"
end