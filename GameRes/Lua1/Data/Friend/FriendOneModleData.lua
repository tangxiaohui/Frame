require "Collection.OrderedDictionary"

local PlayerDataClass = require "Data.Friend.PlayerData"

FriendOneModleData = Class(LuaObject)

function FriendOneModleData:Ctor()
    self.DataDict = OrderedDictionary.New()
end

function FriendOneModleData:SetAllData(datas)
    self.DataDict:Clear()
    for i = 1, #datas do
        self:UpdateData(datas[i])
    end
end

function FriendOneModleData:UpdateData(data)
    local uid = data.playerUID

    local playerData = self.DataDict:GetEntryByKey(uid)

    if playerData ~= nil then
        playerData:Update(data)
    else
        playerData = PlayerDataClass.New()
        playerData:Update(data)
        self.DataDict:Add(uid, playerData)
    end
end

function FriendOneModleData:UpdateAlreadySend(uids)
    for i = 1 ,#uids do
        local uid = uids[i]
        local data = self.DataDict:GetEntryByKey(uid)
        
        if data ~= nil then
            data:UpdateState(false)
        end
    end
end

function FriendOneModleData:GetData()
    return self.DataDict
end

function FriendOneModleData:GetDataByUid(uid)
    return self.DataDict:GetEntryByKey(uid)
end

function FriendOneModleData:AddData(uid,data)
    self.DataDict:Add(uid, data)
end

function FriendOneModleData:DeleterDataByUid(uid)
    local data = self.DataDict:GetEntryByKey(uid)
    if data ~= nil then
        self.DataDict:Remove(uid)
        return data
    end
    return nil
end

function FriendOneModleData:GetCount()
    return self.DataDict:Count()
end

function FriendOneModleData:Clear()
    self.DataDict:Clear()
end

return FriendOneModleData