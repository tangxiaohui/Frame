local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"

local TarotScene = Class(BaseNodeClass)

function TarotScene:Ctor()
end

-----------------------------------------------------------------------
--- 回调函数
-----------------------------------------------------------------------
local function OnReturnButtonClicked(self)
    debug_print("TarotScene:OnReturnButtonClicked", self)
    utility.GetGame():GetSceneManager():PopScene()
end

local function OnDescriptionButtonClicked(self)
    local CommonDescriptionModuleClass = require "GUI.CommonDescriptionModule"
    local windowManager = utility.GetGame():GetWindowManager()
    
    local id = require"StaticData.SystemConfig.SystemBasis":GetData(kSystemBasis_Tarot):GetDescriptionInfo()[0]
    local description = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
    windowManager:Show(CommonDescriptionModuleClass, description)
end

-----------------------------------------------------------------------
--- 私有函数
-----------------------------------------------------------------------
local function CreatePropertyItemProvider(self)
    self.propertyItemProvider = require "GUI.Tarot.TarotPropertyItemProvider".New(self.poolTransform, 30)
end


local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 返回按钮
    self.returnButton = transform:Find("Base/Title/ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 说明按钮
    self.descriptionButton = transform:Find("Base/Button"):GetComponent(typeof(UnityEngine.UI.Button))
    
    -- pool
    self.poolTransform = transform:Find("Base/Pool")

    CreatePropertyItemProvider(self)

    -- 塔罗牌滚动条相关
    self:AddChild(require "GUI.Tarot.TarotCardPanel".New(transform:Find("Base/SlideArea")))

    -- 塔罗牌属性相关
    self:AddChild(require "GUI.Tarot.TarotPropertyPanel".New(transform:Find("Base/Status"), self.propertyItemProvider))

    -- 塔罗牌进度相关
    self:AddChild(require "GUI.Tarot.TarotProgressPanel".New(transform:Find("Base/ProgressInfo"), self.propertyItemProvider))
end

local function RegisterEvents(self)
    -- 注册返回按钮事件
    self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(OnReturnButtonClicked, self)
    self.returnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)

    -- 注册说明按钮事件
    self.__event_button_descriptionButtonClicked__ = UnityEngine.Events.UnityAction(OnDescriptionButtonClicked, self)
    self.descriptionButton.onClick:AddListener(self.__event_button_descriptionButtonClicked__)
end

local function UnregisterEvents(self)
    -- 取消注册返回按钮事件
    if self.__event_button_onReturnButtonClicked__ then
        self.returnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
        self.__event_button_onReturnButtonClicked__ = nil
    end

    -- 取消注册说明按钮事件
    if self.__event_button_descriptionButtonClicked__ then
        self.descriptionButton.onClick:RemoveListener(self.__event_button_descriptionButtonClicked__)
        self.__event_button_descriptionButtonClicked__ = nil
    end
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function TarotScene:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync("UI/Prefabs/Tarot", function(go)
		self:BindComponent(go)
	end)
end

function TarotScene:OnComponentReady()
    -- 界面加载&绑定完毕 初始化函数(只走一次)
    InitControls(self)
end

function TarotScene:OnResume()
    -- 界面显示时调用
    TarotScene.base.OnResume(self)
    RegisterEvents(self)
    utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[14].systemGuideID,self)

end

function TarotScene:OnPause()
    -- 界面隐藏时调用
    TarotScene.base.OnPause(self)
    UnregisterEvents(self)
end

function TarotScene:OnCleanup()
    utility.UnloadResource("UI/Prefabs/Tarot", typeof(UnityEngine.GameObject))
    TarotScene.base.OnCleanup(self)
end

return TarotScene
