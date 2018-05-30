require "Object.LuaObject"

local Node = Class(LuaObject)
function Node:Ctor()
	self.__parameter__ = {}
	self.__parameter__.parentNode = nil
	

end

return Node