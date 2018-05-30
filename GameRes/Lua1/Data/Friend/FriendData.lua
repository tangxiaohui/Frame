require "Collection.OrderedDictionary"

local OneModleDataClass = require "Data.Friend.FriendOneModleData"

TotalFriendData = Class(LuaObject)

function TotalFriendData:Ctor()
    self.TotalFriendDict = OrderedDictionary.New()
end

function TotalFriendData:SetDataByModle(datas,modle) 
    
    local data = self.TotalFriendDict:GetEntryByKey(modle)
    
    if data ~= nil then
        data:SetAllData(datas)
    else
        data = OneModleDataClass.New()
        data:SetAllData(datas)
        self.TotalFriendDict:Add(modle,data)
    end
end

function TotalFriendData:UpdateAlreadySend(modle,uids)
    local data = self.TotalFriendDict:GetEntryByKey(modle)
    if data ~= nil then
        data:UpdateAlreadySend(uids)
    end
end

function TotalFriendData:UpdateData(modle,data)
    local cached = self.TotalFriendDict:GetEntryByKey(modle)
    if cached == nil then
        cached = OneModleDataClass.New()
    end
    cached:UpdateData(data)
end

function TotalFriendData:UpdateDataByUid(modle,uid,data)
    local dataCache = self.TotalFriendDict:GetEntryByKey(modle)
    if dataCache ~= nil then
       local playerData = dataCache:GetDataByUid(uid)
       if playerData ~= nil then
            playerData:UpdateByDataModle(data)
        else
            dataCache:AddData(uid,data)
        end
    else
        dataCache = OneModleDataClass.New()
        dataCache:AddData(uid,data)
        self.TotalFriendDict:Add(modle,dataCache)
    end
end

function TotalFriendData:AddDataByUid(modle,uid,data)

end

function TotalFriendData:DeletedDataByUid(modle,uid)
    local data = self.TotalFriendDict:GetEntryByKey(modle)
    if data ~= nil then
        return data:DeleterDataByUid(uid)
    end
    return nil
end

function TotalFriendData:GetData(modle)
    if self.TotalFriendDict:Contains(modle) then
        return self.TotalFriendDict:GetEntryByKey(modle)
    end
    return nil
end

function TotalFriendData:GetModleCount(modle)
    local data = self:GetData(modle)
    if data ~= nil then
        return data:GetCount() 
    else
        return 0
    end
end

function TotalFriendData:GetDataByUid(modle,uid)
    if self.TotalFriendDict:Contains(modle) then
        return self.TotalFriendDict:GetEntryByKey(modle):GetDataByUid(uid)
    end
    return nil
end

function TotalFriendData:UpdateSendState(modle,uid,state)
    if self.TotalFriendDict:Contains(modle) then
        local data = self.TotalFriendDict:GetEntryByKey(modle):GetDataByUid(uid)
        if data ~= nil then
            data:UpdateState(state)
        end
    end
end


function TotalFriendData:Clear()
    self.TotalFriendDict:Clear()
end