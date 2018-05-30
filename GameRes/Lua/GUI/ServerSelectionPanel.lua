--
-- User: fenghao
-- Date: 21/07/2017
-- Time: 3:20 PM
--

local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
require "Collection.DataStack"
require "Collection.DataQueue"
require "Const"

local ServerSelectionPanel = Class(BaseNodeClass)

function ServerSelectionPanel:Ctor(transform, poolTransform)
    self.hasCreatedPool = false
    self.serverViewPool = DataStack.New()
    self.poolTransform = poolTransform
    self.spawnedItems = DataQueue.New()
    self.tabMode = kServerTabType_All
    self.forceUpdate = true
    self:BindComponent(transform.gameObject, false)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

	-- 关闭对话框 --
	self.closeButton = transform:Find("ReturnButton"):GetComponent(typeof(UnityEngine.UI.Button))
	
    -- 最近的服务器(过滤) --
    self.recentServersTrans = transform:Find("Scroll View/Viewport/Content/RecentServers")

    -- 全部的服务器(过滤) --
    self.allServersTrans = transform:Find("Scroll View/Viewport/Content/AllServers")

    -- 拥有玩家的标题 --
    self.playedServerObject = transform:Find("Scroll View/Viewport/Content/AllTitle/PlayedServer").gameObject

    -- 推荐的服务器 标题
    self.recommendedServerObject = transform:Find("Scroll View/Viewport/Content/AllTitle/RecomandedServer").gameObject

    -- 所有的服务器 标题 --
    self.allServersObject = transform:Find("Scroll View/Viewport/Content/AllTitle/AllServer").gameObject

    -- 拥有角色的服务器 按钮 --
    self.playedButton = transform:Find("BackGround/PlayedButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.playedButtonOffObject = transform:Find("BackGround/PlayedButton/Off").gameObject

    -- 推荐服务器 按钮 --
    self.recommendedButton = transform:Find("BackGround/RecommendButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.recommendedButtonOffObject = transform:Find("BackGround/RecommendButton/Off").gameObject

    -- 所有服务器 按钮
    self.allServerButton = transform:Find("BackGround/AllButton"):GetComponent(typeof(UnityEngine.UI.Button))
    self.allServerButtonOffObject = transform:Find("BackGround/AllButton/Off").gameObject

end

local function UpdateOffStatus(self, mode)
    self.playedButtonOffObject:SetActive(mode ~= kServerTabType_Role)
    self.recommendedButtonOffObject:SetActive(mode ~= kServerTabType_Recommended)
    self.allServerButtonOffObject:SetActive(mode ~= kServerTabType_All)
end

local function UpdateServerTitle(self, mode)
    self.playedServerObject:SetActive(mode == kServerTabType_Role)
    self.recommendedServerObject:SetActive(mode == kServerTabType_Recommended)
    self.allServersObject:SetActive(mode == kServerTabType_All)
end


local function DespawnAllItems(self)
    self.spawnedItems:Foreach(function(item)
        self:RemoveChild(item)
        item:Clear()
        item:UnlinkComponent(self.poolTransform)
        self.serverViewPool:Push(item)
    end)
    self.spawnedItems:Clear()
end

local function SpawnRecommendedItem(self, serverInfo)
    local serverSelectionNode = self.serverViewPool:Pop()
    serverSelectionNode:SetData(serverInfo)
    serverSelectionNode:SetParentTransform(self.allServersTrans)
    self:AddChild(serverSelectionNode)
    self.spawnedItems:Enqueue(serverSelectionNode)
end

local function SpawnRecentItem(self, serverInfo)
    local recentSelectNode = self.serverViewPool:Pop()
    recentSelectNode:SetData(serverInfo)
    recentSelectNode:SetParentTransform(self.recentServersTrans)
    self:AddChild(recentSelectNode)
    self.spawnedItems:Enqueue(recentSelectNode)
end

-- 拥有玩家
local function OnPlayedTabButtonClicked(self)
    if self.tabMode == kServerTabType_Role and not self.forceUpdate then
        return
    end

    -- debug_print("拥有角色!!")

    self.forceUpdate = false

    -- 回收所有控件 --
    DespawnAllItems(self)

    self.tabMode = kServerTabType_Role

    UpdateServerTitle(self, self.tabMode)

    UpdateOffStatus(self, self.tabMode)


    -- 所有的服务器/最近(过滤)
    local gameServer = self:GetGame():GetGameServer()
    local recentServers = gameServer:GetAllRecentServers()


    gameServer:ForeachServer(function(serverInfo, hasRole)
        if hasRole then
            SpawnRecommendedItem(self, serverInfo)
        end
    end)

    for i = 1, #recentServers do
        if gameServer:HasRoleTheServer(recentServers[i]) then
            local entry = gameServer:GetServerEntry(recentServers[i])
            if entry ~= nil then
                SpawnRecentItem(self, entry)
            end
        end
    end

end

-- 推荐
local function OnRecommendedButtonClicked(self)
    if self.tabMode == kServerTabType_Recommended and not self.forceUpdate then
        return
    end

    -- debug_print("推荐服务器!!")

    self.forceUpdate = false

    -- 回收所有控件 --
    DespawnAllItems(self)

    self.tabMode = kServerTabType_Recommended

    UpdateServerTitle(self, self.tabMode)

    UpdateOffStatus(self, self.tabMode)
 

    -- 所有的服务器/最近(过滤)
    local gameServer = self:GetGame():GetGameServer()
    local recentServers = gameServer:GetAllRecentServers()

    gameServer:ForeachServer(function(serverInfo, _) 
        -- 只找推荐的服务器 --
        if serverInfo:IsRecommended() then
            SpawnRecommendedItem(self, serverInfo)
        end
    end)

    for i = 1, #recentServers do
        local entry = gameServer:GetServerEntry(recentServers[i])
        if entry ~= nil and entry:IsRecommended() then
            SpawnRecentItem(self, entry)
        end
    end
end

-- 所有
local function OnAllServerButtonClicked(self)
    if self.tabMode == kServerTabType_All and not self.forceUpdate then
        return
    end

    -- debug_print("所有服务器!!")

    self.forceUpdate = false

    -- 回收所有控件 --
    DespawnAllItems(self)

    self.tabMode = kServerTabType_All

    UpdateServerTitle(self, self.tabMode)

    UpdateOffStatus(self, self.tabMode)

    -- 所有的服务器/最近(过滤)
    local gameServer = self:GetGame():GetGameServer()
    local recentServers = gameServer:GetAllRecentServers()

    gameServer:ForeachServer(function(serverInfo, _) 
        -- 只找推荐的服务器 --
        SpawnRecommendedItem(self, serverInfo)
    end)

    for i = 1, #recentServers do
        local entry = gameServer:GetServerEntry(recentServers[i])
        if entry ~= nil then
            SpawnRecentItem(self, entry)
        end
    end
end

local function UpdateView(self)
    self.forceUpdate = true

    if self.tabMode == kServerTabType_Role then
        OnPlayedTabButtonClicked(self)
    elseif self.tabMode == kServerTabType_Recommended then
        OnRecommendedButtonClicked(self)
    elseif self.tabMode == kServerTabType_All then
        OnAllServerButtonClicked(self)
    end

    self.forceUpdate = false
end


function ServerSelectionPanel:OnComponentReady()
    InitControls(self)
end

function ServerSelectionPanel:InitPool(count)
    if self.hasCreatedPool then
        return
    end

    local ServerSelectionNodeClass = require "GUI.ServerSelectionNode"
    for i = 1, count do
        self.serverViewPool:Push(ServerSelectionNodeClass.New(nil, nil))
    end

    self.hasCreatedPool = true
end

function ServerSelectionPanel:Show()
    -- 更新View --
    UpdateView(self)
    self:ActiveComponent()
end

function ServerSelectionPanel:Hide()
    -- 回收 --
    DespawnAllItems(self)
    self:InactiveComponent()
end

function OnCloseButtonClicked(self)
	self:Hide()
end


function ServerSelectionPanel:OnResume()
    self.__event_playedButtonClicked__ = UnityEngine.Events.UnityAction(OnPlayedTabButtonClicked, self)
    self.playedButton.onClick:AddListener(self.__event_playedButtonClicked__)


    self.__event_recommendedButtonClicked__ = UnityEngine.Events.UnityAction(OnRecommendedButtonClicked, self)
    self.recommendedButton.onClick:AddListener(self.__event_recommendedButtonClicked__)


    self.__event_allServerButtonClicked__ = UnityEngine.Events.UnityAction(OnAllServerButtonClicked, self)
    self.allServerButton.onClick:AddListener(self.__event_allServerButtonClicked__)
	
	
	self.__event_closeButtonClicked__ = UnityEngine.Events.UnityAction(OnCloseButtonClicked, self)
	self.closeButton.onClick:AddListener(self.__event_closeButtonClicked__)
end

function ServerSelectionPanel:OnPause()
    if self.__event_playedButtonClicked__ then
        self.playedButton.onClick:RemoveListener(self.__event_playedButtonClicked__)
        self.__event_playedButtonClicked__ = nil
    end

    if self.__event_recommendedButtonClicked__ then
        self.recommendedButton.onClick:RemoveListener(self.__event_recommendedButtonClicked__)
        self.__event_recommendedButtonClicked__ = nil
    end

    if self.__event_allServerButtonClicked__ then
        self.allServerButton.onClick:RemoveListener(self.__event_allServerButtonClicked__)
        self.__event_allServerButtonClicked__ = nil
    end
	
	if self.__event_closeButtonClicked__ then
		self.closeButton.onClick:RemoveListener(self.__event_closeButtonClicked__)
		self.__event_closeButtonClicked__ = nil
	end
end

return ServerSelectionPanel
