require "StaticData.Manager"

EquipGemData = Class(LuaObject)

function EquipGemData:Ctor(id)
    local EquipGemMgr = Data.EquipGem.Manager.Instance()
    self.data = EquipGemMgr:GetObject(id)
    if self.data == nil then
        error(string.format("宝石信息不存在，ID: %s 不存在", id))
        return
    end
end

function EquipGemData:GetId()
    return self.data.sourceStone
end

function EquipGemData:GetColor()
    return self.data.color
end

function EquipGemData:GetToStone()
	return self.data.toStone
end

function EquipGemData:GetCoinCost()
	return self.data.coinCost
end

function EquipGemData:GetDiamondCost()
	return self.data.diamondCost
end

function EquipGemData:GetBasicProp()
    return self.data.basicProp
end

function EquipGemData:GetAddLuck()
    return self.data.addLuck
end

function EquipGemData:GetFullLuck()
    return self.data.fullLuck
end

function EquipGemData:GetChangeCost()
    return self.data.changeCost
end

EquipGemManager = Class(DataManager)

local EquipGemDataMgr = EquipGemManager.New(EquipGemData)
return EquipGemDataMgr