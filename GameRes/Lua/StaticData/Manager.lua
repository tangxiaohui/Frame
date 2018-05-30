require "Object.LuaObject"

DataManager = Class(LuaObject)

function DataManager:Ctor(prototype)
	self.dataDictionary = {}
	self.prototype = prototype
	if prototype == nil then
		print("数据管理器初始化失败")
	end
end

function DataManager:GetData(id)
	if self.dataDictionary[id] == nil then
		local temp = self.prototype.New(id)
		self.dataDictionary[id] = temp
	end
	
	return self.dataDictionary[id]
end

function DataManager:SafeGetData(id)
	local result, data = pcall(DataManager.GetData, self, id)
	if result then
		return data
	end
	return nil
end
