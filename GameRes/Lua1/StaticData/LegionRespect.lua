require "StaticData.Manager"

LegionRespectData = Class(LuaObject)

function LegionRespectData:Ctor(id)
    local LegionRespectMgr = Data.LegionRespect.Manager.Instance()
    self.data = LegionRespectMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团崇奉信息不存在，ID: %s 不存在", id))
        return
    end
end

function LegionRespectData:GetId()
    return self.data.id
end

function LegionRespectData:GetPriceType()
    return self.data.priceType
end

function LegionRespectData:GetPriceNum()
	return self.data.priceNum
end

function LegionRespectData:GetCoinNum()
	return self.data.coinNum
end

LegionRespectManager = Class(DataManager)

local LegionRespectDataMgr = LegionRespectManager.New(LegionRespectData)
return LegionRespectDataMgr