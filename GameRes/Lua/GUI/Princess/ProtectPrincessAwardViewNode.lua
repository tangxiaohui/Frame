--
-- User: fenghao
-- Date: 03/07/2017
-- Time: 7:51 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local messageGuids = require "Framework.Business.MessageGuids"
require "Const"

local MaxOpenCount = 20

local ProtectPrincessAwardViewNode = Class(BaseNodeClass)

local function ReloadCountView(self, aid, gateID, count)

    local defendThePrincessAwardData = require "StaticData.Princess.DefendThePrincessAward":GetData(gateID)

    local allDiamonds = defendThePrincessAwardData:GetDiamond()
    local totalMaxOpenCount = allDiamonds.Count


    local diamond = 0

    if count < totalMaxOpenCount then
        diamond = allDiamonds[count]
    end

    self.Text1FreeObject:SetActive(diamond <= 0)
    self.Text2Object:SetActive(diamond > 0)
    self.remainingTimes.text = totalMaxOpenCount - count
    self.diamondLabel.text = diamond


    -- local diamond = 0

    -- if aid > 0 then
    --     local defendThePrincessAwardData = require "StaticData.Princess.DefendThePrincessAward":GetData(aid)
    --     diamond = defendThePrincessAwardData:GetDiamond()
    -- end

    -- self.Text1FreeObject:SetActive(diamond <= 0)
    -- self.Text2Object:SetActive(diamond > 0)
    -- self.remainingTimes.text = MaxOpenCount - count
    -- self.diamondLabel.text = diamond
end

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 打开 --
    self.openButton = transform:Find("OpenButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- 摧毁 --
    self.destroyButton = transform:Find("DestroyButton"):GetComponent(typeof(UnityEngine.UI.Button))

    -- Text1 --
    self.Text1FreeObject = transform:Find("Text1").gameObject

    -- Text2 --
    self.Text2Object = transform:Find("Text2").gameObject

    -- 剩余次数 --
    self.remainingTimes = transform:Find("BoxTimesValue"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 钻石个数 --
    self.diamondLabel = transform:Find("priceLabel"):GetComponent(typeof(UnityEngine.UI.Text))

end

function ProtectPrincessAwardViewNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end


local function OnOpenButtonClicked(self)
    local ServerService = require "Network.ServerService"
    local msg, prototype = ServerService.ProtectDrawAwardRequest()
    self:GetGame():SendNetworkMessage(msg, prototype)
end

local function OnDestroyButtonClicked(self)
    print("销毁箱子!")
    -- 请求数据 --
    local ServerService = require "Network.ServerService"
    local msg, prototype = ServerService.ProtectQueryRequest(100)
    self:GetGame():SendNetworkMessage(msg, prototype)
end



local function AddItem(items, id, count, color)
    if count > 0 then
        local newItem = {}
        newItem.id = id
        newItem.count = count
        newItem.color = color
        items[#items + 1] = newItem
    end
end

local function OnDrawAwardWindowClosed(self)
    local msg = self.tempDrawAwardMsg
    self.tempDrawAwardMsg = nil

    utility.ASSERT(msg ~= nil, "消息协议不能为nil!")

    if msg ~= nil then
        if msg.gateID ~= self.protectMsg.curGate then
            -- 先更新保卫公主数据 --

            debug_print("@@@ 保卫公主Response", self.protectMsg, self.protectMsg.curGate, self.protectMsg.gateState, self.protectMsg.count, msg.gateID)

            self.protectMsg.curGate = msg.gateID
            self.protectMsg.gateState = kProtectPrincessGateStatus_None
            
            -- 说明该进入下一个阶段了!
            local totalGateCount = #self.protectMsg.gateInfo
            if msg.gateID > totalGateCount then
                -- print("已经到达最后一波怪了!")
                -- 通知上层该隐藏的隐藏 该显示的显示.
                self:DispatchEvent(messageGuids.ProtectDataDone, nil, self.protectMsg)
            else
                self.protectMsg.count[msg.gateID].aid = msg.aid
                -- 切换到下一波次 --
                --debug_print("该进入下一波次了!", msg.gateID, msg.aid, self.protectMsg)
                -- 通知进入下一阶段
                self:DispatchEvent(messageGuids.ProtectDataNextGate, nil, self.protectMsg)
            end
            return
        end

        print("gateID", msg.gateID, "count", msg.count, "aid", msg.aid)

        ReloadCountView(self, msg.aid, msg.gateID, msg.count)
    end
end

local function OnProtectDrawAwardResponse(self, msg)

    local windowManager = self:GetGame():GetWindowManager()

    local AwardCls = require "GUI.Task.GetAwardItem"

    local items = {}
    AddItem(items, kCurrencyId_Coin, msg.coin, 0)
    AddItem(items, kCurrencyId_Princess, msg.protectCoin, 0)

    for i = 1, #msg.awards do
        local curAwardItem = msg.awards[i]
        AddItem(items, curAwardItem.itemID, curAwardItem.itemNum, curAwardItem.itemColor)
    end

    self.tempDrawAwardMsg = msg

    windowManager:Show(AwardCls,items, self, OnDrawAwardWindowClosed)
end

function ProtectPrincessAwardViewNode:OnResume()

    self:GetGame():RegisterMsgHandler(net.S2CProtectDrawAwardResult, self, OnProtectDrawAwardResponse)

    -- 注册 打开 按钮 --
    self.__event_openButtonClicked__ = UnityEngine.Events.UnityAction(OnOpenButtonClicked, self)
    self.openButton.onClick:AddListener(self.__event_openButtonClicked__)

    -- 注册 摧毁 按钮 --
    self.__event_destroyButtonClicked__ = UnityEngine.Events.UnityAction(OnDestroyButtonClicked, self)
    self.destroyButton.onClick:AddListener(self.__event_destroyButtonClicked__)
end

function ProtectPrincessAwardViewNode:OnPause()

    self:GetGame():UnRegisterMsgHandler(net.S2CProtectDrawAwardResult, self, OnProtectDrawAwardResponse)

    if self.__event_openButtonClicked__ then
        self.openButton.onClick:RemoveListener(self.__event_openButtonClicked__)
        self.__event_openButtonClicked__ = nil
    end

    if self.__event_destroyButtonClicked__ then
        self.destroyButton.onClick:RemoveListener(self.__event_destroyButtonClicked__)
        self.__event_destroyButtonClicked__ = nil
    end
end

function ProtectPrincessAwardViewNode:Show(msg)
    self:ActiveComponent()

    self.protectMsg = msg

    local curGate = msg.curGate
    local countInfo = msg.count[curGate]

    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.ProtectShowInspectorTitle, nil, true, "遗落的宝箱")

    ReloadCountView(self, msg.aid, curGate, countInfo.count)
end

function ProtectPrincessAwardViewNode:Close()
    self:InactiveComponent()

    self.protectMsg = nil
end

return ProtectPrincessAwardViewNode
