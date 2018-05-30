require "Object.LuaObject"

LuaComponent = Class(LuaObject)

function LuaComponent:Ctor()
	self.luaGameObject = nil
end

function LuaComponent:ToString()
	return "LuaComponent"
end

function LuaComponent:SetLuaGameObject(luaGameObject)
	self.luaGameObject = luaGameObject
	self:OnSetLuaGameObject()
end

function LuaComponent:OnSetLuaGameObject()
end

function LuaComponent:GetComponent(name)
	if self.luaGameObject == nil then
		return nil
	end

	return self.luaGameObject:GetComponent(name)
end

function LuaComponent:IsController()
	return false
end

function LuaComponent:Update()
end

function LuaComponent:Initialize()
end