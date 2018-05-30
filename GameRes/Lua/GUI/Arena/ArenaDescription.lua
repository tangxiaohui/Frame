local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
require "Const"

local ArenaDescriptionCls = Class(BaseNodeClass)
windowUtility.SetMutex(ArenaDescriptionCls, true)

function ArenaDescriptionCls:Ctor()
end

function  ArenaDescriptionCls:OnWillShow(index)
	self.id = index
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ArenaDescriptionCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ArenaDescription', function(go)
		self:BindComponent(go)
	end)
end

function ArenaDescriptionCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ArenaDescriptionCls:OnResume()
	-- 界面显示时调用
	ArenaDescriptionCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
    self:LoadItem(self.id)
end

function ArenaDescriptionCls:OnPause()
	-- 界面隐藏时调用
	ArenaDescriptionCls.base.OnPause(self)
	self:UnregisterControlEvents()
	--self:UnregisterNetworkEvents()
end

function ArenaDescriptionCls:OnEnter()
	-- Node Enter时调用
	ArenaDescriptionCls.base.OnEnter(self)
end

function ArenaDescriptionCls:OnExit()
	-- Node Exit时调用
	ArenaDescriptionCls.base.OnExit(self)
end

function ArenaDescriptionCls:IsTransition()
    return true
end

function ArenaDescriptionCls:OnExitTransitionDidStart(immediately)
	ArenaDescriptionCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function ArenaDescriptionCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ArenaDescriptionCls:InitControls()
	local transform = self:GetUnityTransform()
	self.ArenaDescriptionLabel = transform:Find('ArenaDescriptionBase/Scroll View/Viewport/Content/ArenaDescriptionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self.ArenaDescriptionButton = transform:Find('ArenaDescriptionBase/ArenaDescriptionButton'):GetComponent(typeof(UnityEngine.UI.Button))

	self.tweenObjectTrans = transform:Find('ArenaDescriptionBase')
end


function ArenaDescriptionCls:RegisterControlEvents()
	-- 注册 ArenaDescriptionButton 的事件
	self.__event_button_onArenaDescriptionButtonClicked__ = UnityEngine.Events.UnityAction(self.OnArenaDescriptionButtonClicked, self)
	self.ArenaDescriptionButton.onClick:AddListener(self.__event_button_onArenaDescriptionButtonClicked__)
end

function ArenaDescriptionCls:UnregisterControlEvents()
	-- 取消注册 ArenaDescriptionButton 的事件
	if self.__event_button_onArenaDescriptionButtonClicked__ then
		self.ArenaDescriptionButton.onClick:RemoveListener(self.__event_button_onArenaDescriptionButtonClicked__)
		self.__event_button_onArenaDescriptionButtonClicked__ = nil
	end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ArenaDescriptionCls:OnArenaDescriptionButtonClicked()
	--ArenaDescriptionButton控件的点击事件处理
	self:Close()
end

function ArenaDescriptionCls:LoadItem(index)
	local id = require"StaticData.SystemConfig.SystemBasis":GetData(index):GetDescriptionInfo()[0]
	
	local hintStr = require "StaticData.SystemConfig.SystemDescriptionInfo":GetData(id):GetDescription()
	local str = string.gsub(hintStr,"\\n","\n")
	self.ArenaDescriptionLabel.text = str

end

return ArenaDescriptionCls