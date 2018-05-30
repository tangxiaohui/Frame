--
-- User: fenghao
-- Date: 29/06/2017
-- Time: 11:20 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local BattleResultWinNode = Class(BaseNodeClass)

local utility = require "Utils.Utility"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- 经验值
    self.expFill = transform:Find("LevelBase/Fill"):GetComponent(typeof(UnityEngine.UI.Image))

    self.expLabel = transform:Find("LevelBase/Exp"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 等级文本
    self.levelLabel = transform:Find("LevelBase/Text"):GetComponent(typeof(UnityEngine.UI.Text))

    -- 金币
    self.coinLabel = transform:Find("CoinLabel"):GetComponent(typeof(UnityEngine.UI.Text))

    -- Item布局 --
    self.itemLayoutContentTrans = transform:Find("ItemLayout/Viewport/Content")
end

function BattleResultWinNode:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleResultWinNode:OnResume()
end

function BattleResultWinNode:OnPause()
end

-- TODO: 暂时定为FBResponse
function BattleResultWinNode:Show(fbMsg)
    -- # 等级
    self.levelLabel.text = fbMsg.curLevel

    -- # 当前经验值
    local currentExp = fbMsg.curExp
    local maxExp = utility.GetLevelIntervalExp(fbMsg.curLevel)
    self.expFill.fillAmount = currentExp / maxExp
    self.expLabel.text = string.format("%d / %d", currentExp, maxExp)

    -- # 获得的金币
    self.coinLabel.text = fbMsg.awardCoin

    -- # 设置奖励 # --
    local GeneralItemClass = require "GUI.Item.GeneralItem"
    local itemCount = #fbMsg.items
    for i = 1, itemCount do
        local awardItem = fbMsg.items[i]
        local newItem = GeneralItemClass.New(self.itemLayoutContentTrans, awardItem.itemID, awardItem.itemNum, awardItem.itemColor)
        self:AddChild(newItem)
    end

    -- ### 显示 ### --
    self:ActiveComponent()
end

function BattleResultWinNode:Close()
    -- ### 隐藏 ### --
    self:InactiveComponent()

    -- TODO : 删除
end

return BattleResultWinNode