require "StaticData.Manager"
require "Collection.OrderedDictionary"

ScriptData = Class(LuaObject)
function ScriptData:Ctor(id)
    local ScriptMgr = Data.Script.Manager.Instance()
    self.data = ScriptMgr:GetObject(id)
    if self.data == nil then
        error(string.format("对话类型信息不存在，ID: %s 不存在", id))
        return
    end
end
function ScriptData:GetID()
    return self.data.id
end

function ScriptData:GetMapid()
    return self.data.mapid
end

function ScriptData:GetFirstStep()
    return self.data.firstStep
end



local ScriptManager = Class(DataManager)

local ScriptMgr = ScriptManager.New(ScriptData)
return ScriptMgr