
require "StaticData.Manager"

local ChapterInfoData = Class(LuaObject)

function ChapterInfoData:Ctor(id)
    local chapterInfoMgr = Data.ChapterInfo.Manager.Instance()
    self.data = chapterInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("章节信息不存在，ID: %s 不存在", id))
    end
end

function ChapterInfoData:GetId()
    return self.data.id
end

function ChapterInfoData:GetNumText()
    return self.data.num
end

function ChapterInfoData:GetName()
    return self.data.name
end

local chapterInfoManagerClass = Class(DataManager)
return chapterInfoManagerClass.New(ChapterInfoData)