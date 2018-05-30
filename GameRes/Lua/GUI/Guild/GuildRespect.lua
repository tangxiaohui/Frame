local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local GuildRespectCls = Class(BaseNodeClass)
local GuildCommonFunc = require "GUI/Guild/GuildCommonFunc"
local LegionInfoData = require "StaticData.LegionInfo"
local LegionRespectData = require "StaticData.LegionRespect"
require "System.LuaDelegate"

function GuildRespectCls:Ctor()
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function GuildRespectCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GuildRespect', function(go)
		self:BindComponent(go)
	end)
end

function GuildRespectCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function GuildRespectCls:OnResume()
	-- 界面显示时调用
	GuildRespectCls.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.base

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
end

function GuildRespectCls:OnPause()
	-- 界面隐藏时调用
	GuildRespectCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function GuildRespectCls:OnEnter()
	-- Node Enter时调用
	GuildRespectCls.base.OnEnter(self)
end

function GuildRespectCls:OnExit()
	-- Node Exit时调用
	GuildRespectCls.base.OnExit(self)
end

function GuildRespectCls:OnWillShow(managers, remain)
	self.managers = managers
	self.remain = remain
	self.selected = -1
	self.type = -1
end

function GuildRespectCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function GuildRespectCls:OnSetCallBack(table,callBack)
	if callBack ~=nil then
        self.callBack = LuaDelegate.New()
        self.callBack:Set(table, callBack)
    end
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function GuildRespectCls:InitControls()
	local transform = self:GetUnityTransform()
	self.base = transform:Find('Base')
	self.CrossButton = self.base:Find('CrossButton'):GetComponent(typeof(UnityEngine.UI.Button))
	self.Notice = self.base:Find('NoticeBase/Notice'):GetComponent(typeof(UnityEngine.UI.Text))
	self.CoinRespect = self.base:Find('CoinRespect'):GetComponent(typeof(UnityEngine.UI.Button))
	self.EarnGuildCoin = self.base:Find('CoinRespect/EarnGuildCoin'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NeedCoin = self.base:Find('CoinRespect/NeedCoin'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RespectSelectBox = self.base:Find('CoinRespect/RespectSelectBox')
	self.DiaRespect = self.base:Find('DiaRespect'):GetComponent(typeof(UnityEngine.UI.Button))
	self.EarnGuildCoin1 = self.base:Find('DiaRespect/EarnGuildCoin'):GetComponent(typeof(UnityEngine.UI.Text))
	self.NeedDia = self.base:Find('DiaRespect/NeedDia'):GetComponent(typeof(UnityEngine.UI.Text))
	self.RespectSelectBox1 = self.base:Find('DiaRespect/RespectSelectBox')
	self.ConfirmButton = self.base:Find('ConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))

	--背景按钮
	self.BackgroundButton = transform:Find('TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

	self.PlayerBox = {}
	self.HeadBase = {}
	self.Head = {}
	self.Name = {}
	self.Position = {}
	self.Respect = {}
	self.Cover = {}
	self.Select = {}
	for i=1,4 do
		self.PlayerBox[i] = self.base:Find('Layout/PlayerBox'..i):GetComponent(typeof(UnityEngine.UI.Button))
		self.HeadBase[i] = self.base:Find('Layout/PlayerBox'..i..'/Head/Base'):GetComponent(typeof(UnityEngine.UI.Image))
		self.Head[i] = self.base:Find('Layout/PlayerBox'..i..'/Head/Base/PersonalInformationHeadIcon'):GetComponent(typeof(UnityEngine.UI.Image))
		self.Name[i] = self.base:Find('Layout/PlayerBox'..i..'/PlayerNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.Position[i] = self.base:Find('Layout/PlayerBox'..i..'/PlayerPositionLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.Respect[i] = self.base:Find('Layout/PlayerBox'..i..'/RespectPointLabel'):GetComponent(typeof(UnityEngine.UI.Text))
		self.Cover[i] = self.base:Find('Layout/PlayerBox'..i..'/Cover')
		self.Select[i] = self.base:Find('Layout/PlayerBox'..i..'/RespectSelectBox')
	end

	self:InitView()
	self.myGame = utility:GetGame()
end

function GuildRespectCls:InitView()
	self.Notice.text = "选择一名管理崇奉，今天还有"..self.remain.."次崇奉机会"
	for i=1,4 do
		local bEmpty = self.managers[i]==nil
		self.Cover[i].gameObject:SetActive(bEmpty)
		self.PlayerBox[i].enabled = not bEmpty
		if not bEmpty then
			local managerInfo = self.managers[i]
			self.Name[i].text = managerInfo.name
			self.Position[i].text = LegionInfoData:GetData(managerInfo.job):GetName()
			self.Respect[i].text = managerInfo.count
			utility.LoadRoleHeadIcon(managerInfo.playerHead, self.Head[i])
		end
	end
	self.EarnGuildCoin.text = LegionRespectData:GetData(1):GetCoinNum()
	self.NeedCoin.text = LegionRespectData:GetData(1):GetPriceNum()
	self.EarnGuildCoin1.text = LegionRespectData:GetData(2):GetCoinNum()
	self.NeedDia.text = LegionRespectData:GetData(2):GetPriceNum()

	self:OnPlayerBoxClicked(0)
	self:OnRespectTypeClicked(0)
end

function GuildRespectCls:RegisterControlEvents()
	-- 注册 CrossButton 的事件
	self.__event_button_onCrossButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked, self)
	self.CrossButton.onClick:AddListener(self.__event_button_onCrossButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCrossButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 PlayerBox1 的事件
	self.__event_button_onPlayerBox1Clicked__ = UnityEngine.Events.UnityAction(self.OnPlayerBox1Clicked, self)
	self.PlayerBox[1].onClick:AddListener(self.__event_button_onPlayerBox1Clicked__)

	-- 注册 PlayerBox2 的事件
	self.__event_button_onPlayerBox2Clicked__ = UnityEngine.Events.UnityAction(self.OnPlayerBox2Clicked, self)
	self.PlayerBox[2].onClick:AddListener(self.__event_button_onPlayerBox2Clicked__)

	-- 注册 PlayerBox3 的事件
	self.__event_button_onPlayerBox3Clicked__ = UnityEngine.Events.UnityAction(self.OnPlayerBox3Clicked, self)
	self.PlayerBox[3].onClick:AddListener(self.__event_button_onPlayerBox3Clicked__)

	-- 注册 PlayerBox4 的事件
	self.__event_button_onPlayerBox4Clicked__ = UnityEngine.Events.UnityAction(self.OnPlayerBox4Clicked, self)
	self.PlayerBox[4].onClick:AddListener(self.__event_button_onPlayerBox4Clicked__)

	-- 注册 CoinRespect 的事件
	self.__event_button_onCoinRespectClicked__ = UnityEngine.Events.UnityAction(self.OnCoinRespectClicked, self)
	self.CoinRespect.onClick:AddListener(self.__event_button_onCoinRespectClicked__)

	-- 注册 DiaRespect 的事件
	self.__event_button_onDiaRespectClicked__ = UnityEngine.Events.UnityAction(self.OnDiaRespectClicked, self)
	self.DiaRespect.onClick:AddListener(self.__event_button_onDiaRespectClicked__)

	-- 注册 ConfirmButton 的事件
	self.__event_button_onConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked, self)
	self.ConfirmButton.onClick:AddListener(self.__event_button_onConfirmButtonClicked__)
end

function GuildRespectCls:UnregisterControlEvents()
	-- 取消注册 CrossButton 的事件
	if self.__event_button_onCrossButtonClicked__ then
		self.CrossButton.onClick:RemoveListener(self.__event_button_onCrossButtonClicked__)
		self.__event_button_onCrossButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

	-- 取消注册 PlayerBox1 的事件
	if self.__event_button_onPlayerBox1Clicked__ then
		self.PlayerBox[1].onClick:RemoveListener(self.__event_button_onPlayerBox1Clicked__)
		self.__event_button_onPlayerBox1Clicked__ = nil
	end

	-- 取消注册 PlayerBox2 的事件
	if self.__event_button_onPlayerBox2Clicked__ then
		self.PlayerBox[2].onClick:RemoveListener(self.__event_button_onPlayerBox2Clicked__)
		self.__event_button_onPlayerBox2Clicked__ = nil
	end

	-- 取消注册 PlayerBox3 的事件
	if self.__event_button_onPlayerBox3Clicked__ then
		self.PlayerBox[3].onClick:RemoveListener(self.__event_button_onPlayerBox3Clicked__)
		self.__event_button_onPlayerBox3Clicked__ = nil
	end

	-- 取消注册 PlayerBox4 的事件
	if self.__event_button_onPlayerBox4Clicked__ then
		self.PlayerBox[4].onClick:RemoveListener(self.__event_button_onPlayerBox4Clicked__)
		self.__event_button_onPlayerBox4Clicked__ = nil
	end

	-- 取消注册 CoinRespect 的事件
	if self.__event_button_onCoinRespectClicked__ then
		self.CoinRespect.onClick:RemoveListener(self.__event_button_onCoinRespectClicked__)
		self.__event_button_onCoinRespectClicked__ = nil
	end

	-- 取消注册 DiaRespect 的事件
	if self.__event_button_onDiaRespectClicked__ then
		self.DiaRespect.onClick:RemoveListener(self.__event_button_onDiaRespectClicked__)
		self.__event_button_onDiaRespectClicked__ = nil
	end

	-- 取消注册 ConfirmButton 的事件
	if self.__event_button_onConfirmButtonClicked__ then
		self.ConfirmButton.onClick:RemoveListener(self.__event_button_onConfirmButtonClicked__)
		self.__event_button_onConfirmButtonClicked__ = nil
	end
end

function GuildRespectCls:RegisterNetworkEvents()
	utility:GetGame():RegisterMsgHandler(net.S2CGHUpdateResultMessage, self, self.GHUpdateResultMessage)
end

function GuildRespectCls:UnregisterNetworkEvents()
	utility:GetGame():UnRegisterMsgHandler(net.S2CGHUpdateResultMessage, self, self.GHUpdateResultMessage)
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function GuildRespectCls:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function GuildRespectCls:OnExitTransitionDidStart(immediately)
    GuildRespectCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.base

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function GuildRespectCls:OnCrossButtonClicked()
	self:Close()
end

function GuildRespectCls:OnConfirmButtonClicked()
	if self.selected<1 or self.selected>4 or self.type<1 or self.type>2 then
		GuildCommonFunc.ShowErrorTip("请进行有效选择！")
		return
	end
	
	local uid = self.managers[self.selected].playerUID
	local selfUID = self:GetCachedData(require "Framework.UserDataType".PlayerData):GetUid()
	if uid==selfUID then
		GuildCommonFunc.ShowErrorTip("不能崇奉自己！")
	else
		self.myGame:SendNetworkMessage(require "Network/ServerService".GHUpdateRequest(3, self.type, selfUID, uid))
	end
end

function GuildRespectCls:OnPlayerBox1Clicked()
	self:OnPlayerBoxClicked(1)
end

function GuildRespectCls:OnPlayerBox2Clicked()
	self:OnPlayerBoxClicked(2)
end

function GuildRespectCls:OnPlayerBox3Clicked()
	self:OnPlayerBoxClicked(3)
end

function GuildRespectCls:OnPlayerBox4Clicked()
	self:OnPlayerBoxClicked(4)
end

function GuildRespectCls:OnCoinRespectClicked()
	self:OnRespectTypeClicked(1)
end

function GuildRespectCls:OnDiaRespectClicked()
	self:OnRespectTypeClicked(2)
end

function GuildRespectCls:OnRespectTypeClicked(type)
	if type==self.type then
		return
	end

	self.RespectSelectBox.gameObject:SetActive(type==1)
	self.RespectSelectBox1.gameObject:SetActive(type==2)
	self.type = type
end

function GuildRespectCls:OnPlayerBoxClicked(index)
	if index==self.selected then
		return
	end

	if self.managers[self.selected] then
		self.Select[self.selected].gameObject:SetActive(false)
	end
	if self.managers[index] then
		self.Select[index].gameObject:SetActive(true)
		self.selected = index
	end
end

function GuildRespectCls:GHUpdateResultMessage(msg)

	if  self.callBack ~=nil then
		local coinNum = LegionRespectData:GetData(self.type):GetCoinNum()
        self.callBack:Invoke(coinNum)
    end

	self:Close()
end


return GuildRespectCls
