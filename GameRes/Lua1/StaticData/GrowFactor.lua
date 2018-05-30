require "StaticData.Manager"

GrowFactor = Class(LuaObject)

function GrowFactor:Ctor(id)
	local mgr = Data.GrowFactor.Manager.Instance()
	self.data = mgr:GetObject(id)
	if self.data == nil then
		print(string.format("成长值系数初始化失败，ID: %s 不存在", id))
		return
	end
end

function GrowFactor:ToString()
	return string.format("成长系数，ID= %s", self.data.id)
end

function GrowFactor:GetValue(color)
	local value = self.data.value

	if color >= 1 and color <= value.Count then
		return value:get_Item(color - 1)
	else
		print(string.format("成长值系数里没有配索引 %d 的数据 (color = %d)", color - 1, color))
		return value:get_Item(value.Count - 1)
	end
end

GrowFactorManager = Class(DataManager)

local growFactorManager = GrowFactorManager.New(GrowFactor)
return growFactorManager