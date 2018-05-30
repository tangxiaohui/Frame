require "Framework.GameSubSystem"

local PoolManagerTypeNet = _G.ResCtrl.PoolManager

local PoolManager = Class(GameSubSystem)

function PoolManager:Ctor()

end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function GetPoolManagerImpl(self)
    return self.poolManagerImpl
end


-----------------------------------------------------------------------
--- 池和资源控制接口
-----------------------------------------------------------------------
function PoolManager:CreatePool(name, prefab, maxInstances, tag, limitMode)
    return GetPoolManagerImpl(self):CreatePool(name, prefab, maxInstances, tag, limitMode)
end

function PoolManager:DestroyPool(name)
    GetPoolManagerImpl(self):DestroyPool(name)
end

function PoolManager:DestroyPoolsByTag(tag)
    GetPoolManagerImpl(self):DestroyPoolsByTag(tag)
end

function PoolManager:DestroyAllPools()
    GetPoolManagerImpl(self):DestroyAllPools()
end

function PoolManager:GetPrefab(name)
    return GetPoolManagerImpl(self):GetPrefabL(name)
end

function PoolManager:Spawn(name)
    return GetPoolManagerImpl(self):SpawnL(name)
end

function PoolManager:Despawn(name, instance)
    return GetPoolManagerImpl(self):DespawnL(name, instance)
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 接口
-----------------------------------------------------------------------
local function LoadPoolManagerInstance()
    local go = UnityEngine.GameObject.New("PoolManager")
    UnityEngine.Object.DontDestroyOnLoad(go)
    return go:AddComponent(typeof(PoolManagerTypeNet))
end

local function InitComponents(self, poolManagerInstance)
    self.poolManagerImpl = poolManagerInstance
end

function PoolManager:GetGuid()
    return require "Framework.SubsystemGUID".PoolManager
end

function PoolManager:Startup()
    InitComponents(self, LoadPoolManagerInstance())
end

function PoolManager:Shutdown()
end

function PoolManager:Restart()
end

function PoolManager:Update()
end

return PoolManager
