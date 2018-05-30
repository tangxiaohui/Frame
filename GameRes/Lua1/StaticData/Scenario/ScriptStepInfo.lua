require "StaticData.Manager"
require "Collection.OrderedDictionary"

ScriptStepInfoData = Class(LuaObject)
function ScriptStepInfoData:Ctor(id)
    local ScriptStepInfoMgr = Data.ScriptStepInfo.Manager.Instance()
    self.data = ScriptStepInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("剧情步骤文本信息不存在，ID: %s 不存在", id))
        return
    end
end

function ScriptStepInfoData:GetID()
    return self.data.id
end

function ScriptStepInfoData:GetContent()
    return self.data.content
end




ScriptStepInfoManager = Class(DataManager)

local ScriptStepInfoDataMgr = ScriptStepInfoManager.New(ScriptStepInfoData)
return ScriptStepInfoDataMgr