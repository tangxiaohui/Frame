
require "Game.Role"
require "Collection.OrderedDictionary"
require "Data.LineupData"
require "Const"

local utility = require "Utils.Utility"

CardBagData = Class(LuaObject)

function CardBagData:Ctor()
    -- 卡包数据
    self.roleDict = OrderedDictionary.New()

    -- 幽灵卡数据(图鉴中不显示的卡牌)
    self.ghostRoleDict = OrderedDictionary.New()

    -- 索引 Role => posArray
    self.rolePosArrayDict = OrderedDictionary.New()

    -- 阵型索引
    self.lineups = {}
    for type = 0, kLineup_Max - 1 do
        self.lineups[type] = LineupData.New()
    end

    -- 索引 id => uid, uid => id
    self.idToUidMaps = {}
    self.uidToIdMaps = {}
end

local function SortInternal(self)
    local utility = require "Utils.Utility"
    self.roleDict:Sort(function(role1, role2)
        return utility.CompareCardByRoleData(role1, role2)
    end)
end

local function GetRoleDictionary(self, cardID)
    local staticRoleData = require "StaticData.Role":GetData(cardID)
    if staticRoleData == nil then
        print("服务器推送了 数据表里没有配的卡牌, ID是", cardID)
        return nil
    end

    if staticRoleData:IsShowInCollection() then
        return self.roleDict
    else
        return self.ghostRoleDict
    end
end

local function RemoveFromLineup(self, role, posArray)
    if role == nil or posArray == nil then
        return
    end
    local rolePos
    for type = 0, kLineup_Max - 1 do
        rolePos = posArray[type + 1]
        if rolePos >= 1 and rolePos <= 6 then
            self.lineups[type]:Reset(rolePos, role:GetUid())
        end
    end
end

local function AddToLineup(self, role, posArray)
    if role == nil or posArray == nil then
        return
    end

    local rolePos
    for type = 0, kLineup_Max - 1 do
        rolePos = posArray[type + 1]
        if rolePos >= 1 and rolePos <= 6 then
            self.lineups[type]:Set(rolePos, role:GetUid())
        end
    end
end

-- 重新设置所有数据
function CardBagData:SetAllData(cards)
    self:Clear()

    local currentCardItem

    for i = 1, #cards do
        currentCardItem = cards[i]
        self:Update(currentCardItem, false)
    end

    SortInternal(self)
end

-- 增加/更新
function CardBagData:Update(cardItem, needToSort)
    local cardData = cardItem.card

    -- 通过ID拿对应的字典 --
    local cardID = cardData.id
    local roleDict = GetRoleDictionary(self, cardID)
    if roleDict == nil then
        return
    end

    -- uid和阵容信息 --
    local cardUID = cardData.uid
    local posArray = cardData.pos

    -- 拿取或创建卡牌 --
    local currentRole = roleDict:GetEntryByKey(cardUID)
    if currentRole == nil then
        currentRole = Role.New()
        roleDict:Add(cardUID, currentRole)
    end

    -- 更新数据 --
    currentRole:Update(cardData)

    -- 更新站位信息
    RemoveFromLineup(self, currentRole, self.rolePosArrayDict:GetEntryByKey(currentRole))
    self.rolePosArrayDict:Remove(currentRole)
    self.rolePosArrayDict:Add(currentRole, posArray)
    AddToLineup(self, currentRole, posArray)

    -- 索引id --
    self.idToUidMaps[currentRole:GetId()] = cardUID
    self.uidToIdMaps[cardUID] = currentRole:GetId()

    -- 排序 --
    if needToSort then
        SortInternal(self)
    end

    return currentRole
end

function CardBagData:UpdateTarotCache()
    local count = self:RoleCount()
    for i = 1, count do
        local roleData = self:GetRoleByPos(i)
        if roleData ~= nil then
            roleData:UpdateTarotCache()
        end
    end
end

function CardBagData:UpdateElvenTreeCache()
    local count = self:RoleCount()
    for i = 1, count do
        local roleData = self:GetRoleByPos(i)
        if roleData ~= nil then
            roleData:UpdateElvenTreeCache()
        end
    end
end


local function RemoveImpl(self, uid, cardID)
    local roleDict = GetRoleDictionary(self, cardID)
    if roleDict ~= nil then
        local role = roleDict:GetEntryByKey(uid)
        if roleDict:Remove(uid) then
            RemoveFromLineup(self, role, self.rolePosArrayDict:GetEntryByKey(role))
            self.rolePosArrayDict:Remove(role)
            self.idToUidMaps[cardID] = nil
            self.uidToIdMaps[uid] = nil
            return role
        end
    end
    return nil
end

function CardBagData:RemoveByUID(uid)
    if utility.IsValidUid(uid) then
        local cardID = self.uidToIdMaps[uid]
        if utility.IsValidUid(cardID) then
            return RemoveImpl(self, uid, cardID)
        end
    end
    return nil
end

function CardBagData:RemoveByID(id)
    if utility.IsValidUid(id) then
        local uid = self.idToUidMaps[id]
        if utility.IsValidUid(uid) then
            return RemoveImpl(self, uid, id)
        end
    end
    return nil
end

function CardBagData:GetTroopByLineup(type)
    if self.lineups[type] ~= nil then
        return self.lineups[type]:GetTroop()
    end
    return nil
end

function CardBagData:GetTroopCount(type)
    if self.lineups[type] ~= nil then
        return self.lineups[type]:ValidCount()
    end
    return 0
end

-- get (role)
function CardBagData:GetRoleById(id)
    local uid = self.idToUidMaps[id]
    return self:GetRoleByUid(uid)
end

function CardBagData:GetRoleByUid(uid)
    if utility.IsValidUid(uid) then
        return self.roleDict:GetEntryByKey(uid)
    end
    return nil
end

-- 以后会废弃 --
function CardBagData:Count()
    return self:RoleCount()
end

function CardBagData:RoleCount()
    return self.roleDict:Count()
end

function CardBagData:GetRoleByPos(pos)
    return self.roleDict:GetEntryByIndex(pos)
end

-- get (ghost role)
function CardBagData:GetGhostRoleById(id)
    local uid = self.idToUidMaps[id]
    return self:GetGhostRoleByUid(uid)
end

function CardBagData:GetGhostRoleByUid(uid)
    if utility.IsValidUid(uid) then
        return self.ghostRoleDict:GetEntryByKey(uid)
    end
    return nil
end

function CardBagData:GhostRoleCount()
    return self.ghostRoleDict:Count()
end

function CardBagData:GetGhostRoleByPos(pos)
    return self.ghostRoleDict:GetEntryByIndex(pos)
end

-- id to uid or uid to id
function CardBagData:GetIdFromUid(uid)
    return self.uidToIdMaps[uid]
end

function CardBagData:GetUidFromId(id)
    return self.idToUidMaps[id]
end


-- clear all
function CardBagData:Clear()
    self.roleDict:Clear()
    self.ghostRoleDict:Clear()
    self.rolePosArrayDict:Clear()
    self.idToUidMaps = {}
    self.uidToIdMaps = {}
    for type = 0, kLineup_Max - 1 do
        self.lineups[type]:Clear()
    end
end

