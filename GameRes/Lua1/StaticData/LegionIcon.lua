require "StaticData.Manager"

LegionIconData = Class(LuaObject)

function LegionIconData:Ctor(id)
    local LegionIconMgr = Data.LegionIcon.Manager.Instance()
    self.data = LegionIconMgr:GetObject(id)
    if self.data == nil then
        error(string.format("军团logo信息不存在，ID: %s 不存在", id))
        return
    end
end

function LegionIconData:GetId()
    return self.data.id
end

function LegionIconData:GetUnlockLv()
    return self.data.unlockLv
end

function LegionIconData:GetIconType()
	return self.data.iconType
end

function LegionIconData:GetIconColor()
	return self.data.iconColor
end

function LegionIconData:GetIcon()
	return self.data.icon
end

function LegionIconData:GetKeys()
    local LegionIconMgr = Data.LegionIcon.Manager.Instance()
    --return LegionIconMgr:GetKeys()
end

LegionIconManager = Class(DataManager)

local LegionIconDataMgr = LegionIconManager.New(LegionIconData)
return LegionIconDataMgr