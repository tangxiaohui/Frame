require "StaticData.Manager"

SpeakerData = Class(LuaObject)

function SpeakerData:Ctor(id)
    local SpeakerMgr = Data.Speaker.Manager.Instance()
    local SpeakerInfoMgr = Data.SpeakerInfo.Manager.Instance()

    self.data = SpeakerMgr:GetObject(id)
    if self.data == nil then
        error(string.format("发言者数据不存在，ID: %s 不存在", id))
        return
    end

    self.infoData = SpeakerInfoMgr:GetObject(self.data.info)
    if self.infoData == nil then
        error(string.format("发言者信息数据不存在，ID: %s 不存在", self.data.info))
        return
    end
end

function SpeakerData:GetId()
    return self.data.id
end

function SpeakerData:GetPrice()
    return self.data.price
end

function SpeakerData:GetContent()
    return self.infoData.content
end

function SpeakerData:GetType()
    return self.data.type
end


SpeakerManager = Class(DataManager)

local SpeakerDataMgr = SpeakerManager.New(SpeakerData)

function SpeakerDataMgr:GetKeys()
    return Data.Speaker.Manager.Instance():GetKeys()
end
return SpeakerDataMgr