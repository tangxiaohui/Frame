require "StaticData.Manager"

RoleImproveData = Class(LuaObject)

function RoleImproveData:Ctor(id)
    local RoleImproveMgr = Data.RoleImprove.Manager.Instance()
    self.data = RoleImproveMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌进阶信息不存在，ID: %s 不存在", id))
        return
    end
end

function RoleImproveData:GetId()
    return self.data.id
end

function RoleImproveData:GetAfterStageID()
    return self.data.afterStageID
end

function RoleImproveData:GetGraceAddValue()
    return self.data.graceAddValue
end

function RoleImproveData:GetLevelLimit()
    return self.data.levelLimit
end

function RoleImproveData:GetNeedCardSuipianNum()
    return self.data.needCardSuipianNum
end

function RoleImproveData:GetCoin()
    return self.data.coin
end
   

RoleImproveManager = Class(DataManager)

local RoleImproveDataMgr = RoleImproveManager.New(RoleImproveData)
return RoleImproveDataMgr