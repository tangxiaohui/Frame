--
-- User: fbmly
-- Date: 2/6/17
-- Time: 6:17 PM
--

require "StaticData.Manager"

local LevelInfoData = Class(LuaObject)

local function CheckValidL(self)
end

function LevelInfoData:Ctor(id)
    local levelInfoMgr = Data.LevelInfo.Manager.Instance()
    self.data = levelInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("等級信息不存在，ID: %s 不存在", id))
        return
    end
    CheckValidL(self)
end

function LevelInfoData:GetId()
    return self.data.id
end

function LevelInfoData:GetName()
    return self.data.name
end

function LevelInfoData:GetDesc()
    return self.data.desc
end

function LevelInfoData:GetChapterNum()
	return self.data.ChapterNum
end

local levelInfoManagerClass = Class(DataManager)
return levelInfoManagerClass.New(LevelInfoData)