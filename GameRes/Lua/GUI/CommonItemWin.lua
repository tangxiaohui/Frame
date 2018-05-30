local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "LUT.StringTable"
local messageGuids = require "Framework.Business.MessageGuids"


-----------------------------------------------------------------------
local CommonItemWinCls = Class(BaseNodeClass)
windowUtility.SetMutex(CommonItemWinCls, true)

function CommonItemWinCls:Ctor()
end
function CommonItemWinCls:OnWillShow(id,possess)
	self.id = id
	self.possess = possess
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function CommonItemWinCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/InformationCheck', function(go)
		self:BindComponent(go)
	end)
end

function CommonItemWinCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
	
end

function CommonItemWinCls:OnResume()
	-- 界面显示时调用
	CommonItemWinCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:InitItemNode()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function CommonItemWinCls:OnPause()
	-- 界面隐藏时调用
	CommonItemWinCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function CommonItemWinCls:OnEnter()
	-- Node Enter时调用
	CommonItemWinCls.base.OnEnter(self)
end

function CommonItemWinCls:OnExit()
	-- Node Exit时调用
	CommonItemWinCls.base.OnExit(self)
end


function CommonItemWinCls:IsTransition()
    return true
end

function CommonItemWinCls:OnExitTransitionDidStart(immediately)
	CommonItemWinCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function CommonItemWinCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function CommonItemWinCls:InitControls()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find('Base')
	self.RetrunButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	-- 名字
	self.nameLabel = transform:Find('Base/ItemNameLable'):GetComponent(typeof(UnityEngine.UI.Text))
	-- 头像
	self.iconImage = transform:Find('Base/ItemBox/EquipIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	-- 颜色
	self.colorFrame = transform:Find('Base/ColorFrame')
	-- 描述
	self.desLabel = transform:Find('Base/StatusLabel'):GetComponent(typeof(UnityEngine.UI.Text))  
	-- 碎片
	self.DebrisIcon = transform:Find('Base/DebrisIcon').gameObject

	-- 使用按钮
	self.ConfirmButton = transform:Find('Base/ConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
end


function CommonItemWinCls:RegisterControlEvents()
	-- 注册 RetrunButton 的事件
	self.__event_button_onRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRetrunButtonClicked, self)
	self.RetrunButton.onClick:AddListener(self.__event_button_onRetrunButtonClicked__)

	-- 注册 使用按钮 的事件
	self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)
end

function CommonItemWinCls:UnregisterControlEvents()
	-- 取消注册 RetrunButton 的事件
	if self.__event_button_onRetrunButtonClicked__ then
		self.RetrunButton.onClick:RemoveListener(self.__event_button_onRetrunButtonClicked__)
		self.__event_button_onRetrunButtonClicked__ = nil
	end

	-- 取消注册 使用按钮 的事件
	if self.__event_button_onConfirmButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
		self.__event_button_onConfirmButtonClicked__ = nil
	end
end

function CommonItemWinCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CItemBagSellResult, self, self.OnItemBagSellResponse)
	utility:GetGame():RegisterMsgHandler(net.S2COpenTreasureChestRewardResult,self,self.OpenTreasureChestRewardResult)
end

function CommonItemWinCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CItemBagSellResult, self, self.OnItemBagSellResponse)
	utility:GetGame():UnRegisterMsgHandler(net.S2COpenTreasureChestRewardResult,self,self.OpenTreasureChestRewardResult)
end

function CommonItemWinCls:ItemBagSellRequest(id)
	utility:GetGame():SendNetworkMessage( require"Network/ServerService".ItemBagSellRequest(id))
end

function CommonItemWinCls:OpenTreasureChestRewardRequest()
	utility:GetGame():SendNetworkMessage( require"Network/ServerService".OpenTreasureChestRewardRequest(0,self.id,1))
end

function CommonItemWinCls:OnItemBagSellResponse()
	self:DispatchEvent(messageGuids.UpdataKnapsackWindow,nil,2)
end

function  CommonItemWinCls:OpenTreasureChestRewardResult(msg)
	if msg.status then
		self:GetItems(msg.openTreasureChestReward)
		self:OnItemBagSellResponse()
	end
end

function CommonItemWinCls:GetItems(item)
	local itemstables = {}
	local gametool = require "Utils.GameTools"
	for i=1,#item do
		itemstables[i] = {}
		itemstables[i].id = item[i].itemID
		itemstables[i].count = item[i].itemNum
		local _,data,_,_,itype = gametool.GetItemDataById(item[i].itemID)
		local color = gametool.GetItemColorByType(itype,data)
		itemstables[i].color = color
	end
	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end
-----------------------------------------------------------------------
-----------------------------------------------------------------------
function CommonItemWinCls:InitItemNode()
	local gametool = require "Utils.GameTools"
	local PropUtility = require "Utils.PropUtility"

	local infoData,data,name,iconPath,itype = gametool.GetItemDataById(self.id)
	local color = gametool.GetItemColorByType(itype,data)
	
	PropUtility.AutoSetRGBColor(self.colorFrame,color)
	utility.LoadSpriteFromPath(iconPath,self.iconImage)
	self.nameLabel.text = name

	local desc 

	if itype == "RoleChip"  or itype == "EquipChip" then
		local name = infoData:GetName()
		desc = string.format("%s%s",ShopStringTable[5],name)
		self.DebrisIcon:SetActive(true)
	else
		desc = infoData:GetDesc()
	end
	self.desLabel.text  = desc

	-- 是否可以使用
	if self.possess == true then
		self.useNum = data:GetCanUse()
		local active = self.useNum ~= 0 and self.useNum ~= 4
		self.ConfirmButton.gameObject:SetActive(active)
	end
end

function CommonItemWinCls:GetSellItemUid(id)
	local UserDataType = require "Framework.UserDataType"
	local cacheData = self:GetCachedData(UserDataType.ItemBagData)
	local itemUid = cacheData:GetItemById(id):GetUid()
	itemUid = string.format("%s%s",itemUid,",")
	return itemUid
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CommonItemWinCls:OnRetrunButtonClicked()
	--RetrunButton控件的点击事件处理
	self:Close()
end

function CommonItemWinCls:OnConfirmButtonClicked()
	-- 使用按钮
	if self.useNum == 1 then
		-- 出售货币
		local uid = self:GetSellItemUid(self.id)
		self:ItemBagSellRequest(uid)
	elseif self.useNum == 2 then
		-- 副本
		self:DispatchEvent(messageGuids.CloseKnapsackWindow)
		local sceneManager = self:GetGame():GetSceneManager()
      	local CheckpointSceneClass = require "Scenes.CheckpointScene"
      	sceneManager:PushScene(CheckpointSceneClass.New())
	elseif self.useNum == 3 then
		-- 抽卡
		local windowManager = self:GetGame():GetWindowManager()
      	windowManager:Show(require "GUI.CardDraw")
      	self:DispatchEvent(messageGuids.CloseKnapsackWindow)
	elseif self.useNum == 4 then
		-- 接收任务
	elseif self.useNum == 5 then
		self:OpenTreasureChestRewardRequest()
	elseif self.useNum == 6 then
		local windowManager = self:GetGame():GetWindowManager()
		local SelectBoxCls = require "GUI.SelectBoxCls"
		windowManager:Show(SelectBoxCls,self.id)
	end
	
	self:Close()

end



return CommonItemWinCls