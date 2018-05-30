require "StaticData.Manager"

FormationConfigData = Class(LuaObject)

function FormationConfigData:Ctor(id)
    local FormationConfigMgr = Data.FormationConfig.Manager.Instance()
    
    self.data = FormationConfigMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end

end

function FormationConfigData:GetId()
    return self.data.id
end

function FormationConfigData:GetLevel()
    return self.data.level
end

function FormationConfigData:GetMaxCardOn()
    return self.data.maxCardOn
end


FormationConfigManager = Class(DataManager)

local FormationConfigDataMgr = FormationConfigManager.New(FormationConfigData)
return FormationConfigDataMgr