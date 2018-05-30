local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local CheckInDescriptionUIPanelCls= Class(BaseNodeClass)

function CheckInDescriptionUIPanelCls:Ctor()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CheckInDescriptionUIPanelCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/CheckInDescription', function(go)
		self:BindComponent(go)
	end)
end

function CheckInDescriptionUIPanelCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function CheckInDescriptionUIPanelCls:OnResume()
	-- 界面显示时调用
	CheckInDescriptionUIPanelCls.base.OnResume(self)
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()

	-- self:FadeIn(function(self, t)
 --        local transform = self.tweenObjectTrans

 --        local TweenUtility = require "Utils.TweenUtility"
 --        local s = TweenUtility.EaseOutBack(0, 1, t)

 --        transform.localScale = Vector3(s, s, s)
 --    end)

	
end


-- function CheckInDescriptionUIPanelCls:OnExitTransitionDidStart(immediately)
--     CheckInDescriptionUIPanelCls.base.OnExitTransitionDidStart(self, immediately)

--     if not immediately then
--         self:FadeOut(function(self, t)
--             local transform = self.tweenObjectTrans

--             local TweenUtility = require "Utils.TweenUtility"

--             local s = TweenUtility.EaseInBack(1, 0, t)
--             transform.localScale = Vector3(s, s, s)
--         end)
--     end
-- end

function CheckInDescriptionUIPanelCls:OnPause()
	-- 界面隐藏时调用
	CheckInDescriptionUIPanelCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function CheckInDescriptionUIPanelCls:OnEnter()
	-- Node Enter时调用
	CheckInDescriptionUIPanelCls.base.OnEnter(self)
end

function CheckInDescriptionUIPanelCls:OnExit()
	-- Node Exit时调用
	CheckInDescriptionUIPanelCls.base.OnExit(self)

end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CheckInDescriptionUIPanelCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	--描述面板确定按钮
	self.CheckInDescriptionConfirmButton = transform:Find('CheckInDescriptionQueDingButton'):GetComponent(typeof(UnityEngine.UI.Button))--返回按钮
	--描述面板确定按钮
	self.CheckInDescriptionReturnButton = transform:Find('CheckInDescriptionRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))--返回按钮
	--描述面板
	self.CheckInDescriptionText = transform:Find('Scroll View/Viewport/Content/CheckInDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))--描述Text

	local id = require"StaticData.SystemConfig.SystemBasis":GetData(KSystemBasis_CheckID):GetDescriptionInfo()[0]
	local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	local str = string.gsub(hintStr,"\\n","\n")
	self.CheckInDescriptionText.text = str


end


function CheckInDescriptionUIPanelCls:RegisterControlEvents()
	-- 注册 CheckInDescriptionConfirmButton 的事件
	self.__event_button_onCheckInDescriptionConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInDescriptionCancelButtonClicked, self)
	self.CheckInDescriptionConfirmButton.onClick:AddListener(self.__event_button_onCheckInDescriptionConfirmButtonClicked__)

	-- 注册 CheckInDescriptionReturnButton 的事件
	self.__event_button_onCheckInDescriptionReturnClicked__ = UnityEngine.Events.UnityAction(self.OnCheckInDescriptionCancelButtonClicked, self)
	self.CheckInDescriptionReturnButton.onClick:AddListener(self.__event_button_onCheckInDescriptionReturnClicked__)

	

end

function CheckInDescriptionUIPanelCls:UnregisterControlEvents()
	-- 取消注册 CheckInDescriptionConfirmButton 的事件
	if self.__event_button_onCheckInDescriptionConfirmButtonClicked__ then
		self.CheckInDescriptionConfirmButton.onClick:RemoveListener(self.__event_button_onCheckInDescriptionConfirmButtonClicked__)
		self.__event_button_onModifyNameRetrunButtonClicked__ = nil
	end

	-- 取消注册 CheckInDescriptionReturnButton 的事件
	if self.__event_button_onModifyNameRandomButtonClicked__ then
		self.CheckInDescriptionReturnButton.onClick:RemoveListener(self.__event_button_onCheckInDescriptionReturnClicked__)
		self.__event_button_onCheckInDescriptionReturnClicked__ = nil
	end
end




function CheckInDescriptionUIPanelCls:OnCheckInDescriptionCancelButtonClicked()
	print("OnCheckInDescriptionCancelButtonClicked")
	--CheckInDescriptionConfirmButton  CheckInDescriptionReturnButton控件的点击事件处理
    self:Hide()
end




return CheckInDescriptionUIPanelCls
