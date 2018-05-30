local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
require "GUI.Spine.SpineController"
local messageGuids = require "Framework.Business.MessageGuids"

local DepositCls = Class(BaseNodeClass)
windowUtility.SetMutex(DepositCls, true)

function DepositCls:Ctor()
	self.ctrl = SpineController.New()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function DepositCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Deposit', function(go)
		self:BindComponent(go)
	end)
end

function DepositCls:OnWillShow()
end

function DepositCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function DepositCls:OnResume()
	-- 界面显示时调用
	DepositCls.base.OnResume(self) 
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.game:SendNetworkMessage(require"Network.ServerService".VipChongZhiQueryRequest())
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
    end)
    self:BringToFront()
    self:InitSpineShow()
end

function DepositCls:InitSpineShow()
	self.ctrl:SetData(self.skeletonGraphic,self.speakerText,4)
	--self.ctrl:StartPlay()
end

function DepositCls:CloseSpine()
	self.ctrl:Stop()
end

function DepositCls:OnPause()
	-- 界面隐藏时调用
	DepositCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:CloseSpine()
end

function DepositCls:OnEnter()
	-- Node Enter时调用
	DepositCls.base.OnEnter(self)
end

function DepositCls:OnExit()
	-- Node Exit时调用
	DepositCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function DepositCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game=utility:GetGame()
	self.TranslucentLayer = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	self.BigFarme = transform:Find('Base/BigFarme'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Base = transform:Find('Base/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.DownerDecoration = transform:Find('Base/DownerDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.UpperDecoration = transform:Find('Base/UpperDecoration'):GetComponent(typeof(UnityEngine.UI.Image))
	self.RetrunButton = transform:Find('Base/RetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Scroll_View = transform:Find('Base/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.parent = transform:Find('Base/Scroll View/Viewport/Content')
	self.Viewport = transform:Find('Base/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.Title = transform:Find('Base/Title'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Button = transform:Find('Base/Button'):GetComponent(typeof(UnityEngine.UI.Button))
	
	self.skeletonGraphic= transform:Find('Base/shenle/SkeletonGraphic (Bdwz)'):GetComponent(typeof(Spine.Unity.SkeletonGraphic))
	self.speakerText=transform:Find('Frame/Text'):GetComponent(typeof(UnityEngine.UI.Text))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self:InitViews()
end

function DepositCls:DidChildCallBack(flag,infoText)
	-- -- body
	-- print("DidChildCallBack",flag,infoText)
	-- if flag then
	-- 	if self.rotateCou == nil then self.rotateCou = self:StartCoroutine(RotateTrans) end
	-- 	self.connecting.parent.gameObject:SetActive(flag)
	-- else
	-- 	self:StopCoroutine(self.rotateCou)
	-- 	self.connecting.parent.gameObject:SetActive(flag)
	-- 	local ConfirmDialogClass = require "GUI.Dialogs.ErrorDialog"
	-- 	utility:GetGame():GetWindowManager():Show(ConfirmDialogClass, "充值失败！")
	-- end
end

function DepositCls:InitViews()
	local DataCls = require "StaticData.Activity.RechargeSDK"
    local rechargeSDKMgr = Data.RechargeSDK.Manager.Instance()
    local keys = rechargeSDKMgr:GetKeys()

    local length = keys.Length-1
    for i = 0, length do
        local data = DataCls:GetData(keys[i])
        -- print(data:GetDes(),data:GetFirstDiamond())
        local DepositItem = require"GUI.Deposit.DepositItem".New(data,self.parent)
        -- DepositItem:SetCallback(self,self.DidChildCallBack)
        self:AddChild(DepositItem)
    end
end

function DepositCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)


	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 Scroll_View 的事件
	self.__event_scrollrect_onScroll_ViewValueChanged__ = UnityEngine.Events.UnityAction_UnityEngine_Vector2(self.OnScroll_ViewValueChanged, self)
	self.Scroll_View.onValueChanged:AddListener(self.__event_scrollrect_onScroll_ViewValueChanged__)

	-- 注册 Button 的事件
	self.__event_button_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
	self.Button.onClick:AddListener(self.__event_button_onButtonClicked__)
end

function DepositCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

	-- 取消注册 Scroll_View 的事件
	if self.__event_scrollrect_onScroll_ViewValueChanged__ then
		self.Scroll_View.onValueChanged:RemoveListener(self.__event_scrollrect_onScroll_ViewValueChanged__)
		self.__event_scrollrect_onScroll_ViewValueChanged__ = nil
	end

	-- 取消注册 Button 的事件
	if self.__event_button_onButtonClicked__ then
		self.Button.onClick:RemoveListener(self.__event_button_onButtonClicked__)
		self.__event_button_onButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function DepositCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CVipChongZhiQueryResult, self, self.VipChongZhiQueryResult)
end

function DepositCls:UnregisterNetworkEvents()
	 self.game:UnRegisterMsgHandler(net.S2CVipChongZhiQueryResult, self, self.VipChongZhiQueryResult)
end

function DepositCls:VipChongZhiQueryResult(msg)
	-- TODO 显示首冲标识 服务器告知状态 还未处理
    debug_print("shouchongState",msg.shouchongState,"monthlyCardID",msg.card.monthlyCardID,"monthlyCardRemainDrawDay",msg.card.monthlyCardRemainDrawDay)
    debug_print("alreadyBuy",msg.diamondLibaos.alreadyBuy,"totalCharge",msg.totalCharge)
end

function DepositCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function DepositCls:OnRetrunButtonClicked()
	--RetrunButton控件的点击事件处理
	self:Hide()
end

function DepositCls:OnScroll_ViewValueChanged(posXY)
	--Scroll_View控件的点击事件处理
end

function DepositCls:OnButtonClicked()
	--Button控件的点击事件处理
	local windowManager = self:GetWindowManager()
    local VipSenceCls = require "GUI.VIP.VipSence"
    windowManager:Show(VipSenceCls)
    self:Hide()
end

return DepositCls
