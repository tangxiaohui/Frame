--
-- User: fenghao
-- Date: 22/07/2017
-- Time: 10:59 AM
--

require "Object.LuaObject"
local battleUtility = require "Utils.BattleUtility"

local FirstFightConfig = Class(LuaObject)

function FirstFightConfig:Ctor()
    self.leftTeams, self.rightTeam, self.ableSkillWaves, self.sceneID, self.scriptID = battleUtility.CreateFirstFightParameters()
end

function FirstFightConfig:GetLeftTeams()
    return self.leftTeams
end

function FirstFightConfig:GetRightTeam()
    return self.rightTeam
end

function FirstFightConfig:GetAbleSkillWave()
    return self.ableSkillWaves
end

function FirstFightConfig:GetSceneID()
    return self.sceneID
end

function FirstFightConfig:GetScriptID()
    return self.scriptID
end

function FirstFightConfig:GetSeed()
    return 1
end

function FirstFightConfig:IsOffline()
    return true
end

return FirstFightConfig
