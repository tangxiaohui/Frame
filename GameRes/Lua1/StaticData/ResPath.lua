require "StaticData.Manager"

ResPath = Class(LuaObject)

function ResPath:Ctor(id)
	local mgr = Data.ResPath.Manager.Instance()
	self.data = mgr:GetObject(id)
	if self.data == nil then
		error(string.format("资源路径初始化失败，ID: %s 不存在", id))
		return
	end
end

function ResPath:ToString()
	return string.format("资源路径，ID= %s", self.data.id)
end

function ResPath:GetPath()
	return self.data.path
end

ResPathManager = Class(DataManager)

local resPathManager = ResPathManager.New(ResPath)
return resPathManager