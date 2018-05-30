local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
-- local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildManageConfirmCls = Class(BaseNodeClass)
windowUtility.SetMutex(GuildManageConfirmCls,true)
local GuildCommonFunc = require "GUI/Guild/GuildCommonFunc"

function GuildManageConfirmCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildManageConfirmCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildManageConfirm', function(go)
		self:BindComponent(go)
	end)
end

function GuildManageConfirmCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildManageConfirmCls:OnResume()
	-- 界面显示时调用
	GuildManageConfirmCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildManageConfirmCls:OnPause()
	-- 界面隐藏时调用
	GuildManageConfirmCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildManageConfirmCls:OnEnter()
	-- Node Enter时调用
	GuildManageConfirmCls.base.OnEnter(self)
end

function GuildManageConfirmCls:OnExit()
	-- Node Exit时调用
	GuildManageConfirmCls.base.OnExit(self)
end

function GuildManageConfirmCls:OnWillShow(memInfo, typeString)
	self.memInfo = memInfo
	self.typeString = typeString
	self.selectedPosition = 0
end

function GuildManageConfirmCls:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildManageConfirmCls:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform
	self.Base = transform:Find('Head/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.PersonalInformationHeadIcon = transform:Find('Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.MemberNameLabel = transform:Find('MemberNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.LevelNuLabel = transform:Find('LevelNuLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.OFFline = transform:Find('OFFline'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ONline = transform:Find('ONline'):GetComponent(typeof(UnityEngine.UI.Text))
	self.MemberTributeLabel = transform:Find('MemberTributeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.HandoutNotice = transform:Find('Handout/HandoutNotice'):GetComponent(typeof(UnityEngine.UI.Text))
	self.HandoutNotice1 = transform:Find('Kickout /HandoutNotice'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ConfirmButton = transform:Find('ConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CancelButton = transform:Find('CancelButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.CrossButton = transform:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Move = transform:Find('Move')

	self.Position = {}
	self.Hightlight = {}
	for i=1,3 do
		self.Position[i] = transform:Find('Move/Position'..i):GetComponent(typeof(UnityEngine.UI.Button))
		self.Hightlight[i] = transform:Find('Move/Position'..i..'/Hightlight'):GetComponent(typeof(UnityEngine.UI.Image))
	end

	self.Text1 = transform:Find('Move/Position1/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Text11 = transform:Find('Move/Position1/Hightlight/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Text2 = transform:Find('Move/Position2/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Text22 = transform:Find('Move/Position2/Hightlight/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Text3 = transform:Find('Move/Position3/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Text33 = transform:Find('Move/Position3/Hightlight/Text'):GetComponent(typeof(UnityEngine.UI.Text))
	
	self:InitView()

	self.game = utility:GetGame()
end

function GuildManageConfirmCls:InitView()
	utility.LoadRoleHeadIcon(self.memInfo.headID, self.PersonalInformationHeadIcon)
	self.Base.color = require "Utils.PropUtility".GetColorValue(self.memInfo.headColor)
	self.MemberNameLabel.text = self.memInfo.playerName
	self.LevelNuLabel.text = self.memInfo.playerLevel
	self.OFFline.gameObject:SetActive(not self.memInfo.online)
	self.ONline.gameObject:SetActive(self.memInfo.online)
	self.MemberTributeLabel.text = "贡献："..self.memInfo.contribution
	self.HandoutNotice.gameObject:SetActive(self.typeString=="HANDOVER")
	self.HandoutNotice1.gameObject:SetActive(self.typeString=="KICKOUT")
	self.Move.gameObject:SetActive(self.typeString=="TRANSFER")
	for i=1,3 do
		self.Hightlight[i].gameObject:SetActive(false)
	end
end

function GuildManageConfirmCls:RegisterControlEvents()
	-- 注册 Position1 的事件
	self.__event_button_onPosition1Clicked__ = UnityEngine.Events.UnityAction(self.OnPosition1Clicked, self)
	self.Position[1].onClick:AddListener(self.__event_button_onPosition1Clicked__)

	-- 注册 Position2 的事件
	self.__event_button_onPosition2Clicked__ = UnityEngine.Events.UnityAction(self.OnPosition2Clicked, self)
	self.Position[2].onClick:AddListener(self.__event_button_onPosition2Clicked__)

	-- 注册 Position3 的事件
	self.__event_button_onPosition3Clicked__ = UnityEngine.Events.UnityAction(self.OnPosition3Clicked, self)
	self.Position[3].onClick:AddListener(self.__event_button_onPosition3Clicked__)

	-- 注册 ConfirmButton 的事件
	self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)

	-- 注册 CancelButton 的事件
	self.__event_button_onCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCancelButtonClicked, self)
	self.CancelButton.onClick:AddListener(self.__event_button_onCancelButtonClicked__)

	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)
end

function GuildManageConfirmCls:UnregisterControlEvents()
	-- 取消注册 Position1 的事件
	if self.__event_button_onPosition1Clicked__ then
		self.Position[1].onClick:RemoveListener(self.__event_button_onPosition1Clicked__)
		self.__event_button_onPosition1Clicked__ = nil
	end

	-- 取消注册 Position2 的事件
	if self.__event_button_onPosition2Clicked__ then
		self.Position[2].onClick:RemoveListener(self.__event_button_onPosition2Clicked__)
		self.__event_button_onPosition2Clicked__ = nil
	end

	-- 取消注册 Position3 的事件
	if self.__event_button_onPosition3Clicked__ then
		self.Position[3].onClick:RemoveListener(self.__event_button_onPosition3Clicked__)
		self.__event_button_onPosition3Clicked__ = nil
	end

	-- 取消注册 ConfirmButton 的事件
	if self.__event_button_onConfirmButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
		self.__event_button_onConfirmButtonClicked__ = nil
	end

	-- 取消注册 CancelButton 的事件
	if self.__event_button_onCancelButtonClicked__ then
		self.CancelButton.onClick:RemoveListener(self.__event_button_onCancelButtonClicked__)
		self.__event_button_onCancelButtonClicked__ = nil
	end

	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end
end

function GuildManageConfirmCls:RegisterNetworkEvents()
end

function GuildManageConfirmCls:UnregisterNetworkEvents()
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildManageConfirmCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildManageConfirmCls:OnExitTransitionDidStart(immediately)
    GuildManageConfirmCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildManageConfirmCls:OnPosition1Clicked()
	self:OnPositionClicked(1)
end

function GuildManageConfirmCls:OnPosition2Clicked()
	self:OnPositionClicked(2)
end

function GuildManageConfirmCls:OnPosition3Clicked()
	self:OnPositionClicked(3)
end

function GuildManageConfirmCls:OnPositionClicked(index)
	if index==self.selectedPosition then
		return
	end

	if self.Hightlight[self.selectedPosition] then
		self.Hightlight[self.selectedPosition].gameObject:SetActive(false)
	end
	if self.Hightlight[index] then
		self.Hightlight[index].gameObject:SetActive(true)
		self.selectedPosition = index
	end
end

function GuildManageConfirmCls:OnConfirmButtonClicked()
	local state
	if self.typeString=="HANDOVER" then
		state = 0
	elseif self.typeString=="KICKOUT" then
		state = 3
	elseif self.typeString=="TRANSFER" then
		if self.selectedPosition==1 then
			state = 4
		elseif self.selectedPosition==2 then
			state = 1
		elseif self.selectedPosition==3 then
			if self.memInfo.job==2 then
				state = 5
			elseif self.memInfo.job==3 then
				state = 2
			end
		end
	end
	local ghId = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetGonghuiID()
	self.game:SendNetworkMessage(require "Network/ServerService".GHManagerMemRequest(ghId, self.memInfo.playerUID, state))
	self:Close()
end

function GuildManageConfirmCls:OnCancelButtonClicked()
	self:Close()
end

function GuildManageConfirmCls:OnCrossButtonClicked()
	self:Close()
end

return GuildManageConfirmCls
