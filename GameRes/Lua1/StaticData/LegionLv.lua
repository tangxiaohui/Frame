require "StaticData.Manager"

LegionLvData = Class(LuaObject)

function LegionLvData:Ctor(id)
    local LegionLvMgr = Data.LegionLv.Manager.Instance()
    self.data = LegionLvMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团等级不存在，ID: %s 不存在", id))
        return
    end
end

function LegionLvData:GetLv()
    return self.data.lv
end

function LegionLvData:GetExp()
    return self.data.exp
end

function LegionLvData:GetPeople()
    return self.data.people
end

LegionLvManager = Class(DataManager)

local LegionLvDataMgr = LegionLvManager.New(LegionLvData)
return LegionLvDataMgr