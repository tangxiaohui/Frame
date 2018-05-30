local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Collection.OrderedDictionary"

-----------------------------------------------------------------------
local GetSkinCls = Class(BaseNodeClass)
windowUtility.SetMutex(GetSkinCls, true)

function GetSkinCls:Ctor()
end
function GetSkinCls:OnWillShow(id)
	self.id = id
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GetSkinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GetCardSkin', function(go)
		self:BindComponent(go)
	end)
end

function GetSkinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitVariable()
	self:InitControls()
end

function GetSkinCls:OnResume()
	-- 界面显示时调用
	GetSkinCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	self:InitView()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function GetSkinCls:OnPause()
	-- 界面隐藏时调用
	GetSkinCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GetSkinCls:OnEnter()
	-- Node Enter时调用
	GetSkinCls.base.OnEnter(self)
end

function GetSkinCls:OnExit()
	-- Node Exit时调用
	GetSkinCls.base.OnExit(self)
end


function GetSkinCls:IsTransition()
    return false
end

function GetSkinCls:OnExitTransitionDidStart(immediately)
	GetSkinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function GetSkinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GetSkinCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	-- 返回按钮
 	self.RetrunButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))
 	self.itemPoint = transform:Find('Base/SkinPoint/Point')
 	local blueEffect = transform:Find('Base/EffectPoint/point/UI_pifu_lan').gameObject
 	local purpleEffect = transform:Find('Base/EffectPoint/point/UI_pifu_lan').gameObject
 	local orangeEffect = transform:Find('Base/EffectPoint/point/UI_pifu_lan').gameObject
 	self.EffctTable = {blueEffect,purpleEffect,orangeEffect}
end

function GetSkinCls:InitVariable()
	self.myGame = utility:GetGame()
	-- 子类管理
	self.NodeCtrlDict = OrderedDictionary.New()
end


function GetSkinCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

end

function GetSkinCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

end

function GetSkinCls:RegisterNetworkEvents()
	--self.myGame:RegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end

function GetSkinCls:UnregisterNetworkEvents()
	--self.myGame:UnRegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
-- function GetSkinCls:OnTaskQueryRequest()
-- 	self.myGame:SendNetworkMessage( require"Network/ServerService".TaskQueryRequest())
-- end

function GetSkinCls:OnRetrunButtonClicked()
	self:Close()
end

function GetSkinCls:InitView()
	local UserDataType = require "Framework.UserDataType"
    local cacheData = self:GetCachedData(UserDataType.CardSkinsData)
    local skinData = cacheData:GetOneSkinData(self.id)
    local skidItem = require "GUI.SkinSystem.CardSkinItem".New(self.itemPoint,self.id)
    self:AddChild(skidItem)

    local gametool = require "Utils.GameTools"
   	local _,staticdata,_,_,itype = gametool.GetItemDataById(self.id)
   	local skinColor = staticdata:GetColor()
   	debug_print(skinColor,"skinColor")
    if skinColor > 1 then
    	debug_print(self.EffctTable[skinColor-1].name)
  		self.EffctTable[skinColor-1]:SetActive(true)
  	end
end


return GetSkinCls