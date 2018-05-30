--
-- User: fenghao
-- Date: 06/07/2017
-- Time: 10:44 AM
--

require "StaticData.Manager"

local SceneData = Class(LuaObject)

function SceneData:Ctor(id)
    local sceneMgr = Data.Scene.Manager.Instance()
    self.data = sceneMgr:GetObject(id)
    if self.data == nil then
        error(string.format("场景数据，ID: %s 不存在", id))
    end
end

function SceneData:GetId()
    return self.data.id
end

function SceneData:GetMapName()
    return self.data.mapname
end

function SceneData:GetBgm()
	return self.data.bgm
end

function SceneData:GetCameraBloom()
    return self.data.cameraBloom
end

local sceneManagerClass = Class(DataManager)
return sceneManagerClass.New(SceneData)
