--
-- User: fenghao
-- Date: 10/07/2017
-- Time: 2:07 PM
--

require "StaticData.Manager"

local SpecialEffectData = Class(LuaObject)

function SpecialEffectData:Ctor(id)
    local SpecialEffectMgr = Data.SpecialEffect.Manager.Instance()
    self.data = SpecialEffectMgr:GetObject(id)
    if self.data == nil then
        error(string.format("特效ID 不存在! id: %d", id))
    end

    -- 资源路径 --
    self.effects = {}
    local count = self.data.effects.Count
    for i = 0, count - 1 do
        local resID = self.data.effects[i]
        if resID > 0 then
            self.effects[#self.effects + 1] = resID
        end
    end
end

function SpecialEffectData:GetId()
    return self.data.id
end

function SpecialEffectData:GetEffectIDs()
    return self.effects
end

function SpecialEffectData:GetLifeCycleType()
    return self.data.lifeCycleType
end

function SpecialEffectData:GetDuration()
    return self.data.duration
end


local SpecialEffectManager = Class(DataManager)
return SpecialEffectManager.New(SpecialEffectData)