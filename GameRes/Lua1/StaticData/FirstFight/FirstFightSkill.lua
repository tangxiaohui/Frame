
require "StaticData.Manager"

local FirstFightSkillData = Class(LuaObject)

function FirstFightSkillData:Ctor(id)
    local FirstFightSkillMgr = Data.FirstFightSkill.Manager.Instance()
    self.data = FirstFightSkillMgr:GetObject(id)
    if self.data == nil then
--        error(string.format("不存在技能特殊处理, id : %d", id))
    end
end

function FirstFightSkillData:IsValid()
    return self.data ~= nil
end

function FirstFightSkillData:GetId()
    return self.data.id
end

function FirstFightSkillData:GetSkillWave()
    return self.data.SkillWave
end

function FirstFightSkillData:GetSkillPosition()
    return self.data.SkillPosition
end

function FirstFightSkillData:GetVideoPath()
    return self.data.videopath
end


local firstFightSkillManager = Class(DataManager)
return firstFightSkillManager.New(FirstFightSkillData)
