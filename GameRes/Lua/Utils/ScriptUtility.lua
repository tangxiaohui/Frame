
local ScriptUtility = {}

local function GetScriptData(id)
    return require "StaticData.Scenario.Script":GetData(id)
end

local function GetScriptStepData(id)
    return require "StaticData.Scenario.ScriptStep":GetData(id)
end

function ScriptUtility.GetMapId(scriptId)
    return GetScriptData(scriptId):GetMapid()
end

function ScriptUtility.GetFirstStepId(scriptId)
    return GetScriptData(scriptId):GetFirstStep()
end

function ScriptUtility.GetScriptStepsNonAlloc(t, scriptId, wave)
    local stepId = ScriptUtility.GetFirstStepId(scriptId)
    while(stepId ~= 0)
    do
        local scriptStepData = GetScriptStepData(stepId)
        if scriptStepData:GetWavenum() == wave then
            t[#t + 1] = stepId
        end
        stepId = scriptStepData:GetNextStep()
    end
    return t
end

function ScriptUtility.GetScriptSteps(scriptId, wave)
    return ScriptUtility.GetScriptStepsNonAlloc({}, scriptId, wave)
end

return ScriptUtility
