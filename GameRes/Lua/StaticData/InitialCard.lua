
require "StaticData.Manager"

local InitialCardData = Class(LuaObject)

function InitialCardData:Ctor(id)
    local initialCardMgr = Data.InitialCard.Manager.Instance()
    self.data = initialCardMgr:GetObject(id)
    if self.data == nil then
        error(string.format("初始卡牌, ID: %s 不存在", id))
    end

    local infoMgr = Data.RoleInfo.Manager.Instance()
    self.info = infoMgr:GetObject(self.data.info)
end

function InitialCardData:GetId()
    return self.data.id
end

function InitialCardData:GetRoleId()
    return self.data.role
end

function InitialCardData:GetName()
    return self.info.name
end

function InitialCardData:GetDesc()
    return self.info.desc
end

function InitialCardData:GetIcon()
    return self.data.icon
end

function InitialCardData:GetPortraitImage()
    return self.data.portraitImage
end

local initialCardManagerClass = Class(DataManager)
return initialCardManagerClass.New(InitialCardData)
