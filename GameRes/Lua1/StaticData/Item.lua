require "StaticData.Manager"

ItemData = Class(LuaObject)

function ItemData:Ctor(id)
    local itemMgr = Data.Item.Manager.Instance()
    self.data = itemMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function ItemData:GetId()
    return self.data.id
end

function ItemData:GetInfo()
    return self.data.info
end

function ItemData:GetResourceID()
    return self.data.resourceID
end

function ItemData:GetColor()
	return self.data.color
end

function ItemData:GetCanUse()
	--0:不可使用，1：消耗获得对应货币，2：打开副本战斗提示界面
	--3：打开抽卡界面，4：接受任务
	return self.data.canUse
end

function ItemData:GetEffect()
    --使用模式
	--0：无意义，1：加体力，2：加钱，3：加钻石，4：任务（任务ID）
	return self.data.effect
end

function ItemData:GetMaxNumber()
	return self.data.number
end

function ItemData:GetOrderId()
    return self.data.orderId
end

function ItemData:GetCanOverLay()
    return self.data.canOverlay
end

function ItemData:GetBoxId()
    return self.data.boxId
end
ItemManager = Class(DataManager)

local itemManager = ItemManager.New(ItemData)
return itemManager