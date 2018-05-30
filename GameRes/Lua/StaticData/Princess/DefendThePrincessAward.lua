--
-- User: fenghao
-- Date: 04/07/2017
-- Time: 5:25 PM
--

require "StaticData.Manager"

local DefendThePrincessAwardData = Class(LuaObject)

function DefendThePrincessAwardData:Ctor(id)
    local defendThePrincessAwardMgr = Data.DefendThePrincessAward.Manager.Instance()
    self.data = defendThePrincessAwardMgr:GetObject(id)
    if self.data == nil then
        error(string.format("保卫公主奖励表 ID: %d 数据不存在!", id))
        return
    end

    local AwardInfoManager = require "StaticData.Princess.DefendThePrincessAwardInfo"
    self.info = AwardInfoManager:GetData(self.data.info)
end

function DefendThePrincessAwardData:GetId()
    return self.data.id
end

function DefendThePrincessAwardData:GetType()
    return self.data.type
end

function DefendThePrincessAwardData:GetDiamond()
    return self.data.diamond
end

function DefendThePrincessAwardData:GetInfo()
    return self.info
end

function DefendThePrincessAwardData:GetIcon()
    return self.data.icon
end

function DefendThePrincessAwardData:GetButtonIcon()
    return self.data.buttonicon
end

function DefendThePrincessAwardData:GetRewards()
    return self.data.rewards
end


local DefendThePrincessAwardManager = Class(DataManager)
return DefendThePrincessAwardManager.New(DefendThePrincessAwardData)