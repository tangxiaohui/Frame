require "Collection.OrderedDictionary"
require "Const"

local EquipDataClass = require "Data.EquipBag.EquipData"

local PropertySet = require "Game.Property.PropertySet"

-- # 装备背包 # --
----------------------------------------------------------------------
EquipBagData = Class(LuaObject)

function EquipBagData:Ctor()
    -- 全部装备字典
    self.EquipDict = OrderedDictionary.New()
    
    -- 穿在身上的装备
    self.OnCardEquipDict = OrderedDictionary.New()
end

-----------------------------------------------------------------------
--- 根据不同业务 写的更新函数
-----------------------------------------------------------------------
function EquipBagData:SetAllData(items)
    self.EquipDict:Clear()

    for i = 1, #items do
        self:UpdateData(items[i])
    end
    self:Sort()
end

-- # 获取装备类型
local function GetItemTypeByID(id)
    return require "StaticData.Equip":GetData(id):GetType()
end

function EquipBagData:UpdateData(item)
    -- 是否为特殊装备
    local uid = item.equipUID

    local equipUserData = self.EquipDict:GetEntryByKey(uid)
    if equipUserData == nil then
        equipUserData = self.OnCardEquipDict:GetEntryByKey(uid)
    end

    if equipUserData ~= nil then
        equipUserData:UpdateData(item)
        if item.onWhichCard ~= "" then
            self.OnCardEquipDict:Remove(uid)
            self.OnCardEquipDict:Add(uid,equipUserData)
            self.EquipDict:Remove(uid)
        else
            self.EquipDict:Remove(uid)
            self.EquipDict:Add(uid,equipUserData)
            self.OnCardEquipDict:Remove(uid)
        end
    else
        -- 没有
        equipUserData = EquipDataClass.New()
        equipUserData:UpdateData(item)

        if item.onWhichCard ~= "" then
            if not self.OnCardEquipDict:Contains(uid) then
                self.OnCardEquipDict:Add(uid,equipUserData)
            end
        else
            self.EquipDict:Add(uid, equipUserData)
            self.OnCardEquipDict:Remove(uid)
        end        
    end

    self:Sort()

    return equipUserData
end

function EquipBagData:Remove(uid)
    local equipData = self.EquipDict:GetEntryByKey(uid)
    if equipData ~= nil then
        self.EquipDict:Remove(uid)
        return equipData
    end

    return nil
end

local function SortComp(a, b)
    if a:GetLevel() == b:GetLevel() then
        if a:GetColor() == b:GetColor() then
            return a:GetEquipID() > b:GetEquipID()
        else
            return a:GetColor() > b:GetColor()
        end

    else
        return a:GetLevel() > b:GetLevel()
    end
end

function EquipBagData:Sort()
    -- 排序  根据等级 颜色 ID 排序
    self.EquipDict:Sort(SortComp)
end



-----------------------------------------------------------------------
--- 获取函数
-----------------------------------------------------------------------
function EquipBagData:GetItem(uid)
    local item
    item = self.EquipDict:GetEntryByKey(uid)
    if item == nil then        
       item = self.OnCardEquipDict:GetEntryByKey(uid)
    end
    return item
end

function EquipBagData:Count()
    return self.EquipDict:Count()
end

function EquipBagData:Contains(key)
    return self.EquipDict:Contains(key)
end

function EquipBagData:GetDataByIndex(index)
    local data = self.EquipDict:GetEntryByIndex(index)
    return data
end

function EquipBagData:GetType()
    return KKnapsackItemType_EquipNormal
end

function EquipBagData:GetItemDict()
      return self.EquipDict
end

function EquipBagData:RetrievalByResultFunc(func,dict)
    -- 根据一定规则进行检索
    local RetrievalDict

    if dict ~= nil then
        RetrievalDict = dict
    else
        RetrievalDict = OrderedDictionary.New()
    end
    
    
    local count = self.EquipDict:Count()

    for i = 1 ,count do
        local item = self.EquipDict:GetEntryByIndex(i)
        local addBoolean,key = func(item)
        
        if addBoolean then
            RetrievalDict:Add(key,item)
        end
    end
   
    return RetrievalDict
