require "Framework.GameSubSystem"
require "Framework.UI.UICanvas"
require "Framework.UI.UILayers"
local utility = require "Utils.Utility"

local UIManager = Class(GameSubSystem)

-----------------------------------------------------------------------
--- 内部初始化函数
-----------------------------------------------------------------------

local function InitTempPool(self)
    self.propertyEffectItemObject = self.tempPoolTrans:Find("PropertyEffectItem").gameObject
    self.EffectTextObject = self.tempPoolTrans:Find("EffectText").gameObject
    self.CritEffectTextObject = self.tempPoolTrans:Find("CritEffectText").gameObject
    self.DamageWordEffectObject = self.tempPoolTrans:Find("DamageWordEffect").gameObject
    self.HealEffectTextObject = self.tempPoolTrans:Find("HealEffectText").gameObject
end

-- # 创建 UIGroup
local function LoadUIGroup(self)
    local UnityEngine = UnityEngine
    local Object = UnityEngine.Object
    local prefab = utility.LoadResourceSync("Prefabs/UIGroup", typeof(UnityEngine.GameObject))   -- # UIGroup 不会变动 , 因此用 Resources 就行 # --
    self.gameObject = Object.Instantiate(prefab)
    self.gameObject.name = prefab.name
    Object.DontDestroyOnLoad(self.gameObject)
    self.transform = self.gameObject.transform
    self.eventSystemObject = self.transform:Find("EventSystem").gameObject

    -- # 暂时这么写 # --
    self.tempPoolTrans = self.transform:Find("TempPool")

    InitTempPool(self)
end

function UIManager:GetPropertyEffectItemObject()
    return self.propertyEffectItemObject
end

function UIManager:GetEffectTextObject()
    return self.EffectTextObject
end

function UIManager:GetCritEffectTextObject()
    return self.CritEffectTextObject
end

function UIManager:GetDamageWordEffectObject()
    return self.DamageWordEffectObject
end

function UIManager:GetHealEffectTextObject()
    return self.HealEffectTextObject
end

-- # 初始化 一些相关组件
function UIManager:InitComponents(self)

    -- MainScene 摄像机
    self.mainSceneUICanvas = UICanvas.New(self, self.transform:Find("Canvases/MainScene"))
    self.mainSceneUICanvas:SetResolutionAuto(1334, 750)

    -- Main UI摄像机
    self.mainUICanvas = UICanvas.New(self, self.transform:Find("Canvases/Main"))
    self.mainUICanvas:SetResolutionAuto(1334, 750)
    self.mainUICanvas:SetUIMode(true) -- 设置UI模式 --

    -- 战斗 摄像机
    self.battleUICanvas = UICanvas.New(self, self.transform:Find("Canvases/Battle"))
    self.battleUICanvas:SetResolutionAuto(1334, 750)

    -- 特效 摄像机
    self.effectUICanvas = UICanvas.New(self, self.transform:Find("Canvases/Effect"))
    self.effectUICanvas:SetResolutionAuto(1334, 750)

    -- UILayers
    self.uiLayers = UILayers.New(self, self.mainUICanvas:GetCanvasTransform())

    -- 屏幕点击特效 --
    self.screenParticleEffect = require "Framework.UI.UIScreenParticleEffect".New(self.effectUICanvas, self.eventSystemObject)
end

-----------------------------------------------------------------------
--- 构造函数
-----------------------------------------------------------------------
function UIManager:Ctor()
    LoadUIGroup(self)
    self:InitComponents(self)
end

-----------------------------------------------------------------------
--- 设置 是否显示背景
-----------------------------------------------------------------------
--function UIManager:SetHasBackground(hasBackground)
----    local color = self.backgroundImage.color
----    if hasBackground then
----        color.a = 1
----    else
----        color.a = 0
----    end
----    self.backgroundImage.color = color
--end


-----------------------------------------------------------------------
--- 允许/禁止 输入
-----------------------------------------------------------------------
function UIManager:EnableInput()
    self.eventSystemObject:SetActive(true)
end

function UIManager:DisableInput()
    self.eventSystemObject:SetActive(false)
end

-----------------------------------------------------------------------
--- 实现 GameSubSystem 的接口
-----------------------------------------------------------------------
local function Test()
end

function UIManager:GetGuid()
    return require "Framework.SubsystemGUID".UIManager
end

function UIManager:Startup()
    self.screenParticleEffect:Start()
end

function UIManager:Shutdown()
    self.screenParticleEffect:Reset()
end

function UIManager:Restart()
end

function UIManager:Update()
end


-----------------------------------------------------------------------
--- 获取 UI Transform
-----------------------------------------------------------------------
function UIManager:GetBackgroundLayer()
    return self.uiLayers:GetBackgroundLayer()
end

function UIManager:GetForegroundLayer()
    return self.uiLayers:GetForegroundLayer()
end

function UIManager:GetModuleLayer()
    return self.uiLayers:GetModuleLayer()
end

function UIManager:GetDialogLayer()
    return self.uiLayers:GetDialogLayer()
end

function UIManager:GetOverlayLayer()
    return self.uiLayers:GetOverlayLayer()
end

-----------------------------------------------------------------------
--- 获取组件
-----------------------------------------------------------------------
function UIManager:GetMainSceneUICanvas()
    return self.mainSceneUICanvas
end

function UIManager:GetMainUICanvas()
    return self.mainUICanvas
end

function UIManager:GetBattleUICanvas()
    return self.battleUICanvas
end

function UIManager:GetEffectUICanvas()
    return self.effectUICanvas
end

-----------------------------------------------------------------------
--- Transform的一些接口
-----------------------------------------------------------------------
function UIManager:FindTransform(name)
    return self.transform:Find(name)
end


return UIManager