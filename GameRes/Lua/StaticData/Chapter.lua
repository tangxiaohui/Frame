
require "StaticData.Manager"

local ChapterData = Class(LuaObject)

function ChapterData:Ctor(id)
    local chapterMgr = Data.Chapter.Manager.Instance()
    self.data = chapterMgr:GetObject(id)
    if self.data == nil then
        error(string.format("章节，ID: %s 不存在", id))
        return
    end

    -- 章节信息
    local chapterInfoMgr = require "StaticData.ChapterInfo"
    self.chapterInfo = chapterInfoMgr:GetData(self.data.chapterInfo)
end

function ChapterData:GetId()
    return self.data.id
end

function ChapterData:GetChapterInfo()
    return self.chapterInfo
end

function ChapterData:GetPreChapterID()
    return self.data.preChapterID
end

function ChapterData:GetNextChapterID()
    return self.data.nextChapterID
end

function ChapterData:GetFirstLevelID()
    return self.data.firstLevelID
end

function ChapterData:GetHeadImage()
    return self.data.headImage
end

function ChapterData:GetChapterType()
    return self.data.chapterType
end

function ChapterData:GetChapterLv()
    return self.data.chapterLv
end

local chapterManagerClass = Class(DataManager)
return chapterManagerClass.New(ChapterData)