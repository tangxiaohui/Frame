--
-- User: fbmly
-- Date: 3/17/17
-- Time: 8:18 PM
--

require "Framework.GameSubSystem"

-- 放置从网络上更新的数据 --

local DataCacheManager = Class(GameSubSystem)

function DataCacheManager:Ctor()
    self.dataCache = {}
end

-----------------------------------------------------------------------
--- 外部接口
-----------------------------------------------------------------------
function DataCacheManager:UpdateData(name, updateFunc)
    local utility = require "Utils.Utility"
    utility.ASSERT(name ~= nil, "name 字段不能为 nil")
    utility.ASSERT(type(updateFunc) == "function", "updateFunc 字段必须是 function")

    local oldData = self.dataCache[name]
    self.dataCache[name] = updateFunc(oldData)
    oldData = nil
end

function DataCacheManager:GetData(name)
    local utility = require "Utils.Utility"
    utility.ASSERT(name ~= nil, "name 字段不能为 nil")
    return self.dataCache[name]
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 的接口
-----------------------------------------------------------------------
function DataCacheManager:GetGuid()
    return require "Framework.SubsystemGUID".DataCacheManager
end

function DataCacheManager:Startup()
end

function DataCacheManager:Shutdown()
end

function DataCacheManager:Restart()
end

function DataCacheManager:Update()
end

return DataCacheManager