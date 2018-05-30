local BaseNodeClass=require"Framework.Base.UIScene"
local utility=require"Utils.Utility"

local NGCCls=Class(BaseNodeClass)

function NGCCls:Ctor()
end

---------------场景状态-----------------------------

--加载界面（只走一次）
function NGCCls:OnInit()
	utility.LoadNewGameObjectAsync('UI/Prefabs/NewBigLibrary',function (go)
		self:BindComponent(go)
	end)
end

--界面加载完毕 初始化函数只走一次
function NGCCls:OnComponentReady()
	self:InitControls()
end

--界面显示时调用
function NGCCls:OnResume()
	NGCCls.base.OnResume(self)
	self:RegisterControlEvents()

end

--界面隐藏时调用
function NGCCls:OnPause()
	NGCCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function NGCCls:OnEnter()
	NGCCls.base.OnEnter(self)
end

function NGCCls:OnExit()
	NGCCls.base.OnExit(self)
end

function NGCCls:Update()
	self.Countdown()
end

--开始时调用--绑定控件
function NGCCls:InitControls()
	local transform=self:GetUnityTransform()
    --整个界面的返回键
	self.BigLibraryReturnButton=transform:Find('BigLibraryReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	--获取攻略按钮
	self.BigLibraryStrategyButton=transform:Find('FeaturesBookmark/BigLibraryStrategyButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.IsShowStrategy=false
	
	
end

function NGCCls:RegisterControlEvents()
	--注册BigLibraryReturnButton事件
	self._event_button_OnBigLibraryReturnButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryReturnButtonClicked,self)
	self.BigLibraryReturnButton.onClick:AddListener(self._event_button_OnBigLibraryReturnButtonClicked_)

	--注册BigLibraryStrategyButton事件
	self._event_button_OnBigLibraryStrategyButtonClicked_=UnityEngine.Events.UnityAction(self.BigLibraryStrategyButtonClicked,self)
	self.BigLibraryStrategyButton.onClick:AddListener(self._event_button_OnBigLibraryStrategyButtonClicked_)

end

function NGCCls:UnregisterControlEvents()
	--取消注册BigLibraryStrategyButton事件
	if self._event_button_OnBigLibraryStrategyButtonClicked_ then
		self.BigLibraryStrategyButton.onClick:RemoveListener(self._event_button_OnBigLibraryStrategyButtonClicked_)
		self._event_button_OnBigLibraryStrategyButtonClicked_=nil
	end
	--取消注册BigLibraryReturnButton事件
	if self._event_button_OnBigLibraryReturnButtonClicked_ then
		self.BigLibraryReturnButton.onClick:RemoveListener(self._event_button_OnBigLibraryReturnButtonClicked_)
		self._event_button_OnBigLibraryReturnButtonClicked_=nil
	end
end

function NGCCls:BigLibraryStrategyButtonClicked()
	--设置界面显示
	if self.IsShowStrategy then
		return
	end
	local windowManager=self:GetGame():GetWindowManager()
	windowManager:Show(require"GUI.NGC.AllBigLibrary")
	self.IsShowStrategy=true
	

end

function NGCCls:BigLibraryReturnButtonClicked()

	local sceneManager=utility:GetGame():GetSceneManager()
	sceneManager:PopScene()
	
end

return NGCCls