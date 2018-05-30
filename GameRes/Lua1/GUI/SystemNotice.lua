local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local SystemNoticeCls = Class(BaseNodeClass)
windowUtility.SetMutex(SystemNoticeCls, true)

function SystemNoticeCls:Ctor()
end

function SystemNoticeCls:OnWillShow(msg)
	self.msg = msg
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SystemNoticeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/SystemNotice', function(go)
		self:BindComponent(go)
	end)
end

function SystemNoticeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function SystemNoticeCls:OnResume()
	-- 界面显示时调用
	SystemNoticeCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:InitNoticeContentView()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function SystemNoticeCls:OnPause()
	-- 界面隐藏时调用
	SystemNoticeCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function SystemNoticeCls:OnEnter()
	-- Node Enter时调用
	SystemNoticeCls.base.OnEnter(self)
end

function SystemNoticeCls:OnExit()
	-- Node Exit时调用
	SystemNoticeCls.base.OnExit(self)
end

function SystemNoticeCls:IsTransition()
    return false
end

function SystemNoticeCls:OnExitTransitionDidStart(immediately)
	SystemNoticeCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function SystemNoticeCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SystemNoticeCls:InitControls()
	local transform = self:GetUnityTransform()
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.ContentLabel = transform:Find("Base/AnnouncementLabel/Viewport/Content/NoticeContentLabel"):GetComponent(typeof(UnityEngine.UI.Text))
	self.AnnouncementConfirmButton = transform:Find('Base/AnnouncementConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.tweenObjectTrans = transform:Find('Base')
end


function SystemNoticeCls:RegisterControlEvents()
	-- 注册 AnnouncementConfirmButton 的事件
	self.__event_button_onAnnouncementConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAnnouncementConfirmButtonClicked, self)
	self.AnnouncementConfirmButton.onClick:AddListener(self.__event_button_onAnnouncementConfirmButtonClicked__)
end

function SystemNoticeCls:UnregisterControlEvents()
	-- 取消注册 AnnouncementConfirmButton 的事件
	if self.__event_button_onAnnouncementConfirmButtonClicked__ then
		self.AnnouncementConfirmButton.onClick:RemoveListener(self.__event_button_onAnnouncementConfirmButtonClicked__)
		self.__event_button_onAnnouncementConfirmButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function SystemNoticeCls:OnAnnouncementConfirmButtonClicked()
	--AnnouncementConfirmButton控件的点击事件处理
	self:Hide()
end

function SystemNoticeCls:InitNoticeContentView()
	self.ContentLabel.text = self.msg
end

return SystemNoticeCls