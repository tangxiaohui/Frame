local BaseNodeClass = require "Framework.Base.UIScene"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local GuildCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI.Guild.GuildCommonFunc"
local LegionLvData = require "StaticData.LegionLv"
local messageGuids = require "Framework.Business.MessageGuids"
require "Collection.OrderedDictionary"


local JOB_President 		= 1	-- 会长
local JOB_Vice_President	= 2 -- 副会长
local JOB_Brainman 			= 3 -- 参谋
 

function GuildCls:Ctor()
	self.ghInfo = {}
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/Guild', function(go)
		self:BindComponent(go)
	end)
end

function GuildCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildCls:OnResume()
	-- 界面显示时调用
	GuildCls.base.OnResume(self)
	require "Utils.GameAnalysisUtils".EnterScene("军团界面")
	require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_GuildView)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self:RegisterLocalEvents()
	self:RedDotStateQuery()
	utility.GetGame():GetSystemGuideManager():SetNeetSystemGuideID(kSystem_Guide[11].systemGuideID,self)

end

function GuildCls:OnPause()
	-- 界面隐藏时调用
	GuildCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
	self:UnregisterLocalEvents()
end

function GuildCls:OnEnter()
	-- Node Enter时调用
	GuildCls.base.OnEnter(self)
	self:RequestGuildUI()
end

