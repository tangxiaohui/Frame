require "Object.LuaObject"
require "LUT.StringTable"
require "Const"
EquipDebrisCls = Class(LuaObject)


function EquipDebrisCls:Ctor()
	
end

function EquipDebrisCls:GetEquipSuipianID()
    return self.equipSuipianID
end

function EquipDebrisCls:GetNumber()
    return self.number
end


----------------------------------------------------
function EquipDebrisCls:UpdateData(data)
    -- 更新方法

    self.equipSuipianID = data.equipSuipianID
    self.number = data.number
end


function EquipDebrisCls:GetStaticData()
    self.staticData = require "StaticData.EquipCrap":GetData(self.equipSuipianID)
    return self.staticData
end

function EquipDebrisCls:GetName()
    local infoDataID = self:GetStaticData():GetInfo()
    local staticDataInfo = require "StaticData.EquipCrapInfo":GetData(infoDataID)
    local name = staticDataInfo:GetName()
    return name
end


function EquipDebrisCls:GetDesc()
    local name = self:GetName()
    local desc = string.format("%s%s",ShopStringTable[5],name)
    return desc
end

function EquipDebrisCls:GetStar()
    local id = self:GetStaticData():GetEquipid()
    local star = require "StaticData.Equip":GetData(id):GetStarID()
    return star
end

function EquipDebrisCls:GetRarity()
    local id = self:GetStaticData():GetEquipid()
    local star = require "StaticData.Equip":GetData(id):GetStarID()
	local rarity = require "StaticData.StartoSSR":GetData(star):GetRarity()
    return rarity
end

function EquipDebrisCls:GetPrice()
    local price = self:GetStaticData():GetSellPrice()
    return price
end

function EquipDebrisCls:GetEquipType()
	local id = self:GetStaticData():GetEquipid()
	local equipType = require "StaticData.Equip":GetData(id):GetType()
	return equipType
end

function EquipDebrisCls:GetColor()
	local infoDataID = self:GetStaticData():GetEquipid()
    local staticDataInfo = require "StaticData.Equip":GetData(infoDataID)
    local color = staticDataInfo:GetColorID()
    return color
end

function EquipDebrisCls:GetKnapsackItemType()
    return KKnapsackItemType_EquipDebris
end

function EquipDebrisCls:GetNeedBuildNum()
 
    return require "StaticData.EquipCrap":GetData(self.equipSuipianID):GetNeedBuildNum()
end


return EquipDebrisCls