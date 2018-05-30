require "StaticData.Manager"

StartoSSRData = Class(LuaObject)

function StartoSSRData:Ctor(id)
    local itemInfoMgr = Data.StartoSSR.Manager.Instance()
    self.data = itemInfoMgr:GetObject(id)
    if self.data == nil then
        error(string.format("稀有度星级，ID: %s 不存在", id))
        return
    end
end

function StartoSSRData:GetId()
    return self.data.star
end

function StartoSSRData:GetSSR()
    return self.data.ssr
end


StartoSSRManager = Class(DataManager)

local StartoSSRManager = StartoSSRManager.New(StartoSSRData)

function StartoSSRManager:GetKeys()
	return Data.StartoSSR.Manager.Instance():GetKeys()
end

return StartoSSRManager