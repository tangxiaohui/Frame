require "StaticData.Manager"
require "Collection.OrderedDictionary"

ScriptStepData = Class(LuaObject)
function ScriptStepData:Ctor(id)
    local ScriptStepMgr = Data.ScriptStep.Manager.Instance()
    self.data = ScriptStepMgr:GetObject(id)
    if self.data == nil then
        error(string.format("剧情步骤信息不存在，ID: %s 不存在", id))
        return
    end
end

function ScriptStepData:GetID()
    return self.data.id
end

function ScriptStepData:GetNextStep()
    return self.data.nextStep
end

function ScriptStepData:GetIntinfo()
    return self.data.intinfo
end

function ScriptStepData:GetType()
    return self.data.type
end

function ScriptStepData:GetOrder()
    return self.data.order
end

function ScriptStepData:GetPos()
    return self.data.pos
end

function ScriptStepData:GetIsEnemy()
    return self.data.isEnemy
end

function ScriptStepData:GetWavenum()
    return self.data.wavenum
end

function ScriptStepData:GetVoice()
    return self.data.voice
end

function ScriptStepData:GetDuration()
    return self.data.duration
end

function ScriptStepData:GetSpeaker()
    return self.data.speaker
end


function ScriptStepData:GetPortraitShow()
    return self.data.PortraitShow
end
function ScriptStepData:GetIsSipne()
    return self.data.IsSipne
end


ScriptStepManager = Class(DataManager)

local ScriptStepMgr = ScriptStepManager.New(ScriptStepData)
return ScriptStepMgr