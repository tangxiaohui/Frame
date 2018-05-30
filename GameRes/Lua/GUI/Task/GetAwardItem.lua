local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
--local net = require "Network.Net"
--local messageManager = require "Network.MessageManager"
require "System.LuaDelegate"

-----------------------------------------------------------------------
local GetAwardItemCls = Class(BaseNodeClass)
windowUtility.SetMutex(GetAwardItemCls, true)

function GetAwardItemCls:Ctor()
end
function GetAwardItemCls:OnWillShow(items,ctable,func)
	self.items = items
	if ctable ~= nil and func ~= nil then
		self.callback = LuaDelegate.New()
		self.callback:Set(ctable,func)
	end
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GetAwardItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ItemReward', function(go)
		self:BindComponent(go)
	end)
end

function GetAwardItemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GetAwardItemCls:OnResume()
	-- 界面显示时调用
	GetAwardItemCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:RefreshPanel()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function GetAwardItemCls:OnPause()
	-- 界面隐藏时调用
	GetAwardItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function GetAwardItemCls:OnEnter()
	-- Node Enter时调用
	GetAwardItemCls.base.OnEnter(self)
end

function GetAwardItemCls:OnExit()
	-- Node Exit时调用
	GetAwardItemCls.base.OnExit(self)
end


function GetAwardItemCls:IsTransition()
    return false
end

function GetAwardItemCls:OnExitTransitionDidStart(immediately)
	GetAwardItemCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function GetAwardItemCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GetAwardItemCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	-- 返回按钮
 	self.RetrunButton = transform:Find('Base/ReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
 	-- 挂点
 	self.nodePoint = transform:Find('Base/Award') 	
 	self.myGame = utility:GetGame()
end



function GetAwardItemCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

end

function GetAwardItemCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

end

function GetAwardItemCls:RefreshPanel()
	
	for i = 1 ,#self.items do
		local id = self.items[i].id
		local count = self.items[i].count
		local color = self.items[i].color
		self:LoadItem(id,count,color)
	end
	
end

function GetAwardItemCls:LoadItem(id,count,color)
	local node = require "GUI.Task.AwardItem".New(self.nodePoint,id,count,color)
	self:AddChild(node)
end

function GetAwardItemCls:OnRetrunButtonClicked()
	-- 返回事件
	self:Close()
	if self.callback ~= nil then
		self.callback:Invoke()
	end
end


return GetAwardItemCls