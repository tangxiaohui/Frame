local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
require "LUT.StringTable"

local ProgressChargeAward = Class(BaseNodeClass)
windowUtility.SetMutex(ProgressChargeAward, true)


function  ProgressChargeAward:Ctor()
end

function ProgressChargeAward:OnWillShow(id,msg)
    self.id = id
    self.msg = msg
end

function  ProgressChargeAward:OnInit()
    utility.LoadNewGameObjectAsync("UI/Prefabs/ProgressChargeAward",function(go)
        self:BindComponent(go)
    end)
end

function ProgressChargeAward:OnComponentReady()
    self:InitControls()
end

function ProgressChargeAward:OnResume()
    ProgressChargeAward.base.OnResume(self)
    self:RegisterControlEvents()
    self:LoadPanel()
end

function ProgressChargeAward:OnPause()
    ProgressChargeAward.base.OnPause(self)
    self:UnregisterControlEvents()
end

function ProgressChargeAward:OnEnter()
    ProgressChargeAward.base.OnEnter(self)
end

function ProgressChargeAward:OnExit()
    ProgressChargeAward.base.OnExit(self)
end

function ProgressChargeAward:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function  ProgressChargeAward:InitControls()
    local transform = self:GetUnityTransform()
    self.rankText = transform:Find("Rank/Rank"):GetComponent(typeof(UnityEngine.UI.Text))
    self.rankDesc = transform:Find("Rank/Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.itemPoint = transform:Find("Award/MyGenralItem")
    self.returnButton = transform:Find("ConferButton"):GetComponent(typeof(UnityEngine.UI.Button))

end

function  ProgressChargeAward:RegisterControlEvents()
    self._event_button_onInfoButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
    self.returnButton.onClick:AddListener(self._event_button_onInfoButtonClicked_)

end

function  ProgressChargeAward:UnregisterControlEvents()
    if self._event_button_onInfoButtonClicked_ then
        self.returnButton.onClick:RemoveListener(self._event_button_onInfoButtonClicked_)
        self._event_button_onInfoButtonClicked_ = nil
    end

end

function ProgressChargeAward:OnReturnButtonClicked()
    self:Close(true)
end

function ProgressChargeAward:LoadPanel()
    self.node = {}
    local gametool = require "Utils.GameTools"
    for i=1,#self.msg do
        local msg = self.msg[i]
        local _,data,_,_,itype = gametool.GetItemDataById(msg.itemAwardId)
        local color = gametool.GetItemColorByType(itype,data)
        local awardItem = require "GUI.Active.ActiveAwardItem".New(self.itemPoint,msg.itemAwardId,msg.itemAwardNum,color,false)
        self:AddChild(awardItem)
        self.node[#self.node + 1] = awardItem
    end
    local progressData = require "StaticData.Activity.ProgressChargeInfo":GetData(self.id)
    self.rankText.text = progressData:GetTitle()
    self.rankDesc.text = progressData:GetDescription()
end

return ProgressChargeAward