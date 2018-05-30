-- 管理场景中所有摄像机 显示 隐藏 激活 时 Bloom的设置和缓存 --

require "Collection.OrderedDictionary"

-- 设置 Blooms --
function Battlefield:SetupBlooms()
    -- cameraObject => Component
    self.bloomDict = OrderedDictionary.New()
end

local function GetBloomData(self)
    return self:GetCameraBloomData()
end

function Battlefield:EnableBloomEffect(cameraObject)
    local component = self.bloomDict:GetEntryByKey(cameraObject)
    if component == nil then
        -- 数据获取不到 --
        local bloomData = GetBloomData(self)
        if bloomData == nil then
            return
        end
		
        -- 添加Bloom Component --
        local cameraComponent = cameraObject:GetComponent(typeof(UnityEngine.Camera))
        component = CameraBloomUtility.AddComponentByData(cameraComponent, bloomData)
        self.bloomDict:Add(cameraObject, component)
    end
    component.enabled = true
end

function Battlefield:DisableBloomEffect(cameraObject)
    local component = self.bloomDict:GetEntryByKey(cameraObject)
    if component ~= nil then
        component.enabled = false
    end
end

function Battlefield:RemoveBloomEffect(cameraObject)
    local component = self.bloomDict:GetEntryByKey(cameraObject)
    if component ~= nil then
        UnityEngine.Component.Destroy(component)
        return self.bloomDict:Remove(cameraObject)
    end
    return false
end
