--
-- User: fenghao
-- Date: 04/07/2017
-- Time: 5:26 PM
--

require "StaticData.Manager"

local DefendThePrincessAwardInfoData = Class(LuaObject)

function DefendThePrincessAwardInfoData:Ctor(id)
    local defendThePrincessAwardInfoMgr = Data.DefendThePrincessAwardInfo.Manager.Instance()
    self.data = defendThePrincessAwardInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("保卫公主奖励文本表 ID: %d 数据不存在!", id))
        return
    end
end

function DefendThePrincessAwardInfoData:GetId()
    return self.data.id
end

function DefendThePrincessAwardInfoData:GetName()
    return self.data.name
end

function DefendThePrincessAwardInfoData:GetDesc()
    return self.data.desc
end

function DefendThePrincessAwardInfoData:GetOpenName()
    return self.data.openName
end

function DefendThePrincessAwardInfoData:GetOpenDesc()
    return self.data.openDesc
end


local DefendThePrincessAwardInfoManager = Class(DataManager)
return DefendThePrincessAwardInfoManager.New(DefendThePrincessAwardInfoData)
