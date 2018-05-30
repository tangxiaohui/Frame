require "StaticData.Manager"
require "Collection.OrderedDictionary"

SmallTalkData = Class(LuaObject)
function SmallTalkData:Ctor(id)
    local SmallTalkDataMgr = Data.SmallTalk.Manager.Instance()
    self.data = SmallTalkDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function SmallTalkData:GetRandrange()
    return self.data.randrange
end

function SmallTalkData:GetTalkTime()
    return self.data.talkTime
end

function SmallTalkData:GetNexttalkTime()
    return self.data.nexttalkTime
end





SmallTalkManager = Class(DataManager)

local SmallTalkMgr = SmallTalkManager.New(SmallTalkData)
return SmallTalkMgr