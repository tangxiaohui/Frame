
local BaseNodeClass =  require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"

local BusinessTestPanel = Class(BaseNodeClass)

require "LUT.StringTable"

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(BusinessTestPanel, true)

function BusinessTestPanel:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function BusinessTestPanel:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/BusinessTestPanel', function(go)
        self:BindComponent(go)
    end)
end

function BusinessTestPanel:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:InitControls()
end

function BusinessTestPanel:OnResume()
    -- 界面显示时调用
    BusinessTestPanel.base.OnResume(self)
    self:RegisterControlEvents()

    self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function BusinessTestPanel:OnPause()
    -- 界面隐藏时调用
    BusinessTestPanel.base.OnPause(self)
    self:UnregisterControlEvents()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function BusinessTestPanel:InitControls()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find('Base')
    self.prefabTemplateObject = transform:Find('ButtonTemplate').gameObject
    self.contentTrans = transform:Find('Base/Scroll View/Viewport/Content')
    self.CloseButton = transform:Find('Base/Base/Button'):GetComponent(typeof(UnityEngine.UI.Button))

    self:InitButtons()
    self:CreateButtons()
end

function BusinessTestPanel:CreateButtons()
    for i = 1, #self.buttons do
        self:AddChild(self.buttons[i])
    end
end

function BusinessTestPanel:RegisterControlEvents()
    -- 注册 CloseButton 的事件
    self.__event_closebutton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCloseButtonClicked, self)
    self.CloseButton.onClick:AddListener(self.__event_closebutton_onButtonClicked__)
end

function BusinessTestPanel:RegisterNetworkEvents()

end

function BusinessTestPanel:UnregisterControlEvents()
    -- 取消注册 Button 的事件
    if self.__event_closebutton_onButtonClicked__ then
        self.CloseButton.onClick:RemoveListener(self.__event_closebutton_onButtonClicked__)
        self.__event_closebutton_onButtonClicked__ = nil
    end
end

function BusinessTestPanel:UnregisterNetworkEvents()

end

function BusinessTestPanel:OnCloseButtonClicked()
    self:Close()
end

-----------------------------------------------------------------------
--- 动画
-----------------------------------------------------------------------

function BusinessTestPanel:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function BusinessTestPanel:OnExitTransitionDidStart(immediately)
    BusinessTestPanel.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 初始化按钮
-----------------------------------------------------------------------
local function AddButton(title, self, func)
    local BusinessTestButtonClass = require "GUI.BusinessTestButton"
    local instance = BusinessTestButtonClass.New(title, self.prefabTemplateObject, self.contentTrans)
    instance:SetCallback(self, func)
    return instance
end

-----------------------------------------------------------------------
--- 初始化按钮 & 事件
-----------------------------------------------------------------------

--- ### 添加按钮在这里
function BusinessTestPanel:InitButtons()
    self.buttons = {
        -- 为测试功能 不用加入到本地化里
        AddButton("查询背包", self, self.OnCardBagQuery),
        AddButton("请求上阵", self, self.OnPutCardOnLineup),
        AddButton("请求下阵", self, self.OnPutCardOffLineup),
        AddButton("地图信息", self, self.OnQueryAllMaps),
        AddButton("保护公主", self, self.OnProtectQuery)
    }
end


local ServerService = require "Network.ServerService"

--- # 按钮处理事件放这里
require "Const"

---- ### 卡包查询 ###
function BusinessTestPanel:OnCardBagQuery()
    local msg, prototype = ServerService.CardBagQuery()
    self:GetGame():SendNetworkMessage(msg, prototype)
end

function BusinessTestPanel:OnPutCardOnLineup()
    local msg, prototype = ServerService.PutCardOnLineup("c:10000014", kLineup_Attack, 1)
    self:GetGame():SendNetworkMessage(msg, prototype)
end

function BusinessTestPanel:OnPutCardOffLineup()
    local msg, prototype = ServerService.PutCardOffLineup(kLineup_Attack, 1)
    self:GetGame():SendNetworkMessage(msg, prototype)
end

function BusinessTestPanel:OnQueryAllMaps()
    local msg, prototype = ServerService.QueryAllMaps()
    self:GetGame():SendNetworkMessage(msg, prototype)
end

function BusinessTestPanel:OnProtectQuery()
    local levelLimit = require "StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_DefendPrincess):GetMinLevel()
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    if userData:GetLevel() < levelLimit then
        local ErrorDialogClass = require "GUI.Dialogs.ErrorDialog"
        local windowManager = self:GetGame():GetWindowManager()
        local hintStr = string.format(CommonStringTable[0],levelLimit)
        windowManager:Show(ErrorDialogClass, hintStr)
        return true
    end

    local sceneManager = self:GetGame():GetSceneManager()
    local DefendPrincessClass = require "Scenes.DefendThePrincessScene"
    sceneManager:PushScene(DefendPrincessClass.New())
--    local msg, prototype = ServerService.ProtectQueryRequest()
--    self:GetGame():SendNetworkMessage(msg, prototype)
end


return BusinessTestPanel

