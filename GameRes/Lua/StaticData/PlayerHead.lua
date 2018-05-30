require "StaticData.Manager"

PlayerHeadData = Class(LuaObject)

function PlayerHeadData:Ctor(id)
    local HeadMgr = Data.PlayerHead.Manager.Instance()
    self.data = HeadMgr:GetObject(id)
    if self.data == nil then
        error(string.format("头像信息不存在，ID: %s 不存在", id))
        return
    end
end

function PlayerHeadData:GetId()
    return self.data.id
end

function PlayerHeadData:GetIcon()
    return self.data.icon
end

function PlayerHeadData:GetType()
    return self.data.type
end

function PlayerHeadData:GetunlockParame1()
    return self.data.unlockParame1
end

function PlayerHeadData:GetunlockParame2()
    return self.data.unlockParame2
end

HeadManager = Class(DataManager)

local PlayerHeadDataMgr = HeadManager.New(PlayerHeadData)
return PlayerHeadDataMgr