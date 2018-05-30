
local NodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"

local GeneralItemClass = require "GUI.Item.GeneralItem"

local RaidAwardItem = Class(NodeClass)

function RaidAwardItem:Ctor(transform)
    self.isLayoutFinished = false
    self.isShowIconFinished = false
    self.hasBindedControl = false

    self:BindComponent(transform.gameObject)
end

function RaidAwardItem:OnComponentReady()
    self:InitControls()
end

function RaidAwardItem:InitControls()
    local transform = self:GetUnityTransform()

    -- 用于布局用 --
    self.rootLayoutElement = transform:GetComponent(typeof(UnityEngine.UI.LayoutElement))

    -- 获取列表的 --
    self.listTransform = transform:Find("List")
    -- List Canvas
    self.listLayoutElement = self.listTransform:GetComponent(typeof(UnityEngine.UI.LayoutElement))

    -- 金币 --
    self.coinLabel = transform:Find("Currency/FightingSettlementAwardCurrencyNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 经验 --
    self.expLabel = transform:Find("Exp/FightingSettlementAwardExpNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 标题 --
    self.titleLabel = transform:Find("Title"):GetComponent(typeof(UnityEngine.UI.Text))

    self.hasBindedControl = true
end

local function DelayLayout(self)
    repeat
        coroutine.step(1)
    until(self:IsReady())
    coroutine.step()
    self.isLayoutFinished = true
end

function RaidAwardItem:SetData(msg, pos)
    self.isLayoutFinished = false

    if not self.hasBindedControl then
        self.resultData = msg
        self.resultPos = pos
        return
    end

    -- 显示标题 => 第 n 战
    self.titleLabel.text = string.format(SweepStringTable[6], pos)

    -- 获取的经验
    self.expLabel.text = msg.awardExp[pos]

    -- 获取的金币
    self.coinLabel.text = msg.awardCoin[pos]

    -- 获取道具个数 (2个道具)/
    local itemCount = #(msg.itemList[pos].items)
--    print('itemCount = ', itemCount)

--    -- 测试代码
--    itemCount = math.random(3,10)

    -- 获取大小(预计算)
    local contentSize = math.max(1, math.ceil(itemCount / 4)) * 100 + 39 + 10
    local itemSize = contentSize - 149 + 200

    -- 设置内部物品list的大小
    self.listLayoutElement.preferredHeight = contentSize

    -- 设置外部Item的大小
    self.rootLayoutElement.preferredHeight = itemSize

    -- 延时布局
    self:StartCoroutine(DelayLayout)
end

function RaidAwardItem:IsLayoutFinished()
    return self.isLayoutFinished == true
end

function RaidAwardItem:IsShowIconFinished()
    return self.isShowIconFinished == true
end

local function DelayShowIcons(self)
    local items = self.resultData.itemList[self.resultPos].items

    local count = #items

    for i = 1, count do
        local newNode = GeneralItemClass.New(self.listTransform, items[i].itemID, items[i].itemNum, nil)
        self:AddChild(newNode)
        repeat
            coroutine.step(1)
        until(newNode:IsReady())
        coroutine.step(1)
    end

    self.isShowIconFinished = true
end

function RaidAwardItem:ShowIcons()
    self.isShowIconFinished = true
    self:StartCoroutine(DelayShowIcons)
end

function RaidAwardItem:OnResume()
    RaidAwardItem.base.OnResume(self)
    self:SetData(self.resultData, self.resultPos)
end

function RaidAwardItem:OnPause()
    RaidAwardItem.base.OnPause(self)

    self:RemoveAllChildren(true)
    -- 设置成默认值 --
    self.isLayoutFinished = false
    self.isShowIconFinished = false
end

return RaidAwardItem