
require "StaticData.Manager"

local ChapterBuyData = Class(LuaObject)

function ChapterBuyData:Ctor(id)
    local chapterBuyMgr = Data.ChapterBuy.Manager.Instance()
    local data = chapterBuyMgr:GetObject(id)
    self.diamond = data.diamond
end

function ChapterBuyData:GetDiamond()
    return self.diamond
end

return Class(DataManager).New(ChapterBuyData)

