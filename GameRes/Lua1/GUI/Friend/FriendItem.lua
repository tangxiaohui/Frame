local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local FriendItemCls = Class(BaseNodeClass)

function FriendItemCls:Ctor(parent,friendData)
    self.parent = parent
	self.friendData = friendData
    self.callback = LuaDelegate.New()
end


function FriendItemCls:SetCallback(ctable,func)
     self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function FriendItemCls:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/FriendItem', function(go)
        self:BindComponent(go,false)
    end)
end

function FriendItemCls:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)
    self:LinkComponent(self.parent)
    self:InitControls()
end

function FriendItemCls:OnResume()
    -- 界面显示时调用
    FriendItemCls.base.OnResume(self)
    self:RegisterControlEvents()
    self:ResetView()
end

function FriendItemCls:OnPause()
    -- 界面隐藏时调用
    FriendItemCls.base.OnPause(self)
    self:UnregisterControlEvents()
    self:ResetButtons()
end

function FriendItemCls:OnEnter()
    -- Node Enter时调用
    FriendItemCls.base.OnEnter(self)
end

function FriendItemCls:OnExit()
    -- Node Exit时调用
    FriendItemCls.base.OnExit(self)
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function FriendItemCls:InitControls()
    local transform = self:GetUnityTransform()

    -- 好友
    self.FriendParent = transform:Find('Friend').gameObject
    self.DeleteButton = transform:Find('Friend/DeleteButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.ChatButton = transform:Find('Friend/TalkButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.GiveButton = transform:Find('Friend/GiveButton'):GetComponent(typeof(UnityEngine.UI.Button))

    -- 体力
    self.StaminaParent = transform:Find('Stamina').gameObject
    self.GetButton = transform:Find('Stamina/GetButton'):GetComponent(typeof(UnityEngine.UI.Button))

    -- 添加
    self.AddFriendParent = transform:Find('BeFriend').gameObject
    self.AddFriendButton = transform:Find('BeFriend/AddButton'):GetComponent(typeof(UnityEngine.UI.Button))

    -- 申请
    self.ApplyParent = transform:Find('NewFriend').gameObject
    self.AgreeButton = transform:Find('NewFriend/AgreeButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.RefuseButton = transform:Find('NewFriend/RefuseButton'):GetComponent(typeof(UnityEngine.UI.Button))

    self.nameLabel = transform:Find('NameLabel'):GetComponent(typeof(UnityEngine.UI.Text))
    self.levelLabel = transform:Find('Lv/Text'):GetComponent(typeof(UnityEngine.UI.Text))
    self.powerLabel = transform:Find('PowerLabel'):GetComponent(typeof(UnityEngine.UI.Text))
    self.iconImage = transform:Find('Head/Base/Icon'):GetComponent(typeof(UnityEngine.UI.Image))
    self.infoButton = transform:Find('Head/Frame'):GetComponent(typeof(UnityEngine.UI.Button))
end


function FriendItemCls:RegisterControlEvents()
    -- 注册 DeleteButton 的事件
    self.__event_button_onDeleteButtonClicked__ = UnityEngine.Events.UnityAction(self.OnDeleteButtonClicked, self)
    self.DeleteButton.onClick:AddListener(self.__event_button_onDeleteButtonClicked__)

    -- 注册 ChatButton 的事件
    self.__event_button_onChatButtonClicked__ = UnityEngine.Events.UnityAction(self.OnChatButtonClicked, self)
    self.ChatButton.onClick:AddListener(self.__event_button_onChatButtonClicked__)

    -- 注册 BackpackRetrunButton 的事件
    self.__event_button_onGiveButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGiveButtonClicked, self)
    self.GiveButton.onClick:AddListener(self.__event_button_onGiveButtonClicked__)

    -- 注册 GetButton 的事件
    self.__event_button_onGetButtonClicked__ = UnityEngine.Events.UnityAction(self.OnGetButtonClicked, self)
    self.GetButton.onClick:AddListener(self.__event_button_onGetButtonClicked__)

    -- 注册 AddFriendButton 的事件
    self.__event_button_onAddFriendButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAddFriendButtonClicked, self)
    self.AddFriendButton.onClick:AddListener(self.__event_button_onAddFriendButtonClicked__)

    -- 注册 AgreeButton 的事件
    self.__event_button_onAgreeButtonClicked__ = UnityEngine.Events.UnityAction(self.OnAgreeButtonClicked, self)
    self.AgreeButton.onClick:AddListener(self.__event_button_onAgreeButtonClicked__)

    -- 注册 RefuseButton 的事件
    self.__event_button_onRefuseButtonClicked__ = UnityEngine.Events.UnityAction(self.OnRefuseButtonClicked, self)
    self.RefuseButton.onClick:AddListener(self.__event_button_onRefuseButtonClicked__)

     -- 注册 infoButton 的事件
    self.__event_button_onInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnInfoButtonClicked, self)
    self.infoButton.onClick:AddListener(self.__event_button_onInfoButtonClicked__)
end

