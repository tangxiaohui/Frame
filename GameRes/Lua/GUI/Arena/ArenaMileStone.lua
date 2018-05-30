local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"

-----------------------------------------------------------------------
local ArenaMileStoneCls = Class(BaseNodeClass)
windowUtility.SetMutex(ArenaMileStoneCls, true)

function ArenaMileStoneCls:Ctor()
end
function ArenaMileStoneCls:OnWillShow()
	
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ArenaMileStoneCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MileStone', function(go)
		self:BindComponent(go)
	end)
end

function ArenaMileStoneCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ArenaMileStoneCls:OnResume()
	-- 界面显示时调用
	ArenaMileStoneCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:OnArenaMilestoneQueryRequest()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ArenaMileStoneCls:OnPause()
	-- 界面隐藏时调用
	ArenaMileStoneCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ArenaMileStoneCls:OnEnter()
	-- Node Enter时调用
	ArenaMileStoneCls.base.OnEnter(self)
end

function ArenaMileStoneCls:OnExit()
	-- Node Exit时调用
	ArenaMileStoneCls.base.OnExit(self)
end


function ArenaMileStoneCls:IsTransition()
    return true
end

function ArenaMileStoneCls:OnExitTransitionDidStart(immediately)
	ArenaMileStoneCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ArenaMileStoneCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ArenaMileStoneCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	-- 返回按钮
 	self.RetrunButton = transform:Find('Base/CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
 	-- 挂点
 	self.nodePoint = transform:Find('Base/Scroll View/Viewport/Content') 
 	-- 次数
 	self.timeLabel = transform:Find('Base/Times/TimesLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

 	self.myGame = utility:GetGame()
end



function ArenaMileStoneCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

end

function ArenaMileStoneCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function ArenaMileStoneCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CArenaMilestoneQueryResult, self, self.OnArenaMilestoneQueryResponse)
end

function ArenaMileStoneCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CArenaMilestoneQueryResult, self, self.OnArenaMilestoneQueryResponse)
end

function ArenaMileStoneCls:OnArenaMilestoneQueryRequest()
	self.myGame:SendNetworkMessage( require"Network/ServerService".OnArenaMilestoneQueryRequest())
end

function ArenaMileStoneCls:OnRetrunButtonClicked()
	-- 返回事件
	self:Close()
end

function ArenaMileStoneCls:OnArenaMilestoneQueryResponse(msg)
	-- body
	print("OnArenaMilestoneQueryResponse")
	self.timeLabel.text = msg.dekaronTimes
	local nodeCls = require "GUI.Arena.MileStoneItem"
	for i = 1 ,#msg.award do
		local node = nodeCls.New(self.nodePoint)
		self:AddChild(node)
		node:RefreshItem(msg.award[i])
		print(msg.award[i].id,"id:")
	end
end


return ArenaMileStoneCls