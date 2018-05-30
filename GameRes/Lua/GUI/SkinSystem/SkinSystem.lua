local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "Collection.OrderedDictionary"

-----------------------------------------------------------------------
local SkinSystemCls = Class(BaseNodeClass)
windowUtility.SetMutex(SkinSystemCls, true)

function SkinSystemCls:Ctor()
end
function SkinSystemCls:OnWillShow(id)
	self.id = id
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function SkinSystemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ShowAllSkin', function(go)
		self:BindComponent(go)
	end)
end

function SkinSystemCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitVariable()
	self:InitControls()
end

function SkinSystemCls:OnResume()
	-- 界面显示时调用
	SkinSystemCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()

	--self:GetSkinsData(self.id)

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function SkinSystemCls:OnPause()
	-- 界面隐藏时调用
	SkinSystemCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function SkinSystemCls:OnEnter()
	-- Node Enter时调用
	SkinSystemCls.base.OnEnter(self)
end

function SkinSystemCls:OnExit()
	-- Node Exit时调用
	SkinSystemCls.base.OnExit(self)
end


function SkinSystemCls:IsTransition()
    return false
end

function SkinSystemCls:OnExitTransitionDidStart(immediately)
	SkinSystemCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function SkinSystemCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function SkinSystemCls:InitControls()
	local transform = self:GetUnityTransform()

	self.tweenObjectTrans = transform:Find('Base')
	-- 返回按钮
 	self.RetrunButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

end

function SkinSystemCls:InitVariable()
	self.myGame = utility:GetGame()
	-- 子类管理
	self.NodeCtrlDict = OrderedDictionary.New()
end


function SkinSystemCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

end

function SkinSystemCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

end

function SkinSystemCls:RegisterNetworkEvents()
	--self.myGame:RegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end

function SkinSystemCls:UnregisterNetworkEvents()
	--self.myGame:UnRegisterMsgHandler(net.S2CTaskQueryResult, self, self.OnTaskQueryResponse)
end
-----------------------------------------------------------------------
--- 网络处理
-----------------------------------------------------------------------
-- function SkinSystemCls:OnTaskQueryRequest()
-- 	self.myGame:SendNetworkMessage( require"Network/ServerService".TaskQueryRequest())
-- end

function SkinSystemCls:OnRetrunButtonClicked()
	self:Close()
end


function SkinSystemCls:GetSkinsData(id)
	local UserDataType = require "Framework.UserDataType"
    local cacheData = self:GetCachedData(UserDataType.CardSkinsData)

    local skinid
    local skinData = cacheData:GetCardSkins(id)
    local skinsDataDict = skinData:GetCardSkins()
    for i =1,skinsDataDict:Count() do
    	local data = skinsDataDict:GetEntryByIndex(i)
    	debug_print("@@@皮肤ID",data:GetCardSkinId())
    	skinid = data:GetCardSkinId()
    end

    local _,StaticData,name,icon,itype = require "Utils.GameTools".GetItemDataById(skinid)
    debug_print("@@@皮肤",name,icon,itype)
end


return SkinSystemCls