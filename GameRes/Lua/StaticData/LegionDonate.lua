require "StaticData.Manager"

LegionDonateData = Class(LuaObject)

function LegionDonateData:Ctor(id)
    local LegionDonateMgr = Data.LegionDonate.Manager.Instance()
    self.data = LegionDonateMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团捐赠不存在，ID: %s 不存在", id))
        return
    end
end

function LegionDonateData:GetId()
    return self.data.id
end

function LegionDonateData:GetPriceType()
    return self.data.priceType
end

function LegionDonateData:GetPriceNum()
    return self.data.priceNum
end

function LegionDonateData:GetExp()
    return self.data.exp
end

function LegionDonateData:GetCoinNum()
    return self.data.coinNum
end

LegionDonateManager = Class(DataManager)

local LegionDonateDataMgr = LegionDonateManager.New(LegionDonateData)
return LegionDonateDataMgr