require "StaticData.Manager"
require "Collection.OrderedDictionary"

OnlineTimeAwardData = Class(LuaObject)
function OnlineTimeAwardData:Ctor(id)
    local OnlineTimeAwardMgr = Data.OnlineTimeAward.Manager.Instance()
    self.data = OnlineTimeAwardMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function OnlineTimeAwardData:GetIndex()
    return self.data.index
end

function OnlineTimeAwardData:GetItemID1()
    return self.data.itemID1
end

function OnlineTimeAwardData:GetItemNum1()
    return self.data.itemNum1
end
function OnlineTimeAwardData:GetItemID2()
    return self.data.itemID2
end

function OnlineTimeAwardData:GetItemNum2()
    return self.data.itemNum2
end
function OnlineTimeAwardData:GetItemID3()
    return self.data.itemID3
end

function OnlineTimeAwardData:GetItemNum3()
    return self.data.itemNum3
end
function OnlineTimeAwardData:GetItemID4()
    return self.data.itemID4
end

function OnlineTimeAwardData:GetItemNum4()
    return self.data.itemNum4
end


function OnlineTimeAwardData:GetBaseMinute()
    return self.data.minute
end


function OnlineTimeAwardData:GetItemDic()
    local dict = OrderedDictionary.New()
    if self:GetItemID1()~=0 then
           dict:Add(self:GetItemID1(),self:GetItemNum1())
    end
     if self:GetItemID2()~=0 then
           dict:Add(self:GetItemID2(),self:GetItemNum2())
    end
     if self:GetItemID3()~=0 then
           dict:Add(self:GetItemID3(),self:GetItemNum3())
    end
     if self:GetItemID4()~=0 then
           dict:Add(self:GetItemID4(),self:GetItemNum4())
    end
    return dict

end

OnlineTimeAwardManager = Class(DataManager)

local OnlineTimeAwardDataMgr = OnlineTimeAwardManager.New(OnlineTimeAwardData)
return OnlineTimeAwardDataMgr