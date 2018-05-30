require "StaticData.Manager"

BigLibraryAchievementData = Class(LuaObject)
function BigLibraryAchievementData:Ctor(id)
    local BigLibraryAchievementMgr = Data.BigLibraryAchievement.Manager.Instance()
    self.data = BigLibraryAchievementMgr:GetObject(id)

    if self.data == nil then
        error(string.format("成就信息不存在，ID: %s 不存在", id))
        return
    end

    local BigLibraryAchievementInfoMgr=Data.BigLibraryAchievementInfo.Manager.Instance()
    self.Infodata=BigLibraryAchievementInfoMgr:GetObject(self.data.info)
    
   if self.Infodata == nil then
        error(string.format("大书库描述信息不存在，ID: %s 不存在", id))
        return
    end
    
end

function BigLibraryAchievementData:GetName()
    return self.Infodata.name
end

function BigLibraryAchievementData:GetDescription()
    return self.Infodata.description
end

function BigLibraryAchievementData:GetDescriptionLoog()
    return self.Infodata.descriptionLoog
end


function BigLibraryAchievementData:GetInfo()
    return self.data.info
end

function BigLibraryAchievementData:GetID()
    return self.data.id 
end

function BigLibraryAchievementData:GetType()
    return self.data.type
end

function BigLibraryAchievementData:GetFather()
    return self.data.father
end

function BigLibraryAchievementData:GetSon()
    return self.data.son
end

function BigLibraryAchievementData:GetLimit()
    return self.data.limit
end

function BigLibraryAchievementData:GetIcon()
    return self.data.icon
end

function BigLibraryAchievementData:GetIconColor()
    return self.data.iconColor
end

function BigLibraryAchievementData:GetItemID_1()
    return self.data.itemID_1
end

function BigLibraryAchievementData:GetItemNum_1()
    return self.data.itemNum_1
end

function BigLibraryAchievementData:GetItemColor_1()
    return self.data.itemColor_1
end


BigLibraryAchievementDataManager = Class(DataManager)

local BigLibraryAchievementDataMgr = BigLibraryAchievementDataManager.New(BigLibraryAchievementData)

function BigLibraryAchievementDataMgr:GetKeys()
    return Data.BigLibraryAchievement.Manager.Instance():GetKeys()
end

return BigLibraryAchievementDataMgr