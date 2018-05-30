
local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Const"
require "System.LuaDelegate"

local ServerStatusNode = Class(BaseNodeClass)

function ServerStatusNode:Ctor(transform, table, callback)
    self.callbackOnClick = LuaDelegate.New()
    self.callbackOnClick:Set(table, callback)
    self:BindComponent(transform.gameObject, false)
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    self.button = transform:Find("Background"):GetComponent(typeof(UnityEngine.UI.Button))
    self.statusImage = transform:Find("Status"):GetComponent(typeof(UnityEngine.UI.Image))
    self.serverNameLabel = transform:Find("Name"):GetComponent(typeof(UnityEngine.UI.Text))
end

function ServerStatusNode:OnComponentReady()
    InitControls(self)
end

function ServerStatusNode:Set(id,_,_,name,_,_,status)
    if id == nil then
        self:InactiveComponent()
        return
    end

    utility.LoadSpriteFromPath(utility.GetServerStateSprite(status),self.statusImage)
    self.serverNameLabel.text = name
    self:ActiveComponent()
end

local function OnButtonClicked(self)
    debug_print("ServerStatusNode::OnButtonClicked")
    self.callbackOnClick:Invoke()
end

function ServerStatusNode:OnResume()
    self.__event_ButtonClicked__ = UnityEngine.Events.UnityAction(OnButtonClicked, self)
    self.button.onClick:AddListener(self.__event_ButtonClicked__)
end

function ServerStatusNode:OnPause()
    if self.__event_ButtonClicked__ then
        self.button.onClick:RemoveListener(self.__event_ButtonClicked__)
        self.__event_ButtonClicked__ = nil
    end
end

return ServerStatusNode
