require "Framework.GameSubSystem"

UICanvas = Class(GameSubSystem)

-----------------------------------------------------------------------
--- 初始化
-----------------------------------------------------------------------
local function InitThingsAboutCanvas(self)
    self.canvasTransform = self.rootTransform:Find("Canvas")
    self.cameraComponent = self.rootTransform:Find("Camera"):GetComponent(typeof(UnityEngine.Camera))
    self.canvasComponent = self.canvasTransform:GetComponent(typeof(UnityEngine.Canvas))
    self.canvasScaler = self.canvasTransform:GetComponent(typeof(UnityEngine.UI.CanvasScaler))

end

function UICanvas:Ctor(uiManager, transform)
    self.uiManager = uiManager
    self.rootTransform = transform
    self.rootGameObject = transform.gameObject

    self.nativeRatio = UnityEngine.Screen.width/UnityEngine.Screen.height

    InitThingsAboutCanvas(self)
end

function UICanvas:SetResolution(width, height)
    self.canvasScaler.uiScaleMode = UnityEngine.UI.CanvasScaler.ScaleMode.ScaleWithScreenSize
    self.canvasScaler.screenMatchMode = UnityEngine.UI.CanvasScaler.ScreenMatchMode.MatchWidthOrHeight
    self.canvasScaler.referenceResolution = Vector2.New(width, height)
end

function UICanvas:SetMatchWidthOrHeight(match)
    self.canvasScaler.matchWidthOrHeight = match
end

function UICanvas:GetCanvasTransform()
    return self.canvasTransform
end

function UICanvas:GetCamera()
    return self.cameraComponent
end

function UICanvas:SetUIMode(isUI)
    if self.cameraComponent == nil then
        return
    end

    if isUI then
        self.cameraComponent.clearFlags = UnityEngine.CameraClearFlags.SolidColor
		self.cameraComponent.backgroundColor = UnityEngine.Color(0,0,0,1)
    else
        self.cameraComponent.clearFlags = UnityEngine.CameraClearFlags.Depth
    end
end

function UICanvas:SetFieldOfView(fov)
    self.cameraComponent.fieldOfView = fov
end

function UICanvas:ShowRoot()
    self.rootGameObject:SetActive(true)
end

function UICanvas:HideRoot()
    self.rootGameObject:SetActive(false)
end

-----------------------------------------------------------------------
--- 方便的函数
-----------------------------------------------------------------------
function UICanvas:SetResolutionInLandscape(width, height)
    self:SetMatchWidthOrHeight(0)
    self:SetResolution(width, height)
end

function UICanvas:SetResolutionInPortrait(width, height)
    self:SetMatchWidthOrHeight(1)
    self:SetResolution(width, height)
end

function UICanvas:SetResolutionAuto(width, height)
    local designedRatio = width / height
    if self.nativeRatio <= designedRatio then
        self:SetMatchWidthOrHeight(0)
    else
        self:SetMatchWidthOrHeight(1)
    end
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 接口
-----------------------------------------------------------------------
-- GetGuid不用实现, 上层不会用 --

function UICanvas:Startup()
end

function UICanvas:Shutdown()
end

function UICanvas:Restart()
end

function UICanvas:Update()
end