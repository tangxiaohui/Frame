require "StaticData.Manager"

ChapterAdventureData = Class(LuaObject)
function ChapterAdventureData:Ctor(id)

    local ChapterAdventureMgr = Data.ChapterAdventure.Manager.Instance()
  --  print(type(ChapterAdventureInfoMgr))

    self.data = ChapterAdventureMgr:GetObject(id)
 --   print(id)


    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function ChapterAdventureData:GetID()
    return self.data.id
end

function ChapterAdventureData:GetInfo()
    return self.data.info
end

function ChapterAdventureData:GetPic()
    return self.data.pic
end

function ChapterAdventureData:GetMapID()
    return self.data.mapID
end


function ChapterAdventureData:GetRound()
    return self.data.round
end

function ChapterAdventureData:GetLimit()
    return self.data.limit
end

function ChapterAdventureData:GetPic()
    return self.data.pic
end

function ChapterAdventureData:GetBossPortrait1()
    return self.data.BossPortrait1
end
function ChapterAdventureData:GetBossPortrait2()
    return self.data.BossPortrait2
end
function ChapterAdventureData:GetBossPortrait3()
    return self.data.BossPortrait3
end
function ChapterAdventureData:GetBossPortrait4()
    return self.data.BossPortrait4
end
function ChapterAdventureData:GetBossPortrait5()
    return self.data.BossPortrait5
end




ChapterAdventureManager = Class(DataManager)

local ChapterAdventureDataMgr = ChapterAdventureManager.New(ChapterAdventureData)
return ChapterAdventureDataMgr
