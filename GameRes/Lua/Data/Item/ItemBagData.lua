require "Const"
require "Collection.OrderedDictionary"

local ItemDataClass = require "Data.Item.ItemData"

ItemBagData = Class(LuaObject)

function ItemBagData:Ctor()
    self.itemDict = OrderedDictionary.New()

    -- 检索字典
    self.RetrievalDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------

--- # 对应 S2CItemBagQueryResult 协议 (参数对应 repeated ItemInfo 类型)
function ItemBagData:SetAllData(items)
    self.itemDict:Clear()
    for i = 1, #items do
        self:Update(items[i])
    end

    self:Sort()
end

--- # 对应 S2CItemBagFlush 协议 (参数对应 ItemInfo 类型)
function ItemBagData:Update(item)
    local uid = item.itemUID

    --debug_print("@@@ItemBagData:Update@@@", item.itemUID, item.itemID, item.itemNum)

    local itemUserData = self.itemDict:GetEntryByKey(uid)

    if itemUserData ~= nil then
        itemUserData:Update(item)
    else
        itemUserData = ItemDataClass.New()
        itemUserData:Update(item)
        self.itemDict:Add(uid, itemUserData)
        debug_print(itemUserData:GetOrderId(),"GetOrderId")
    end
    debug_print("对应 S2CItemBagFlush 协议",item.itemID)
    self:Sort()
   
    return itemUserData
end

--- # 对应 S2CItemBagFlush 协议使用, 当mod为del时 会将要删除物品的uid传进来!
function ItemBagData:Remove(uid)
    local item = self.itemDict:GetEntryByKey(uid)
    if item ~= nil then
        self.itemDict:Remove(uid)
        return item
    end

    return nil
end

function ItemBagData:Sort()
    -- 排序
    local utility = require "Utils.Utility"
    self.itemDict:Sort(function(a, b)
        -- debug_print("ItemBagData:Sort()",a:GetOrderId(),b:GetOrderId())
        return utility.CompareItemByItemData(a, b)
    end)
end

-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
function ItemBagData:GetCanSellData()
    --获取可以出售的物品 -- const Effect 类型为2 加钱

    --结果列表
    self.resultDict = OrderedDictionary.New()

    local count = self.itemDict:Count()

    for i = 1 ,count do
        local item = self.itemDict:GetEntryByIndex(i)
        local effect = item:GetEffect()
        
        if effect == 2 then
            local uid = item:GetUid()
            local count = item:GetNumber()
            self.resultDict:Add(uid,count)
        end
    end

    return self.resultDict
end


function ItemBagData:RetrievalByResultFunc(func)
    -- 根据一定规则进行检索
    self.RetrievalDict:Clear()
    
    local count = self.itemDict:Count()

    for i = 1 ,count do
        local item = self.itemDict:GetEntryByIndex(i)
        local addBoolean,key = func(item)
        
        if addBoolean then
            self.RetrievalDict:Add(key,item)
        end

    end

    return self.RetrievalDict
end


function ItemBagData:GetItemCountById(id)
    local count = self.itemDict:Count()
    local number = 0

    for i = 1, count do
        local currentItem = self.itemDict:GetEntryByIndex(i)
        if currentItem:GetId() == id then
            --debug_print("@ItemBagData:GetItemCountById", id, currentItem:GetNumber())
            number = number + currentItem:GetNumber()
        end
    end

    return number
end

function ItemBagData:GetDataByIndex(index)
    local data = self.itemDict:GetEntryByIndex(index)
    return data
end


function ItemBagData:GetItem(uid)
    return self.itemDict:GetEntryByKey(uid)
end

function ItemBagData:Count()
    return self.itemDict:Count()
end

function ItemBagData:GetItemDict()
      return self.itemDict
end

function ItemBagData:GetItemById(id)
    local count = self.itemDict:Count()
    for i = 1 ,count do
        local currItem = self.itemDict:GetEntryByIndex(i)
        if currItem:GetId() == id then
            return currItem
        end
    end
    return nil
end