require "StaticData.Manager"

NewPlayerGUideStepData = Class(LuaObject)

function NewPlayerGUideStepData:Ctor(id)
    local newPlayerGuideStepMgr = Data.NewPlayerGuideStep.Manager.Instance()
    self.data = newPlayerGuideStepMgr:GetObject(id)
    if self.data == nil then
        error(string.format("新手引导步骤信息不存在，ID: %s 不存在", id))
        return
    end
end

function NewPlayerGUideStepData:GetId()
    return self.data.id
end

function NewPlayerGUideStepData:GetInfo()
    return self.data.info
end

function NewPlayerGUideStepData:GetPreviousId()
	return self.data.previousId
end

function NewPlayerGUideStepData:GetNextId()
    return self.data.nextId
end

function NewPlayerGUideStepData:GetNeedInterface()
    return self.data.needInterface
end

function NewPlayerGUideStepData:GetOperatingType()
    return self.data.operatingType
end

function NewPlayerGUideStepData:GetHighlightSwitch()
	return self.data.HighlightSwitch
end

function NewPlayerGUideStepData:GetTypeParam()
    return self.data.typeParam
end

function NewPlayerGUideStepData:GetTypePos()
	return self.data.typePos
end

function NewPlayerGUideStepData:GetHighlightPos()
	return self.data.HighlightPos
end

function NewPlayerGUideStepData:GetPortrait()
    return self.data.Portrait
end

function NewPlayerGUideStepData:GetPortraitPosition()
    return self.data.PortraitPosition
end

function NewPlayerGUideStepData:GetFramePosition()
    return self.data.FramePosition
end

function NewPlayerGUideStepData:GetWindowScroll()
    return self.data.WindowScroll
end

function NewPlayerGUideStepData:GetGuideEvent()
	return self.data.GuideEvent
end
function NewPlayerGUideStepData:IsForced()
    return self.data.IsForced
end
function NewPlayerGUideStepData:GetGuideVoice()
    return self.data.GuideVoice
end

function NewPlayerGUideStepData:GetGuideLocateDelay()
    return self.data.LocateDelay
end

function NewPlayerGUideStepData:GetModulePath()
    return self.data.ModulePath
end
NewPlayerGuideStepManager = Class(DataManager)

function NewPlayerGuideStepManager:Ctor()
	local newPlayerGuideStepMgr = Data.NewPlayerGuideStep.Manager.Instance()
	self.keys = newPlayerGuideStepMgr:GetKeys()
end

function NewPlayerGuideStepManager:GetKeys()
	return self.keys
end

local NewPlayerGUideStepDataMgr = NewPlayerGuideStepManager.New(NewPlayerGUideStepData)
return NewPlayerGUideStepDataMgr