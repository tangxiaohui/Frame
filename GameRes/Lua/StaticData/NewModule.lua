
require "StaticData.Manager"

local NewModuleData = Class(LuaObject)

function NewModuleData:Ctor(id)
    local newModuleMgr = Data.NewModule.Manager.Instance()
    self.data = newModuleMgr:GetObject(id)
    if self.data == nil then
        error(string.format("跳转，ID: %s 不存在", id))
        return
    end
end

function NewModuleData:GetId()
    return self.data.id
end

function NewModuleData:GetBackModule()
    return self.data.BackModule
end

function NewModuleData:GetModulePath()
    return self.data.ModulePath
end

function NewModuleData:GetIcon()
    return self.data.ShowIcon
end

local NewModuleClass = Class(DataManager)
return NewModuleClass.New(NewModuleData)