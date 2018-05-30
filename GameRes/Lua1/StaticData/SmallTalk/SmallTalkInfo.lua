require "StaticData.Manager"
require "Collection.OrderedDictionary"

SmallTalkInfoData = Class(LuaObject)
function SmallTalkInfoData:Ctor(id)
    local SmallTalkInfoDataMgr = Data.SmallTalkInfo.Manager.Instance()
    self.data = SmallTalkInfoDataMgr:GetObject(id)
    if self.data == nil then
        error(string.format("道具信息不存在，ID: %s 不存在", id))
        return
    end
end

function SmallTalkInfoData:GetId()
    return self.data.id
end

function SmallTalkInfoData:GetContent()
    return self.data.content
end






SmallTalkInfoManager = Class(DataManager)

local SmallTalkInfoMgr = SmallTalkInfoManager.New(SmallTalkInfoData)
return SmallTalkInfoMgr