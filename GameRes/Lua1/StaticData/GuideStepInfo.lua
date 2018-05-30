require "StaticData.Manager"

GuideStepInfoData = Class(LuaObject)

function GuideStepInfoData:Ctor(id)
    local GuideStepInfoMgr = Data.GuideStepInfo.Manager.Instance()
    self.data = GuideStepInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("新手引导对白信息不存在，ID: %s 不存在", id))
        return
    end
end

function GuideStepInfoData:GetId()
    return self.data.id
end

function GuideStepInfoData:GetContent()
    return self.data.content
end

GuideStepInfoManager = Class(DataManager)

local GuideStepInfoDataMgr = GuideStepInfoManager.New(GuideStepInfoData)
return GuideStepInfoDataMgr