require "StaticData.Manager"

SkinLevelData = Class(LuaObject)

function SkinLevelData:Ctor(id)
    local SkinLevelMgr = Data.SkinLevel.Manager.Instance()
    
    self.data = SkinLevelMgr:GetObject(id)
    if self.data == nil then
        error(string.format("卡牌等级信息不存在，ID: %s 不存在", id))
        return
    end
end

function SkinLevelData:GetLevel()
    return self.data.level
end

function SkinLevelData:GetExp()
    return self.data.exp
end

SkinLevelManager = Class(DataManager)

local SkinLevelDataMgr = SkinLevelManager.New(SkinLevelData)

function SkinLevelDataMgr:GetKeys()
	return Data.SkinLevel.Manager.Instance():GetKeys()
end

return SkinLevelDataMgr