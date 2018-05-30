require "StaticData.Manager"

ChapterAdventureInfoData = Class(LuaObject)
function ChapterAdventureInfoData:Ctor(id)

    local ChapterAdventureInfoMgr = Data.ChapterAdventureInfo.Manager.Instance()
  --  print(type(ChapterAdventureInfoMgr))

    self.data = ChapterAdventureInfoMgr:GetObject(id)
 --   print(id)


    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function ChapterAdventureInfoData:GetIndex()
    return self.data.id
end

function ChapterAdventureInfoData:GetName()
    return self.data.name
end

function ChapterAdventureInfoData:GetDescShort()
    return self.data.descShort
end

function ChapterAdventureInfoData:GetDescLong()
    return self.data.descLong
end




ChapterAdventureInfoManager = Class(DataManager)

local ChapterAdventureInfoDataMgr = ChapterAdventureInfoManager.New(ChapterAdventureInfoData)
return ChapterAdventureInfoDataMgr
