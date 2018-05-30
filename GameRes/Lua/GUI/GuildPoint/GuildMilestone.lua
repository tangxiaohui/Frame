local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local windowUtility = require "Framework.Window.WindowUtility"

local GuildMilestoneCls = Class(BaseNodeClass)
windowUtility.SetMutex(GuildMilestoneCls, true)

function GuildMilestoneCls:Ctor()
end

function GuildMilestoneCls:OnWillShow(id)
	self.id = id
end

function  GuildMilestoneCls:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/MilestonPacks",function(go)
		self:BindComponent(go)
	end)
end

function GuildMilestoneCls:OnComponentReady()
	self:InitControls()
end

function GuildMilestoneCls:OnResume()
	GuildMilestoneCls.base.OnResume(self)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:LoadItem()
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function GuildMilestoneCls:OnPause()
	GuildMilestoneCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildMilestoneCls:OnEnter()
	GuildMilestoneCls.base.OnEnter(self)
end

function GuildMilestoneCls:OnExit()
	GuildMilestoneCls.base.OnExit(self)
end

function GuildMilestoneCls:IsTransition()
    return true
end

function GuildMilestoneCls:OnExitTransitionDidStart(immediately)
	GuildMilestoneCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end


function GuildMilestoneCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function GuildMilestoneCls:InitControls()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find("SmallWindowBase")
	self.returnButton = self.tweenObjectTrans:Find("NovicePacksCancelButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.reciveButton = self.tweenObjectTrans:Find("ButtonLayout/NovicePacksReceiveButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.childPoint = self.tweenObjectTrans:Find("ItemListLayout")
	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.myGame = utility:GetGame()
end

function GuildMilestoneCls:RegisterControlEvents()
	--注册退出事件
	self._event_button_onReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onReturnButtonClicked_)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	--注册领取事件
	self._event_button_onReciveButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReciveButtonClicked,self)
	self.reciveButton.onClick:AddListener(self._event_button_onReciveButtonClicked_)
end

function GuildMilestoneCls:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onReturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onReturnButtonClicked_)
		self._event_button_onReturnButtonClicked_ = nil
	end

	--取消注册领取事件
	if self._event_button_onReciveButtonClicked_ then
		self.reciveButton.onClick:RemoveListener(self._event_button_onReciveButtonClicked_)
		self._event_button_onReciveButtonClicked_ = nil
	end
	
	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end
end

function GuildMilestoneCls:RegisterNetworkEvents()
	self.myGame:RegisterMsgHandler(net.S2CGHPointMilestoneAwardResult,self,self.GHPointMilestoneAwardResult)
end

function GuildMilestoneCls:UnregisterNetworkEvents()
	self.myGame:UnRegisterMsgHandler(net.S2CGHPointMilestoneAwardResult,self,self.GHPointMilestoneAwardResult)
end

function GuildMilestoneCls:GHPointMilestoneAwardRequest(awardId)
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointMilestoneAwardRequest(awardId))
end

function GuildMilestoneCls:GHPointMilestoneQueryRequest()
	self.myGame:SendNetworkMessage( require "Network/ServerService".GHPointMilestoneQueryRequest())
end

function GuildMilestoneCls:GHPointMilestoneAwardResult(msg)
	if msg.result then
		self:ShowAwardPanel()
		self:GHPointMilestoneQueryRequest()
		self:OnReturnButtonClicked()
	end
end

function GuildMilestoneCls:OnReciveButtonClicked()
	self:GHPointMilestoneAwardRequest(self.id)
end

function GuildMilestoneCls:OnReturnButtonClicked()
	self:Close(true)
end

function GuildMilestoneCls:LoadItem()		
	local milestoneData = require "StaticData.PointFightMileStone":GetData(self.id)
	local nodeCls = require "GUI.Item.GeneralItem"
	local count = milestoneData:GetItemID().Count - 1
	local gametool = require "Utils.GameTools"
	for i=0,count do
		local id = milestoneData:GetItemID()[i]
		local num = milestoneData:GetItemNum()[i]
		local color 
		if milestoneData:GetItemColor()[i] == -1 then
			local _,data,_,_,itype = gametool.GetItemDataById(id)
        	color = gametool.GetItemColorByType(itype,data)
		else
			color = milestoneData:GetItemColor()[i]
		end
		local node = nodeCls.New(self.childPoint,id,num,color)
		self:AddChild(node)
	end
end

function GuildMilestoneCls:ShowAwardPanel()
	local milestoneData = require "StaticData.PointFightMileStone":GetData(self.id)
	local nodeCls = require "GUI.Item.GeneralItem"
	local count = milestoneData:GetItemID().Count
	local nodeCls = require "GUI.Item.GeneralItem"
	local gametool = require "Utils.GameTools"
	local itemstables = {}
	for i=0,count - 1 do
		local id = milestoneData:GetItemID()[i]
		local num = milestoneData:GetItemNum()[i]
		local color 
		if milestoneData:GetItemColor()[i] == -1 then
			local _,data,_,_,itype = gametool.GetItemDataById(id)
        	color = gametool.GetItemColorByType(itype,data)
		else
			color = milestoneData:GetItemColor()[i]
		end
		itemstables[i + 1] = {}
		itemstables[i + 1].id = id
		itemstables[i + 1].count = num
		itemstables[i + 1].color = color
	end
	local windowManager = self:GetGame():GetWindowManager()
    local AwardCls = require "GUI.Task.GetAwardItem"
    windowManager:Show(AwardCls,itemstables)
end

return GuildMilestoneCls