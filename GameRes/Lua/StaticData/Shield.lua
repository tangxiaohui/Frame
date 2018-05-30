
require "StaticData.Manager"

local ShieldData = Class(LuaObject)

local function InitResPath(self, resPathID)
    if resPathID > 0 then
        local resPathData = require "StaticData.ResPath":GetData(resPathID)
        self.resPath = resPathData:GetPath()
    end
end

local function InitAttackedEffect(self, effectID)
    if effectID > 0 then
        local resPathData = require "StaticData.ResPath":GetData(effectID)
        self.attackedEffectPath = resPathData:GetPath()
    end
end

function ShieldData:Ctor(id)
    local shieldManager = Data.Shield.Manager.Instance()
    local data = shieldManager:GetObject(id)
    if data == nil then
        error(string.format("护盾信息不存在，ID: %s", id))
    end

    self.id = data.id
    self.basicHp = data.basicHp
    self.hpRate = data.hpRate
    self.rounds = data.rounds
    InitResPath(self, data.resID)
    InitAttackedEffect(self, data.attackedEffect)
    self.attackedName = data.attackedName
end

function ShieldData:GetId()
    return self.id
end

function ShieldData:GetBasicHp()
    return self.basicHp
end

function ShieldData:GetHpRate()
    return self.hpRate
end

function ShieldData:GetRounds()
    return self.rounds
end

function ShieldData:GetResPath()
    return self.resPath
end

function ShieldData:GetAttackedEffectPath()
    return self.attackedEffectPath
end

local shieldDataManager = Class(DataManager)
return shieldDataManager.New(ShieldData)

