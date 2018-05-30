require "Const"
require "Object.LuaObject"

local ItemData = Class(LuaObject)

function ItemData:Ctor()
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------

--- # 对应 S2CItemBagFlush 协议 (参数对应 ItemInfo 类型)
function ItemData:Update(item)
    self.uid = item.itemUID
    self.id = item.itemID
    self.number = item.itemNum
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------

function ItemData:GetUid()
    return self.uid
end

function ItemData:GetId()
    return self.id
end

function ItemData:GetNumber()
    return self.number
end

function ItemData:GetColor()
    
	local id = self.id
    local color = require"StaticData/Item":GetData(id):GetColor()
	
    return color
end

function ItemData:GetCanUse()
     -- 获得使用模式
    local id = self.id
    local canUse = require"StaticData/Item":GetData(id):GetCanUse()
    return canUse
end

function ItemData:GetEffect()
    -- 获得使用类型
    local effect = require"StaticData/Item":GetData(self.id):GetEffect()
    return effect 

end

---------------------------------------------------------------
function ItemData:GetStaticData()
    self.staticData = require "StaticData.Item":GetData(self.id)
    return self.staticData
end

function ItemData:GetName()
    local infoDataID = self:GetStaticData():GetInfo()
    local staticDataInfo = require "StaticData.ItemInfo":GetData(infoDataID)
    local name = staticDataInfo:GetName()
    return name
end


function ItemData:GetDesc()
    local infoDataID = self:GetStaticData():GetInfo()
    local staticDataInfo = require "StaticData.ItemInfo":GetData(infoDataID)
    local desc = staticDataInfo:GetDesc()
    return desc
end


function ItemData:GetOrderId()
    return self:GetStaticData():GetOrderId()
end

function ItemData:GetKnapsackItemType()
    return KKnapsackItemType_Item
end



return ItemData