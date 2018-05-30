
require "StaticData.Manager"

local ChapterStarData = Class(LuaObject)

function ChapterStarData:Ctor(id)
    local chapterStarMgr = Data.ChapterStar.Manager.Instance()
    self.data = chapterStarMgr:GetObject(id)
    if self.data == nil then
        error(string.format("章节奖励信息不存在: %d", id))
    end
end

function ChapterStarData:GetId()
    return self.data.id
end

function ChapterStarData:GetMapID()
    return self.data.mapID
end

function ChapterStarData:GetStage()
    return self.data.stage
end

function ChapterStarData:GetComplete()
    return self.data.complete
end

function ChapterStarData:GetCoin()
    return self.data.coin
end

function ChapterStarData:GetDiamond()
    return self.data.diamond
end

function ChapterStarData:GetItemID()
    return self.data.itemID
end

function ChapterStarData:GetItemNum()
    return self.data.itemNum
end

local ChapterStarManagerClass = Class(DataManager)
return ChapterStarManagerClass.New(ChapterStarData)