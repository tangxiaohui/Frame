local BaseNodeClass = require "GUI.Item.GeneralItem"
local utility = require "Utils.Utility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ChallengeGeneralItemCls = Class(BaseNodeClass)

function ChallengeGeneralItemCls:Ctor(parentTransform, itemID, itemNum, itemColor)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ChallengeGeneralItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ChallengeGeneralItem', function(go)
		self:BindComponent(go)
	end)
end

-- function ChallengeGeneralItemCls:OnComponentReady()
-- 	-- 界面加载完毕 初始化函数(只走一次)
-- 	self:InitControls()
-- end

function ChallengeGeneralItemCls:OnResume()
	-- 界面显示时调用
	ChallengeGeneralItemCls.base.OnResume(self)
	self:RegisterControlEvents()
	--self:RegisterNetworkEvents()
end

function ChallengeGeneralItemCls:OnPause()
	-- 界面隐藏时调用
	ChallengeGeneralItemCls.base.OnPause(self)
	self:UnregisterControlEvents()
--	self:UnregisterNetworkEvents()
end

function ChallengeGeneralItemCls:OnEnter()
	-- Node Enter时调用
	ChallengeGeneralItemCls.base.OnEnter(self)
end

function ChallengeGeneralItemCls:OnExit()
	-- Node Exit时调用
	ChallengeGeneralItemCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ChallengeGeneralItemCls:InitControls()
   ChallengeGeneralItemCls.base.InitControls(self)
	local transform = self:GetUnityTransform()
	-- self.Base = transform:Find('Base'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.ItemInfoButton = transform:Find('ItemInfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.BackpackSellItemNumLabel = transform:Find('BackpackSellItem/BackpackSellItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.BackpackSellItemGoldIcon = transform:Find('BackpackSellItem/BackpackSellItemGoldIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.BackpackSellItemValueNumLabel = transform:Find('BackpackSellItem/BackpackSellItemValueNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	-- self.BackpackSellButton = transform:Find('BackpackSellItem/BackpackSellButton'):GetComponent(typeof(UnityEngine.UI.Button))
	-- self.TranslucentLayer = transform:Find('BackpackSellItem/BackpackSellItemSelected/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Hook = transform:Find('BackpackSellItem/BackpackSellItemSelected/Hook'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.ItemIcon = transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Image001 = transform:Find('Frame/Group/Image001'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Image003 = transform:Find('Frame/Group/Image003'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Image002 = transform:Find('Frame/Group/Image002'):GetComponent(typeof(UnityEngine.UI.Image))
	-- self.Image004 = transform:Find('Frame/Group/Image004'):GetComponent(typeof(UnityEngine.UI.Image))
--	self.GeneralItemNumLabel = transform:Find('GeneralItemNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
end


function ChallengeGeneralItemCls:RegisterControlEvents()
	-- 注册 ItemInfoButton 的事件
	-- self.__event_button_onItemInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnItemInfoButtonClicked, self)
	-- self.ItemInfoButton.onClick:AddListener(self.__event_button_onItemInfoButtonClicked__)

	-- -- 注册 BackpackSellButton 的事件
	-- self.__event_button_onBackpackSellButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackpackSellButtonClicked, self)
	-- self.BackpackSellButton.onClick:AddListener(self.__event_button_onBackpackSellButtonClicked__)

end

function ChallengeGeneralItemCls:UnregisterControlEvents()
	-- -- 取消注册 ItemInfoButton 的事件
	-- if self.__event_button_onItemInfoButtonClicked__ then
	-- 	self.ItemInfoButton.onClick:RemoveListener(self.__event_button_onItemInfoButtonClicked__)
	-- 	self.__event_button_onItemInfoButtonClicked__ = nil
	-- end

	-- -- 取消注册 BackpackSellButton 的事件
	-- if self.__event_button_onBackpackSellButtonClicked__ then
	-- 	self.BackpackSellButton.onClick:RemoveListener(self.__event_button_onBackpackSellButtonClicked__)
	-- 	self.__event_button_onBackpackSellButtonClicked__ = nil
	-- end

end

function ChallengeGeneralItemCls:RegisterNetworkEvents()
end

function ChallengeGeneralItemCls:UnregisterNetworkEvents()
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ChallengeGeneralItemCls:OnItemInfoButtonClicked()
	--ItemInfoButton控件的点击事件处理
end

function ChallengeGeneralItemCls:OnBackpackSellButtonClicked()
	--BackpackSellButton控件的点击事件处理
end

return ChallengeGeneralItemCls
