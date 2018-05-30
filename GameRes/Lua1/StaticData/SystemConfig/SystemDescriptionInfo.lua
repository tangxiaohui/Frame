require "StaticData.Manager"

local SystemDescriptionInfoData = Class(LuaObject)

function SystemDescriptionInfoData:Ctor(id)
    local SystemDescriptionInfoMgr = Data.SystemDescriptionInfo.Manager.Instance()
    
    local data = SystemDescriptionInfoMgr:GetObject(id)
    if data == nil then
        error(
            string.format(
                "系统设置SystemDescriptionInfo信息, ID: %s 不存在",
                id
            )
        )
    end

    self.id = data.id
    self.description = string.gsub(data.description,"\\n","\n")
end

function SystemDescriptionInfoData:GetId()
    return self.id
end

function SystemDescriptionInfoData:GetDescription()
    return self.description
end

local SystemDescriptionInfoManager = Class(DataManager)

local SystemDescriptionInfoDataMgr = SystemDescriptionInfoManager.New(SystemDescriptionInfoData)
return SystemDescriptionInfoDataMgr