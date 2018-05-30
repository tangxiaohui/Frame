require "Object.LuaObject"

LuaGameObject = Class(LuaObject)

function LuaGameObject:Ctor()
	self.luaComponents = {}
	self.gameObject = nil	-- Unity GameObject
	self.parent = nil		-- Lua GameObject
end

function LuaGameObject:ToString()
	return "LuaGameObject"
end

function LuaGameObject:AddComponent(luaComponent)
	luaComponent:SetLuaGameObject(self)
	self.luaComponents[luaComponent:ToString()] = luaComponent
end

function LuaGameObject:GetComponent(name)
	return self.luaComponents[name]
end

function LuaGameObject:SetParent(parent)
	self.parent = parent
end

function LuaGameObject:GetParent()
	return self.parent
end

function LuaGameObject:GetGameObject()
	return self.gameObject
end

function LuaGameObject:Update()
	if self.luaComponents == nil then
		return
	end

	for k, v in pairs(self.luaComponents) do
		if v:IsController() then
			v:Update()
		end
	end
end

function LuaGameObject:Initialize()
end