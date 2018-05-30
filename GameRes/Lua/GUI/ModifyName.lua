local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local ModifyNameCls = Class(BaseNodeClass)

function ModifyNameCls:Ctor()

end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ModifyNameCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ModifyName', function(go)
		self:BindComponent(go)
	end)
end

function ModifyNameCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function ModifyNameCls:OnResume()
	-- 界面显示时调用
	ModifyNameCls.base.OnResume(self)
	self.ModifyNameInputLable.text = nil
	self:GetUnityTransform():SetAsLastSibling()
	self:RegisterControlEvents()
	self:RegisterNetworkEvents()
	self.game:SendNetworkMessage( require"Network/ServerService".WhetherTheFirstRenameRequest())
end

function ModifyNameCls:OnPause()
	-- 界面隐藏时调用
	ModifyNameCls.base.OnPause(self)
	self:UnregisterControlEvents()
	self:UnregisterNetworkEvents()
end

function ModifyNameCls:OnEnter()
	-- Node Enter时调用
	ModifyNameCls.base.OnEnter(self)
end

function ModifyNameCls:OnExit()
	-- Node Exit时调用
	ModifyNameCls.base.OnExit(self)

end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ModifyNameCls:InitControls()
	local transform = self:GetUnityTransform()
	self.game = utility.GetGame()
	self.ModifyNameRetrunButton = transform:Find('ModifyNameRetrunButton'):GetComponent(typeof(UnityEngine.UI.Button))--返回按钮
	self.PromptText = transform:Find('PromptText'):GetComponent(typeof(UnityEngine.UI.Text))
	self.ModifyNameDiamondNum = transform:Find('ModifyNameDiamondNum'):GetComponent(typeof(UnityEngine.UI.Text))--需要花费的钻石
	self.ModifyNameInputLable = transform:Find('InputBox/ModifyNameInputLable'):GetComponent(typeof(UnityEngine.UI.InputField))--限制输入名字2-7个字
	self.ModifyNameRandomButton = transform:Find('ModifyNameRandomButton'):GetComponent(typeof(UnityEngine.UI.Button))--随机名字按钮
	self.ModifyNameConfirmButton = transform:Find('ModifyNameConfirmButton'):GetComponent(typeof(UnityEngine.UI.Button))--确定按钮
	self.ModifyNameCancelButton = transform:Find('ModifyNameCancelButton'):GetComponent(typeof(UnityEngine.UI.Button))--取消按钮
	
	self.DiamondImage = transform:Find('DiamondImage'):GetComponent(typeof(UnityEngine.UI.Image))--确定按钮
	self.ModifyNameDiamondNum = transform:Find('ModifyNameDiamondNum'):GetComponent(typeof(UnityEngine.UI.Text))--需要花费的钻石
	--背景按钮
	self.BackgroundButton = transform:Find('WindowBase/TranslucentLayer'):GetComponent(typeof(UnityEngine.UI.Button))

    -- # 改名字花费的钻石数量
	self.ModifyNameDiamondNum.text =  require "StaticData.SystemConfig.SystemConfig":GetData(5):GetParameNum()[0]

	self.DiamondImage.enabled=false
	self.ModifyNameDiamondNum.enabled=false
end


function ModifyNameCls:RegisterControlEvents()
	-- 注册 ModifyNameRetrunButton 的事件
	self.__event_button_onModifyNameRetrunButtonClicked__ = UnityEngine.Events.UnityAction(self.OnModifyNameRetrunButtonClicked, self)
	self.ModifyNameRetrunButton.onClick:AddListener(self.__event_button_onModifyNameRetrunButtonClicked__)

	-- 注册 BackgroundButton 的事件
	self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnModifyNameRetrunButtonClicked,self)
	self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)

	-- 注册 ModifyNameRandomButton 的事件
	self.__event_button_onModifyNameRandomButtonClicked__ = UnityEngine.Events.UnityAction(self.OnModifyNameRandomButtonClicked, self)
	self.ModifyNameRandomButton.onClick:AddListener(self.__event_button_onModifyNameRandomButtonClicked__)

	-- 注册 ModifyNameConfirmButton 的事件
	self.__event_button_onModifyNameConfirmButtonClicked__ = UnityEngine.Events.UnityAction(self.OnModifyNameConfirmButtonClicked, self)
	self.ModifyNameConfirmButton.onClick:AddListener(self.__event_button_onModifyNameConfirmButtonClicked__)

	-- 注册 ModifyNameCancelButton 的事件
	self.__event_button_onModifyNameCancelButtonClicked__ = UnityEngine.Events.UnityAction(self.OnModifyNameCancelButtonClicked, self)
	self.ModifyNameCancelButton.onClick:AddListener(self.__event_button_onModifyNameCancelButtonClicked__)

