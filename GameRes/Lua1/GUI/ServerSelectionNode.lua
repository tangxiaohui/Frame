
local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"

local ServerSelectionNode = Class(BaseNodeClass)

function ServerSelectionNode:Ctor(gameObject, parentTransform)
    self.serverInfo = nil
    self.parentTransform = parentTransform
    self.controlDirty = false
    if gameObject ~= nil then
        self:BindComponent(gameObject, false)
        return
    end
end

function ServerSelectionNode:OnInit()
    if self:HasUnityGameObject() then
        return
    end

    -- 加载 登录页面 --
    utility.LoadNewGameObjectAsync("UI/Prefabs/SelectServerButton", function(go)
        self:BindComponent(go, false)
        if self.parentTransform ~= nil then
            self:LinkComponent(self.parentTransform)
        end
    end)
end

-- >> 私有函数 << --

-- 更新控件 --
local function UpdateView(self)
	print("@@@@ UpdateView >>> 1")
    if self:HasUnityGameObject() and self.serverInfo ~= nil and self.controlDirty then
	
		print("@@@@ UpdateView >>> 2")
	
        self.controlDirty = false
		
		print("@@@@ UpdateView >>> 3")

        -- 设置服务器ID --
        self.serverNumLabel.text = self.serverInfo:GetId()
		
		print("@@@@ UpdateView >>> 4")

        -- 设置 <繁忙状态> 图标 --
		utility.LoadSpriteFromPath(utility.GetServerStateSprite(self.serverInfo:GetServerState()),self.serverStatusImage)

        -- 设置 <热> 图标
        self.hotIcon.enabled = self.serverInfo:IsNew() == kServerIconState_New

        -- 设置 <新> 图标
        self.newIcon.enabled = self.serverInfo:IsNew() == kServerIconState_Hot

        -- 设置服务器名字 --
        self.serverNameLabel.text = self.serverInfo:GetName()
    end
end

-- 初始化控件绑定 --
local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 主按钮 --
    self.mainButton = transform:GetComponent(typeof(UnityEngine.UI.Button))

    -- 服务器的数字(ID) --
    self.serverNumLabel = transform:Find("ServerNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 状态图标 (繁忙等状态) --
    self.serverStatusImage = transform:Find("StatusIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- <热> 图标 --
    self.hotIcon = transform:Find("HotIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- <新> 图标 --
    self.newIcon = transform:Find("NewIcon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 服务器的名字 --
    self.serverNameLabel = transform:Find("NameLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    UpdateView(self)
end

local function OnMainButtonClicked(self)
    if self.serverInfo ~= nil then
        local messageGuids = require "Framework.Business.MessageGuids"
        self:DispatchEvent(messageGuids.GameServerSelectionNodeClicked, nil, self.serverInfo:GetId())
    end
end

function ServerSelectionNode:SetData(info)
    if self.serverInfo ~= info then
        self.serverInfo = info
        self.controlDirty = true
        UpdateView(self)
    end
end

function ServerSelectionNode:Clear()
    self.serverInfo = nil
    self.serverNumLabel.text = ""
    self.serverStatusImage.sprite = nil
    self.hotIcon.enabled = false
    self.newIcon.enabled = false
    self.serverNameLabel.text = ""
end

function ServerSelectionNode:SetParentTransform(parentTransform)
    self.parentTransform = parentTransform
end

function ServerSelectionNode:OnResume()
    ServerSelectionNode.base.OnResume(self)

    self.__event_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_mainButtonClicked__)

    if self.parentTransform ~= nil then
        self:LinkComponent(self.parentTransform)
    end
end

function ServerSelectionNode:OnPause()
    ServerSelectionNode.base.OnPause(self)

    if self.__event_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_mainButtonClicked__)
        self.__event_mainButtonClicked__ = nil
    end
end

function ServerSelectionNode:OnComponentReady()
    InitControls(self)
end

return ServerSelectionNode
