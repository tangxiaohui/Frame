require "StaticData.Manager"

ArenaTitleData = Class(LuaObject)

function ArenaTitleData:Ctor(id)
    local ArenaTitleMgr = Data.ArenaTitle.Manager.Instance()
     local ArenaTitleInfoMgr = Data.ArenaTitleInfo.Manager.Instance()
    
    self.data = ArenaTitleMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end

    self.info = ArenaTitleInfoMgr:GetObject(self.data.info)
     if self.info == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", self.data.info))
        return
    end

end

function ArenaTitleData:GetId()
    return self.data.id
end

function ArenaTitleData:GetRankUp()
    return self.data.rankUp
end

function ArenaTitleData:GetRankDown()
    return self.data.rankDown
end

function ArenaTitleData:GetInfo()
    return self.data.info
end

function ArenaTitleData:GetMaxGroupNum()
    return self.data.maxGroupNum
end

function ArenaTitleData:GetName()
    return self.info.name
end


ArenaTitleManager = Class(DataManager)

local ArenaTitleDataMgr = ArenaTitleManager.New(ArenaTitleData)
return ArenaTitleDataMgr