end


function EquipBagData:GetCanSellData()
    -- 获取可以出售的列表
    local RetrievalDict = OrderedDictionary.New()

    RetrievalDict:Clear()

    local count = self.EquipDict:Count()

    for i = 1 ,count do
        local item = self.EquipDict:GetEntryByIndex(i)
        local price = item:GetPrice()
        
        if price ~= 0 then
            local uid = item:GetEquipUID()
            RetrievalDict:Add(uid,item)
        end
    end

    return RetrievalDict
end

local function GetRetrieval(dict,id)
    local tempId
    local equipData

    local keys = dict:GetKeys()
    for i = 1,#keys do
        equipData = dict:GetEntryByKey(keys[i])
        tempId = equipData:GetEquipID()
        if tempId == id then
            return equipData,keys[i]
        end
    end
end

function EquipBagData:RetrievalContainsById(id)
    -- 根据Id检索是否拥有此装备  背包中的
    local equipData,uid
    equipData,uid = GetRetrieval(self.EquipDict,id)
    if equipData == nil then
        equipData,uid = GetRetrieval(self.OnCardEquipDict,id)
        if equipData ~= nil then
            return equipData,uid
        end
    else
        return equipData,uid
    end

    return nil
end

function EquipBagData:GetItemCountById(id)
    -- 根据Id检索此装备数量
    local count = 0

    -- 装备背包中检索
    local keys = self.EquipDict:GetKeys()

    local tempId
    for i = 1,#keys do
        local equipData = self.EquipDict:GetEntryByKey(keys[i])

        tempId = equipData:GetEquipID()
        if tempId == id then
            count = count + 1
        end
    end

    return count
end

function EquipBagData:GetOneCardEquipsByUid(uid)
    -- 获取穿在身上的装备
    local equipList = OrderedDictionary.New()
    local count = self.OnCardEquipDict:Count()

    for i = 1 , count do
        local equip = self.OnCardEquipDict:GetEntryByIndex(i)
        local onWhichCard = equip:GetOnWhichCard()
        if onWhichCard == uid  then
            local equipUid = equip:GetEquipUID()
            local pos = equip:GetPos()
            equipList:Add(pos,equipUid)
        end
    end

    return equipList
end

-- 获取身上的装备(装备以OrderedDictionary返回)
function EquipBagData:GetAllEquipsOnCard(uid)
    local equipDataList = OrderedDictionary.New()
    local count = self.OnCardEquipDict:Count()

    for i = 1, count do
        local equipData = self.OnCardEquipDict:GetEntryByIndex(i)
        if equipData ~= nil and equipData:GetOnWhichCard() == uid then
            equipDataList:Add(equipData:GetEquipUID(), equipData)
        end
    end

    return equipDataList
end

function EquipBagData:ExistsOnCardEquipDict(id, roleUid)
    local count = self.OnCardEquipDict:Count()
    for i = 1, count do
        local equipData = self.OnCardEquipDict:GetEntryByIndex(i)
        if equipData ~= nil and equipData:GetEquipID() == id and equipData:GetOnWhichCard() == roleUid then
            return true,equipData
        end
    end
    return false,nil
end

function EquipBagData:GetMountedGemCountByType(gamType)
    local count = self.EquipDict:Count()
    local gemNum = 0
    for i=1,count do
       local equipData = self.EquipDict:GetEntryByIndex(i) 
       if equipData:GetEquipType() == KEquipType_EquipGem and equipData:GetFillInType() == gamType then
            gemNum=gemNum+1
       end
    end
    return gemNum
    
end


function EquipBagData:GetEquipCountByType(equipType)  
    local equipCount = 0
    --获取全部装备
    local count =  self.EquipDict:Count()
    for i=1,count do
        local data =  self.EquipDict:GetDataByIndex(i)
        if data:GetEquipType() == equipType then
            equipCount=equipCount+1
        end
    end
    return equipCount
    
end