end

function ModifyNameCls:UnregisterControlEvents()
	-- 取消注册 ModifyNameRetrunButton 的事件
	if self.__event_button_onModifyNameRetrunButtonClicked__ then
		self.ModifyNameRetrunButton.onClick:RemoveListener(self.__event_button_onModifyNameRetrunButtonClicked__)
		self.__event_button_onModifyNameRetrunButtonClicked__ = nil
	end

	-- 取消注册 ModifyNameRandomButton 的事件
	if self.__event_button_onModifyNameRandomButtonClicked__ then
		self.ModifyNameRandomButton.onClick:RemoveListener(self.__event_button_onModifyNameRandomButtonClicked__)
		self.__event_button_onModifyNameRandomButtonClicked__ = nil
	end

	-- 取消注册 ModifyNameConfirmButton 的事件
	if self.__event_button_onModifyNameConfirmButtonClicked__ then
		self.ModifyNameConfirmButton.onClick:RemoveListener(self.__event_button_onModifyNameConfirmButtonClicked__)
		self.__event_button_onModifyNameConfirmButtonClicked__ = nil
	end

	-- 取消注册 ModifyNameCancelButton 的事件
	if self.__event_button_onModifyNameCancelButtonClicked__ then
		self.ModifyNameCancelButton.onClick:RemoveListener(self.__event_button_onModifyNameCancelButtonClicked__)
		self.__event_button_onModifyNameCancelButtonClicked__ = nil
	end

	-- 取消注册 BackgroundButton 的事件
	if self.__event_backgroundButton_onButtonClicked__ then
	   self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
	   self.__event_backgroundButton_onButtonClicked__ = nil
	end

end

function ModifyNameCls:RegisterNetworkEvents()
    self.game:RegisterMsgHandler(net.S2CChangePlayerNameResult, self, self.ChangePlayerNameResult)
    self.game:RegisterMsgHandler(net.S2CWhetherTheFirstRenameResult, self, self.WhetherTheFirstRenameResult)

end

function ModifyNameCls:UnregisterNetworkEvents()
    self.game:UnRegisterMsgHandler(net.S2CChangePlayerNameResult, self, self.ChangePlayerNameResult)
    self.game:UnRegisterMsgHandler(net.S2CWhetherTheFirstRenameResult, self, self.WhetherTheFirstRenameResult)
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ModifyNameCls:OnModifyNameRetrunButtonClicked()
	--ModifyNameRetrunButton控件的点击事件处理
    self:Hide()
end

function ModifyNameCls:WhetherTheFirstRenameResult(msg)
	--self.wheTheFirRename=msg.wheTheFirRename
	debug_print("msg.wheTheFirRename",msg.wheTheFirRename)
	if msg.wheTheFirRename then
		self.DiamondImage.enabled=false
		self.ModifyNameDiamondNum.enabled=false
		self.PromptText.text="首次改名免费"
	else
		self.DiamondImage.enabled=true
	    self.ModifyNameDiamondNum.enabled=true
		self.PromptText.text="修改玩家昵称需要花费"

	end
end

function ModifyNameCls:OnModifyNameRandomButtonClicked()
	--ModifyNameRandomButton控件的点击事件处理
	local utility = require "Utils.Utility"
	self.ModifyNameInputLable.text = utility:GetNameRandomly()
end

function ModifyNameCls:OnModifyNameConfirmButtonClicked()
	--ModifyNameConfirmButton控件的点击事件处理
	self:ChangePlayerName(self.ModifyNameInputLable.text)   
end

function ModifyNameCls:OnModifyNameCancelButtonClicked()
	--ModifyNameCancelButton控件的点击事件处理
    self:Hide()
end

--修改名字请求
function ModifyNameCls:ChangePlayerName(NewName)
   self.game:SendNetworkMessage(require "Network.ServerService".ChangePlayerNameRequest(NewName))
end

--修改名字结果回调
function ModifyNameCls:ChangePlayerNameResult(msg)
	-- 请求用户数据 --
	self.DiamondImage.enabled=true
	self.ModifyNameDiamondNum.enabled=true
	self.PromptText.text="修改玩家昵称需要花费"
  	local windowManager = utility:GetGame():GetWindowManager()
  	windowManager:Show(require "GUI.Dialogs.ErrorDialog","修改昵称成功！")
   
	self:Hide()
end
-- # 更新玩家数据的回调
function ModifyNameCls:UpdatePlayerData(msg)
end
return ModifyNameCls