function FriendItemCls:UnregisterControlEvents()
    -- 取消注册 DeleteButton 的事件
    if self.__event_button_onDeleteButtonClicked__ then
        self.DeleteButton.onClick:RemoveListener(self.__event_button_onDeleteButtonClicked__)
        self.__event_button_onDeleteButtonClicked__ = nil
    end

     -- 取消注册 ChatButton 的事件
    if self.__event_button_onChatButtonClicked__ then
        self.ChatButton.onClick:RemoveListener(self.__event_button_onChatButtonClicked__)
        self.__event_button_onChatButtonClicked__ = nil
    end

     -- 取消注册 GiveButton 的事件
    if self.__event_button_onGiveButtonClicked__ then
        self.GiveButton.onClick:RemoveListener(self.__event_button_onGiveButtonClicked__)
        self.__event_button_onGiveButtonClicked__ = nil
    end

     -- 取消注册 GetButton 的事件
    if self.__event_button_onGetButtonClicked__ then
        self.GetButton.onClick:RemoveListener(self.__event_button_onGetButtonClicked__)
        self.__event_button_onGetButtonClicked__ = nil
    end

     -- 取消注册 AddFriendButton 的事件
    if self.__event_button_onAddFriendButtonClicked__ then
        self.AddFriendButton.onClick:RemoveListener(self.__event_button_onAddFriendButtonClicked__)
        self.__event_button_onAddFriendButtonClicked__ = nil
    end

     -- 取消注册 AgreeButton 的事件
    if self.__event_button_onAgreeButtonClicked__ then
        self.AgreeButton.onClick:RemoveListener(self.__event_button_onAgreeButtonClicked__)
        self.__event_button_onAgreeButtonClicked__ = nil
    end

     -- 取消注册 RefuseButton 的事件
    if self.__event_button_onRefuseButtonClicked__ then
        self.RefuseButton.onClick:RemoveListener(self.__event_button_onRefuseButtonClicked__)
        self.__event_button_onRefuseButtonClicked__ = nil
    end

     -- 取消注册 infoButton 的事件
    if self.__event_button_onInfoButtonClicked__ then
        self.infoButton.onClick:RemoveListener(self.__event_button_onInfoButtonClicked__)
        self.__event_button_onInfoButtonClicked__ = nil
    end
end
-----------------------------------------------------------------------
function FriendItemCls:SetPattern(modle)
    self.modle = modle
end

function FriendItemCls:SetUid(uid)
    self.uid = uid
end

function FriendItemCls:SetPlayerLevel(playerLevel)
    self.playerLevel = playerLevel
end

function FriendItemCls:SetPlayerName(playerName)
    self.playerName = playerName
end

function FriendItemCls:SetZhanli(zhanli)
    self.zhanli = zhanli
end

function FriendItemCls:SetHeadID(headID)
    self.headID = headID
end

function FriendItemCls:SetState(state)
    self.state = state
end

function FriendItemCls:GetUid()
    return self.uid
end

local function DelayResetView(self)
    while (not self:IsReady()) do
        coroutine.step(1)
    end

    self:ResetButtons()
    if self.modle == 1 then
        self.FriendParent:SetActive(true)
        self.activeModle = self.FriendParent
        self.GiveButton.gameObject:SetActive(self.state)
    elseif self.modle == 2 then
        self.StaminaParent:SetActive(true)
        self.activeModle = self.StaminaParent
    elseif self.modle == 3 then
        self.AddFriendParent:SetActive(true)
        self.activeModle = self.AddFriendParent
    elseif self.modle == 4 then
        self.ApplyParent:SetActive(true)
        self.activeModle = self.ApplyParent
    end

    self.nameLabel.text = self.playerName
    self.levelLabel.text = self.playerLevel
    self.powerLabel.text = self.zhanli

    local tempIconName = require"StaticData/PlayerHead":GetData(self.headID):GetIcon()
    local iconPath = "UI/Atlases/CardHead/"..tostring(tempIconName)
    utility.LoadSpriteFromPath(iconPath,self.iconImage)

--iconImage
end

function FriendItemCls:ResetView()
    self:StartCoroutine(DelayResetView)
end

function FriendItemCls:ResetButtons()
    if self.activeModle ~= nil then
        self.activeModle:SetActive(false)
        self.activeModle = nil
    end
    if self.GiveButtonHided then
        self.GiveButton.gameObject:SetActive(true)
        self.GiveButtonHided = false    
    end
end

function FriendItemCls:SetHideSendButton()
    self.GiveButton.gameObject:SetActive(false)
    self.GiveButtonHided = true
end
-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function FriendItemCls:OnDeleteButtonClicked()
    self.callback:Invoke(1,self.uid)
end

function FriendItemCls:OnChatButtonClicked()
    self.callback:Invoke(2,self.uid,self.playerName)
end

function FriendItemCls:OnGiveButtonClicked()
    self.callback:Invoke(3,self.uid)
end

function FriendItemCls:OnGetButtonClicked()
    self.callback:Invoke(4,self.uid)
end

function FriendItemCls:OnAddFriendButtonClicked()
    self.callback:Invoke(5,self.uid)
end

function FriendItemCls:OnAgreeButtonClicked()
    self.callback:Invoke(6,self.uid)
end

function FriendItemCls:OnRefuseButtonClicked()
    self.callback:Invoke(7,self.uid)
end

function FriendItemCls:OnInfoButtonClicked()
    if self.modle == 1 then
        local windowManager = self:GetGame():GetWindowManager()
        windowManager:Show(require "GUI.ChatPlayer",self.uid,self.friendData)
    end
end

return FriendItemCls