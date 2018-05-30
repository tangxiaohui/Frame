--
-- User: fenghao
-- Date: 06/07/2017
-- Time: 8:06 PM
--

require "StaticData.Manager"

local SoundResPathData = Class(LuaObject)

function SoundResPathData:Ctor(id)
    local soundResPathMgr = Data.SoundResPath.Manager.Instance()

    self.data = soundResPathMgr:GetObject(id)
    if self.data == nil then
        error(string.format("音乐资源不存在, ID: %d", id))
    end
end

function SoundResPathData:GetId()
    return self.data.id
end

function SoundResPathData:GetPath()
    return self.data.path
end

local soundResPathManagerClass = Class(DataManager)
return soundResPathManagerClass.New(SoundResPathData)