function GuildCls:OnExit()
	-- Node Exit时调用
	GuildCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform
	self.BackButton = transform:Find('BackButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Scroll_View = transform:Find('InGuild/ManageArea/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport = transform:Find('InGuild/ManageArea/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.NoticeLabel = transform:Find('InGuild/ManageArea/Box/NoticeInput/NoticeLabel'):GetComponent(typeof(UnityEngine.UI.InputField))
	self.ApplyButton = transform:Find('InGuild/ManageArea/Box/ApplyButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ChangeButton = transform:Find('InGuild/ManageArea/Box/ChangeButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.QuitButton = transform:Find('InGuild/ManageArea/Box/QuitButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.rankInGuildButton = transform:Find('InGuild/ManageArea/Box/RankButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.MemberNumLabel = transform:Find('InGuild/ManageArea/ListTitleBase/MemberNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.GuildNameLabel = transform:Find('InGuild/InfoArea/GuildNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ChangeNameButton = transform:Find('InGuild/InfoArea/ChangeNameButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.GuildLevelLabel = transform:Find('InGuild/InfoArea/GuildLevelLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Bar = transform:Find('InGuild/InfoArea/Bar/Fill'):GetComponent(typeof(UnityEngine.UI.Image))
	self.IconFrame = transform:Find('InGuild/InfoArea/IconFrame'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base = transform:Find('InGuild/InfoArea/IconFrame/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GuildIcon = transform:Find('InGuild/InfoArea/IconFrame/GuildIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.TotalExpLabel = transform:Find('InGuild/InfoArea/TotalExpLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.TributeButton = transform:Find('InGuild/InfoArea/TributeButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.NoticeLabel1 = transform:Find('InGuild/InfoArea/NoticeLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.Scroll_View1 = transform:Find('OffGuild/ManageArea/Scroll View'):GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.Viewport1 = transform:Find('OffGuild/ManageArea/Scroll View/Viewport'):GetComponent(typeof(UnityEngine.UI.Mask))
	self.RankButton = transform:Find('OffGuild/ManageArea/RankButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SearchButton = transform:Find('OffGuild/ManageArea/SearchButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.SearchText = transform:Find('OffGuild/ManageArea/Frame'):GetComponent(typeof(UnityEngine.UI.InputField))
	self.EmptyLabel = transform:Find('OffGuild/ManageArea/EmptyLabel'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CreateText = transform:Find('OffGuild/InfoArea/Frame'):GetComponent(typeof(UnityEngine.UI.InputField))
	self.IconFrame1 = transform:Find('OffGuild/InfoArea/IconFrame'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Base1 = transform:Find('OffGuild/InfoArea/IconFrame/Base'):GetComponent(typeof(UnityEngine.UI.Image))
	self.GuildIcon1 = transform:Find('OffGuild/InfoArea/IconFrame/GuildIcon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Icon = transform:Find('OffGuild/InfoArea/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
	self.Price = transform:Find('OffGuild/InfoArea/Price'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CreateButton = transform:Find('OffGuild/InfoArea/CreateButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.InfoButton = transform:Find('InfoButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.ShopButton = transform:Find('InGuild/ShopButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.MercenaryButton = transform:Find('InGuild/MercenaryButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.RespectButton = transform:Find('InGuild/RespectButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.guildPoint = transform:Find('InGuild/GuildPoint'):GetComponent(typeof(UnityEngine.UI.Button))

	self.InGuild = transform:Find('InGuild')
	self.OffGuild = transform:Find('OffGuild')
	self.Content = transform:Find('InGuild/ManageArea/Scroll View/Viewport/Content')
	self.Content1 = transform:Find('OffGuild/ManageArea/Scroll View/Viewport/Content')
	self.guildRedDotImage = self.ApplyButton.transform:Find('RedDotImage').gameObject
	self.animatorObj = transform:Find('Animator')

	self.game = utility:GetGame()
	self.windowManager = self.game:GetWindowManager()

	self.NoticeLabel.enabled = false
	self.isInGuild = false
	self.callBackNum = 0
end


function GuildCls:RegisterControlEvents()
	-- 注册 BackButton 的事件
	self.__event_button_onBackButtonClicked__ = UnityEngine.Events.UnityAction(self.OnBackButtonClicked, self)
	self.BackButton.onClick:AddListener(self.__event_button_onBackButtonClicked__)

	-- 注册 ApplyButton 的事件
	self.__event_button_onApplyButtonClicked__ = UnityEngine.Events.UnityAction(self.OnApplyButtonClicked, self)
	self.ApplyButton.onClick:AddListener(self.__event_button_onApplyButtonClicked__)

	-- 注册 ChangeButton 的事件
	self.__event_button_onChangeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeButtonClicked, self)
	self.ChangeButton.onClick:AddListener(self.__event_button_onChangeButtonClicked__)

	-- 注册 QuitButton 的事件
	self.__event_button_onQuitButtonClicked__ = UnityEngine.Events.UnityAction(self.OnQuitButtonClicked, self)
	self.QuitButton.onClick:AddListener(self.__event_button_onQuitButtonClicked__)

	self.__event_button_onRankInGuildButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRankInGuildButtonClicked, self)
	self.rankInGuildButton.onClick:AddListener(self.__event_button_onRankInGuildButtonClicked__)

	-- 注册 ChangeNameButton 的事件
	self.__event_button_onChangeNameButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChangeNameButtonClicked, self)
	self.ChangeNameButton.onClick:AddListener(self.__event_button_onChangeNameButtonClicked__)

	-- 注册 TributeButton 的事件
	self.__event_button_onTributeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnTributeButtonClicked, self)
	self.TributeButton.onClick:AddListener(self.__event_button_onTributeButtonClicked__)

	-- 注册 RankButton 的事件
	self.__event_button_onRankButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRankButtonClicked, self)
	self.RankButton.onClick:AddListener(self.__event_button_onRankButtonClicked__)

	-- 注册 SearchButton 的事件
	self.__event_button_onSearchButtonClicked__ = UnityEngine.Events.UnityAction(self.OnSearchButtonClicked, self)
	self.SearchButton.onClick:AddListener(self.__event_button_onSearchButtonClicked__)

	-- 注册 IconFrame 的事件
	self.__event_button_onIconFrameClicked__ = UnityEngine.Events.UnityAction(self.OnIconFrameClicked, self)
	self.IconFrame.onClick:AddListener(self.__event_button_onIconFrameClicked__)

	-- 注册 IconFrame1 的事件
	self.__event_button_onIconFrame1Clicked__ = UnityEngine.Events.UnityAction(self.OnIconFrame1Clicked, self)
	self.IconFrame1.onClick:AddListener(self.__event_button_onIconFrame1Clicked__)

	-- 注册 CreateButton 的事件
	self.__event_button_onCreateButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCreateButtonClicked, self)
	self.CreateButton.onClick:AddListener(self.__event_button_onCreateButtonClicked__)

	-- 注册 InfoButton 的事件
	self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
	self.InfoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)

	-- 注册 ShopButton 的事件
	self.__event_button_onShopButtonClicked__ = UnityEngine.Events.UnityAction(self.OnShopButtonClicked, self)
	self.ShopButton.onClick:AddListener(self.__event_button_onShopButtonClicked__)

	-- 注册 MercenaryButton 的事件
	self.__event_button_onMercenaryButtonClicked__ = UnityEngine.Events.UnityAction(self.OnMercenaryButtonClicked, self)
	self.MercenaryButton.onClick:AddListener(self.__event_button_onMercenaryButtonClicked__)

	-- 注册 RespectButton 的事件
	self.__event_button_onRespectButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRespectButtonClicked, self)
	self.RespectButton.onClick:AddListener(self.__event_button_onRespectButtonClicked__)
	-- 注册军团积分战事件
	self.__event_button_onGuildPointClicked__ = UnityEngine.Events.UnityAction(self.OnGuildPointClicked, self)
	self.guildPoint.onClick:AddListener(self.__event_button_onGuildPointClicked__)
end

function GuildCls:UnregisterControlEvents()
	-- 取消注册 BackButton 的事件
	if self.__event_button_onBackButtonClicked__ then
		self.BackButton.onClick:RemoveListener(self.__event_button_onBackButtonClicked__)
		self.__event_button_onBackButtonClicked__ = nil
	end

	-- 取消注册 ApplyButton 的事件
	if self.__event_button_onApplyButtonClicked__ then
		self.ApplyButton.onClick:RemoveListener(self.__event_button_onApplyButtonClicked__)
		self.__event_button_onApplyButtonClicked__ = nil
	end

	-- 取消注册 ChangeButton 的事件
	if self.__event_button_onChangeButtonClicked__ then
		self.ChangeButton.onClick:RemoveListener(self.__event_button_onChangeButtonClicked__)
		self.__event_button_onChangeButtonClicked__ = nil
	end

	-- 取消注册 QuitButton 的事件
	if self.__event_button_onQuitButtonClicked__ then
		self.QuitButton.onClick:RemoveListener(self.__event_button_onQuitButtonClicked__)
		self.__event_button_onQuitButtonClicked__ = nil
	end

	if self.__event_button_onRankInGuildButtonClicked__ then
		self.rankInGuildButton.onClick:RemoveListener(self.__event_button_onRankInGuildButtonClicked__)
		self.__event_button_onRankInGuildButtonClicked__ = nil
	end

	-- 取消注册 ChangeNameButton 的事件
	if self.__event_button_onChangeNameButtonClicked__ then
		self.ChangeNameButton.onClick:RemoveListener(self.__event_button_onChangeNameButtonClicked__)
		self.__event_button_onChangeNameButtonClicked__ = nil
	end

	-- 取消注册 TributeButton 的事件
	if self.__event_button_onTributeButtonClicked__ then
		self.TributeButton.onClick:RemoveListener(self.__event_button_onTributeButtonClicked__)
		self.__event_button_onTributeButtonClicked__ = nil
	end

	-- 取消注册 RankButton 的事件
	if self.__event_button_onRankButtonClicked__ then
		self.RankButton.onClick:RemoveListener(self.__event_button_onRankButtonClicked__)
		self.__event_button_onRankButtonClicked__ = nil
	end

	-- 取消注册 SearchButton 的事件
	if self.__event_button_onSearchButtonClicked__ then
		self.SearchButton.onClick:RemoveListener(self.__event_button_onSearchButtonClicked__)
		self.__event_button_onSearchButtonClicked__ = nil
	end

	-- 取消注册 IconFrame 的事件
	if self.__event_button_onIconFrameClicked__ then
		self.IconFrame.onClick:RemoveListener(self.__event_button_onIconFrameClicked__)
		self.__event_button_onIconFrameClicked__ = nil
	end

	-- 取消注册 IconFrame1 的事件
	if self.__event_button_onIconFrame1Clicked__ then
		self.IconFrame1.onClick:RemoveListener(self.__event_button_onIconFrame1Clicked__)
		self.__event_button_onIconFrame1Clicked__ = nil
	end

	-- 取消注册 CreateButton 的事件
	if self.__event_button_onCreateButtonClicked__ then
		self.CreateButton.onClick:RemoveListener(self.__event_button_onCreateButtonClicked__)
		self.__event_button_onCreateButtonClicked__ = nil
	end

	-- 取消注册 InfoButton 的事件
	if self.__event_button_onInfoButtonClicked__ then
		self.InfoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
		self.__event_button_onInfoButtonClicked__ = nil
	end

	-- 取消注册 ShopButton 的事件
	if self.__event_button_onShopButtonClicked__ then
		self.ShopButton.onClick:RemoveListener(self.__event_button_onShopButtonClicked__)
		self.__event_button_onShopButtonClicked__ = nil
	end

	-- 取消注册 MercenaryButton 的事件
	if self.__event_button_onMercenaryButtonClicked__ then
		self.MercenaryButton.onClick:RemoveListener(self.__event_button_onMercenaryButtonClicked__)
		self.__event_button_onMercenaryButtonClicked__ = nil
	end

	-- 取消注册 RespectButton 的事件
	if self.__event_button_onRespectButtonClicked__ then
		self.RespectButton.onClick:RemoveListener(self.__event_button_onRespectButtonClicked__)
		self.__event_button_onRespectButtonClicked__ = nil
	end

	-- 取消注册军团积分战事件
	if self.__event_button_onGuildPointClicked__ then
		self.guildPoint.onClick:RemoveListener(self.__event_button_onGuildPointClicked__)
		self.__event_button_onGuildPointClicked__ = nil
	end
end

function GuildCls:RegisterNetworkEvents()
	self.game:RegisterMsgHandler(net.S2CGHQueryResult, self, self.GHQueryResult)
	self.game:RegisterMsgHandler(net.S2CGHCreateResult, self, self.GHCreateResult)
	self.game:RegisterMsgHandler(net.S2CGHQuitResult, self, self.GHQuitResult)
	self.game:RegisterMsgHandler(net.S2CGHSetLogoResult, self, self.GHSetLogoResult)
	self.game:RegisterMsgHandler(net.S2CGHSetShowMsgResult, self, self.GHSetShowMsgResult)
	self.game:RegisterMsgHandler(net.S2CGHRankResult, self, self.GHRankResult)
	self.game:RegisterMsgHandler(net.S2CGHRecordResult, self, self.GHRecordResult)
	self.game:RegisterMsgHandler(net.S2CGHSearchResult, self, self.GHSearchResult)
	self.game:RegisterMsgHandler(net.S2CGHHandleApplyResult, self, self.GHHandleApplyResult)
	self.game:RegisterMsgHandler(net.S2CGHJoinResult, self, self.GHJoinResult)
	self.game:RegisterMsgHandler(net.S2CGHQueryApplyResult, self, self.GHQueryApplyResult)
	self.game:RegisterMsgHandler(net.S2CGHItemUpdate, self, self.GHItemUpdate)
	self.game:RegisterMsgHandler(net.S2CGHManagerMemResult, self, self.GHManagerMemResult)
	self.game:RegisterMsgHandler(net.S2CGHUpdateResultMessage, self, self.GHUpdateResultMessage)
	self.game:RegisterMsgHandler(net.S2CGHPointQueryResult,self,self.GHPointQueryResult)
end

function GuildCls:UnregisterNetworkEvents()
	self.game:UnRegisterMsgHandler(net.S2CGHQueryResult, self, self.GHQueryResult)
	self.game:UnRegisterMsgHandler(net.S2CGHCreateResult, self, self.GHCreateResult)
	self.game:UnRegisterMsgHandler(net.S2CGHQuitResult, self, self.GHQuitResult)
	self.game:UnRegisterMsgHandler(net.S2CGHSetLogoResult, self, self.GHSetLogoResult)
	self.game:UnRegisterMsgHandler(net.S2CGHSetShowMsgResult, self, self.GHSetShowMsgResult)
	self.game:UnRegisterMsgHandler(net.S2CGHRankResult, self, self.GHRankResult)
	self.game:UnRegisterMsgHandler(net.S2CGHRecordResult, self, self.GHRecordResult)
	self.game:UnRegisterMsgHandler(net.S2CGHSearchResult, self, self.GHSearchResult)
	self.game:UnRegisterMsgHandler(net.S2CGHHandleApplyResult, self, self.GHHandleApplyResult)
	self.game:UnRegisterMsgHandler(net.S2CGHJoinResult, self, self.GHJoinResult)
	self.game:UnRegisterMsgHandler(net.S2CGHQueryApplyResult, self, self.GHQueryApplyResult)
	self.game:UnRegisterMsgHandler(net.S2CGHItemUpdate, self, self.GHItemUpdate)
	self.game:UnRegisterMsgHandler(net.S2CGHManagerMemResult, self, self.GHManagerMemResult)
	self.game:UnRegisterMsgHandler(net.S2CGHUpdateResultMessage, self, self.GHUpdateResultMessage)
	self.game:UnRegisterMsgHandler(net.S2CGHPointQueryResult,self,self.GHPointQueryResult)
end

function GuildCls:RegisterLocalEvents()
	self:RegisterEvent('SetGuildLogo', self.SetGuildLogo)
	self:RegisterEvent('SetGuildName', self.SetGuildName)
	self:RegisterEvent('NormalNoticeConfirm', self.DoConfirmOperation)
	self:RegisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

function GuildCls:UnregisterLocalEvents()
	self:UnregisterEvent('SetGuildLogo', self.SetGuildLogo)
	self:UnregisterEvent('SetGuildName', self.SetGuildName)
	self:UnregisterEvent('NormalNoticeConfirm', self.DoConfirmOperation)
	self:UnregisterEvent(messageGuids.ModuleRedDotChanged, self.RedDotStateUpdated)
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildCls:OnBackButtonClicked()
	local sceneManager = self.game:GetSceneManager()
    sceneManager:PopScene()
end

local function RequestCreatGuild(self)
	coroutine.wait(3.3)
	self.animatorObj.gameObject:SetActive(false)
	self.Effect.gameObject:SetActive(false)
	self:RequestGuildUI()
end

function GuildCls:OnInfoButtonClicked()
	local str = utility.GetDescriptionStr(KSystemBasis_GuildID)
    self.windowManager:Show(require "GUI.CommonDescriptionModule",str)
end

function GuildCls:OnShopButtonClicked()
	self.windowManager:Show(require "GUI/Shop/Shop", 5)
end

function GuildCls:OnMercenaryButtonClicked()
	self.windowManager:Show(require "GUI/Guild/GuildMercenary")
end

function GuildCls:TributeCallBack(msg)
	self.callBackNum = msg
end

function GuildCls:OnRespectButtonClicked()

	local Respect = require "GUI/Guild/GuildRespect"
	Respect:OnSetCallBack(self, self.TributeCallBack)
	self.windowManager:Show(Respect, self.managers, self.remainWorship)
end

function GuildCls:OnRankButtonClicked()
	self.isInGuild = false
	self.game:SendNetworkMessage(require "Network/ServerService".GHRankRequest())
end

function GuildCls:OnSearchButtonClicked()
	local searchString = self.SearchText.text
	self.game:SendNetworkMessage(require "Network/ServerService".GHSearchRequest(searchString))
end

function GuildCls:GHPointQueryRequest()
	self.game:SendNetworkMessage(require "Network/ServerService".GHPointQueryRequest())
end

function GuildCls:OnCreateButtonClicked()
	if self.CreateText.text=="" then
		GuildCommonFunc.ShowErrorTip("请输入有效的军团名字！")
	else
		--debug_print(self.precreateLogoID)
		if self.precreateLogoID ~= nil then
			self.CreateText.text = string.gsub(self.CreateText.text, "^%s*(.-)%s*$", "%1")
			self.game:SendNetworkMessage(require"Network/ServerService".GHCreateRequest(self.CreateText.text, self.precreateLogoID))
		else
			GuildCommonFunc.ShowErrorTip("请选择军团图标！")
		end
	end
end


function GuildCls:OnApplyButtonClicked()
	self.game:SendNetworkMessage(require "Network/ServerService".GHQueryApplyRequest(self.ghInfo.ghID))
end

function GuildCls:OnChangeButtonClicked()
	if self.NoticeLabel.enabled then
		local showmsg = self.NoticeLabel.text
		if showmsg==self.ghInfo.showmsg then
			GuildCommonFunc.ShowErrorTip("军团公告没有改动！")
		else
			self.game:SendNetworkMessage(require "Network/ServerService".GHSetShowMsgRequest(self.ghInfo.ghID, showmsg))
		end
		self.NoticeLabel.enabled = false
	else
		self.NoticeLabel.enabled = true
		self.NoticeLabel:ActivateInputField()
	end
end

function GuildCls:OnQuitButtonClicked()
	self.windowManager:Show(require "GUI/NormalNotice", "GUILD_QUIT", "您确定要退出军团吗？")
end

function GuildCls:OnRankInGuildButtonClicked()
	self.isInGuild = true
	self:OnRankButtonClicked()
end

function GuildCls:OnTributeButtonClicked()
	local Tribute = require "GUI/Guild/GuildTribute"
	Tribute:OnSetCallBack(self, self.TributeCallBack)
	self.windowManager:Show(Tribute)
end

function GuildCls:OnChangeNameButtonClicked()
	self.windowManager:Show(require "GUI/Guild/GuildChangeName", self.ghInfo.name)
end

function GuildCls:OnIconFrameClicked()
	self.windowManager:Show(require "GUI/Guild/GuildChangeHead", self.ghInfo.logoID, self.ghInfo.level)
end

function GuildCls:OnIconFrame1Clicked()
	self.windowManager:Show(require "GUI/Guild/GuildChangeHead", self.precreateLogoID, 1)
end

function GuildCls:DoConfirmOperation(TYPE)
	if TYPE=="GUILD_QUIT" then
		self.game:SendNetworkMessage(require "Network/ServerService".GHQuitRequest(self.ghInfo.ghID))
	end
end

function GuildCls:OnGuildPointClicked()
	local isOpen = utility.IsCanOpenModule(kSystemBasis_GuildPointID)
    if not isOpen then
        return
    end

	self:GHPointQueryRequest()
end

-----------------------------------------------------------------------
--- 协议处理
-----------------------------------------------------------------------
function GuildCls:ShowAnimator()
	if self.Animator == nil then
		local path = "UI/Prefabs/GuildCreate" 
    	local Object = UnityEngine.GameObject
  		local obj = Object.Instantiate(utility.LoadResourceSync(path, typeof(UnityEngine.GameObject))) 
  		self.Animator = obj.transform
   		self.Animator:SetParent(self.animatorObj)
   		self.Animator.localPosition = self.base.localPosition
   		self.Animator.localScale = self.base.localScale
		local effectPath = "Effect/Effects/UI/UI_chuangjianchenggong"
  		self.Effect = Object.Instantiate(utility.LoadResourceSync(effectPath, typeof(UnityEngine.GameObject))) 
   		self.Effect.transform.parent = self.Animator.transform
   		self.Effect.transform.localPosition = self.Animator.transform.localPosition
   		self.Effect.transform.localScale = self.Animator.transform.localScale
   	else
   		self.animatorObj.gameObject:SetActive(true)
   		self.Animator.transform:GetComponent(typeof(UnityEngine.Animator)):Play("chuxian", 0, 0)
   		self.Effect.gameObject:SetActive(true)
   	end
end

function GuildCls:GHQueryResult(msg)
	print("query result arrive, ghID = "..msg.selfGHItem.ghID)
	if msg.selfGHItem.ghID==0 then
		self.ghInfo.ghID = msg.selfGHItem.ghID
		self:ResetOffGuildUI()
		self.EmptyLabel.gameObject:SetActive(#msg.ghItems==0)
		self:SetGuildListUI(msg.ghItems)
	else
		self.ghInfo = msg.selfGHItem
		self.managers = msg.admin
		self.remainWorship = msg.remainWorship

		local selfUID = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetUid()
		for i=1,#msg.members do
			if msg.members[i].playerUID==selfUID then
				self.job = msg.members[i].job
				break
			end
		end
		print("self job = "..self.job)
		self:SetUILimits()

		self:ResetInGuildUI()
		self.MemberNumLabel.text = #msg.members..'/'..LegionLvData:GetData(self.ghInfo.level):GetPeople()
		self:SetMemberListUI(msg.members)
	end
	self:SwitchToInGuildState(msg.selfGHItem.ghID~=0)
end

-- 会长, 副会长, 参谋有权限
local function HasPermission(self)
	return true
	-- return self.job == JOB_President or self.job == JOB_Vice_President or self.job == JOB_Brainman
end

function GuildCls:SetUILimits()
	self.IconFrame.enabled = HasPermission(self)
	self.ChangeNameButton.gameObject:SetActive(HasPermission(self))
	self.ChangeButton.gameObject:SetActive(HasPermission(self))
	self.ApplyButton.gameObject:SetActive(HasPermission(self))
end

function GuildCls:GHCreateResult(msg)
	print("create guild success !")
	self.precreateLogoID=nil
	self:ShowAnimator()
	self:StartCoroutine(RequestCreatGuild)
	-- self:RequestGuildUI()
end

function GuildCls:GHQuitResult(msg)
	print("quit guild success !")
	self:RequestGuildUI()
end

function GuildCls:GHRankResult(msg)
	if #msg.rankItems==0 then
		GuildCommonFunc.ShowErrorTip("没有排行榜数据，不如试试别的功能吧！")
	else
		self.windowManager:Show(require "GUI/Guild/GuildRank", msg.rankItems,self.isInGuild)
	end
end

function GuildCls:GHSearchResult(msg)
	if #msg.ghItem==0 then
		GuildCommonFunc.ShowErrorTip("没有您想要搜索的军团，请重试！")
	else
		self.EmptyLabel.gameObject:SetActive(false)
		self:SetGuildListUI(msg.ghItem)
	end
end

function GuildCls:GHQueryApplyResult(msg)
	print("query apply result arrive")
	if #msg.apply==0 then
		GuildCommonFunc.ShowErrorTip("目前暂没有申请者！")
	else
		self.windowManager:Show(require "GUI/Guild/GuildApply", msg.apply)
	end
end

function GuildCls:GHHandleApplyResult(msg)
	print("handle apply result arrive")
	self:RequestGuildUI()
end

function GuildCls:GHJoinResult(msg)
	print("join result arrive")
	self:RequestGuildUI()
end

function GuildCls:GHSetLogoResult(msg)
	if msg.head.sid==100 then
		print("protocol set name "..self.prechangeName)
		self.GuildNameLabel.text = self.prechangeName
	elseif msg.logoID~=self.ghInfo.logoID then
		print("protocol set logo "..msg.logoID)
		self:SetGuildLogo(msg.logoID)
	end
end

function GuildCls:GHSetShowMsgResult(msg)
	--debug_print("protocol set showmsg "..msg.showMsg)
	if msg.showMsg~=self.NoticeLabel.text then
		self.NoticeLabel.text = msg.showMsg
	end
	GuildCommonFunc.ShowErrorTip("公告修改成功")
end

function GuildCls:GHItemUpdate(msg)
	print("protocol update item")
	self:RequestGuildUI()
end

function GuildCls:GHRecordResult(msg)
	print("protocol record arrive")
	local string = self.NoticeLabel1.text
	for i=1,#msg.records do
		local info = msg.records[i]
		if string~="" then
			string = string..'\n'
		end
		if info.action==1 then
			string = string..info.playerName.."加入公会"
		elseif info.action==2 then
			string = string..info.playerName.."被踢出公会"
		elseif info.action==3 then
			string = string..info.playerName.."被任命为参谋"
		elseif info.action==4 then
			string = string..info.playerName.."被任命为指挥官"
		elseif info.action==5 then
			string = string..info.playerName.."退出公会"
		elseif info.action==6 then
			string = string..info.playerName.."被取消参谋"
		elseif info.action==7 then
			string = string..info.playerName.."被设置为副指挥官"
		elseif info.action==8 then
			string = string..info.playerName.."被取消副指挥官"
		end
	end
	self.NoticeLabel1.text = string
end

function GuildCls:GHManagerMemResult(msg)
	print("protocol manage member result arrive")
	self:RequestGuildUI()
end

function GuildCls:LoadLegionCoinItem(coinCount)
	if coinCount > 0 then
		local itemstables = {}
		itemstables[1] = {}
		itemstables[1].id = 10410007
		itemstables[1].count = coinCount
		local gametool = require "Utils.GameTools"
		local _,data,_,_,itype = gametool.GetItemDataById(itemstables[1].id)
		local color = gametool.GetItemColorByType(itype, data)
		itemstables[1].color = color
		local windowManager = self:GetGame():GetWindowManager()
		local AwardCls = require "GUI.Task.GetAwardItem"
		windowManager:Show(AwardCls, itemstables)
	end
end

function GuildCls:GHUpdateResultMessage(msg)
	print("捐赠/崇奉 result arrive, type = "..msg.type)
	self:RequestGuildUI()
	if msg.type==2 then	--捐赠w
		self:LoadLegionCoinItem(self.callBackNum)
		self.callBackNum = 0
		--[[
		self.ghInfo.level = msg.lev
		self.GuildLevelLabel.text = self.ghInfo.level..'/'..20
		self.Bar.value = msg.exp / LegionLvData:GetData(self.ghInfo.level):GetExp()
		self.TotalExpLabel.text = msg.exp..'/'..LegionLvData:GetData(self.ghInfo.level):GetExp()]]
		--GuildCommonFunc.ShowErrorTip("感谢您的捐赠！")
	elseif msg.type==3 then	--崇奉
		self:LoadLegionCoinItem(self.callBackNum)
		self.callBackNum = 0
		--GuildCommonFunc.ShowErrorTip("崇奉成功！")
	end
end

function GuildCls:GHPointQueryResult()
	local sceneManager = self:GetGame():GetSceneManager()
    local GemCombineCls = require "GUI.GuildPoint.GuildPoint"
    sceneManager:PushScene(GemCombineCls.New())
end
-----------------------------------------------------------------------
--- 辅助函数
-----------------------------------------------------------------------
function GuildCls:SwitchToInGuildState(bInGuild)
	self.InGuild.gameObject:SetActive(bInGuild)
	self.OffGuild.gameObject:SetActive(not bInGuild)
end

function GuildCls:ResetOffGuildUI()
	self.CreateText.text = ""
	self.SearchText.text = ""
	self.Price.text = require "StaticData.SystemConfig.SystemConfig":GetData(4):GetParameNum()[0]
	local iconPath = "UI/Atlases/Common2/Backpack_AddButton"
	utility.LoadSpriteFromPath(iconPath,self.GuildIcon1)
	-- self:SetGuildLogo(1)
end

function GuildCls:ResetInGuildUI()
	self:SetGuildLogo(self.ghInfo.logoID)
	self.GuildNameLabel.text = self.ghInfo.name
	self.GuildLevelLabel.text = self.ghInfo.level..'/'..20
	self.Bar.fillAmount = self.ghInfo.exp / LegionLvData:GetData(self.ghInfo.level):GetExp()
	self.TotalExpLabel.text = self.ghInfo.exp..'/'..LegionLvData:GetData(self.ghInfo.level):GetExp()
	self.NoticeLabel.text = self.ghInfo.showmsg
end

function GuildCls:SetGuildLogo(iconId)
	local iconPath, iconColor, _ = GuildCommonFunc.GetGuildIconInfo(iconId)
	if self.ghInfo.ghID==0 then
		self.precreateLogoID = iconId
	else
		self.ghInfo.logoID = iconId
	end
	self.IconFrame1:GetComponent(typeof(UnityEngine.UI.Image)).color = iconColor
	utility.LoadSpriteFromPath(iconPath,self.GuildIcon1)
	utility.LoadSpriteFromPath(iconPath,self.GuildIcon)
	self.IconFrame:GetComponent(typeof(UnityEngine.UI.Image)).color = iconColor
end

function GuildCls:SetGuildName(name)
	self.prechangeName = name
end

function GuildCls:SetMemberListUI(members)
	self:ClearMemberList()
	if #members==0 then
		return
	end

	for i=1,#members do
		if not self.memberDict:Contains(members[i].playerUID) then
			local node = require "GUI.Guild.GuildMemberItem".New(self.Content, members[i], self.job)
			self:AddChild(node)
			self.memberDict:Add(members[i].playerUID, node)
		end
	end
end

function GuildCls:ClearMemberList()
	if self.memberDict==nil then
		self.memberDict = OrderedDictionary.New()
	else
		local keys = self.memberDict:GetKeys()
		for i=1,#keys do
			local node = self.memberDict:GetEntryByKey(keys[i])
			self:RemoveChild(node)
		end
		self.memberDict:Clear()
	end
end

function GuildCls:SetGuildListUI(guilds)
	self:ClearGuildList()
	if #guilds==0 then
		return
	end

	for i=1,#guilds do
		if not self.guildDict:Contains(guilds[i].ghID) then
			local node = require "GUI.Guild.GuildItem".New(self.Content1, guilds[i])
			self:AddChild(node)
			self.guildDict:Add(guilds[i].ghID, node)
		end
	end
end

function GuildCls:ClearGuildList()
	if self.guildDict==nil then
		self.guildDict = OrderedDictionary.New()
	else
		local keys = self.guildDict:GetKeys()
		for i=1,#keys do
			local node = self.guildDict:GetEntryByKey(keys[i])
			self:RemoveChild(node)
		end
		self.guildDict:Clear()
	end
end

function GuildCls:RequestGuildUI()
	self.game:SendNetworkMessage(require "Network/ServerService".GHQueryRequest())
end

function GuildCls:RedDotStateQuery()
    -- 查询红点提示
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    local UserDataType = require "Framework.UserDataType"
    local RedDotData = self:GetCachedData(UserDataType.RedDotData)

    if RedDotData ~= nil then
        local guild = RedDotData:GetModuleRedState(S2CGuideRedResult.gonghui)
        self.guildRedDotImage:SetActive(guild == 1)
    end
end

function GuildCls:RedDotStateUpdated(moduleId,moduleState)
    -- 红点更新处理
    local S2CGuideRedResult = require "Network.PB.S2CGuideRedResult"
    if moduleId == S2CGuideRedResult.gonghui then
		--公会
		self.guildRedDotImage:SetActive(moduleState == 1)
	end
end


return GuildCls
