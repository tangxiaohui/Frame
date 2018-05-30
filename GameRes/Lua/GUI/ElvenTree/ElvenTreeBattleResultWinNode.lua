--
-- User: fenghao
-- Date: 29/06/2017
-- Time: 11:20 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local ElvenTreeBattleResultWinNode = Class(BaseNodeClass)

local utility = require "Utils.Utility"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- Layout
    self.Layout = transform:Find('ItemLayout')

end

function ElvenTreeBattleResultWinNode:Ctor(transform)
    print(">>>>>>>>>>>>>>>>  is me ")
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function ElvenTreeBattleResultWinNode:OnResume()
end

function ElvenTreeBattleResultWinNode:OnPause()
end

-- TODO: 暂时定为FBResponse
function ElvenTreeBattleResultWinNode:Show(msg)
    -- -- # 等级
    print("精灵树战斗结果    ",#msg.award,msg.award.itemID,msg.repairBoxID,msg.success,msg.playerUID,msg.award.itemNum,msg.award.itemColor)
   
    local newItem = require"GUI.Item.GeneralItem".New(self.Layout, msg.award.itemID, msg.award.itemNum,nil)
    self:AddChild(newItem)

      --     optional bool success = 3;//true=战斗胜利
    -- optional int32 historyAward = 4;//超过历史记录的奖励,没有则为0
    -- optional int32 curRank = 5;//玩家当前的排名
    -- optional int32 historyHighRank = 6;//历史最高排名
    -- optional int32 lastRank = 7;//上次排名
    -- optional int32 killHighLevelAward = 8;//击杀超过自己等级的奖励
    -- self.levelLabel.text = fbMsg.curLevel

    -- -- # 当前经验值
    -- local currentExp = fbMsg.curExp
    -- local maxExp = utility.GetLevelIntervalExp(fbMsg.curLevel)
    -- self.expFill.fillAmount = currentExp / maxExp

    -- -- # 获得的金币
    -- self.coinLabel.text = fbMsg.awardCoin

    -- -- # 设置奖励 # --
    -- local GeneralItemClass = require "GUI.Item.GeneralItem"
    -- local itemCount = #fbMsg.items
    -- for i = 1, itemCount do
    --     local awardItem = fbMsg.items[i]
    --     local newItem = GeneralItemClass.New(self.itemLayoutContentTrans, awardItem.itemID, awardItem.itemNum, awardItem.itemColor)
    --     self:AddChild(newItem)
    -- end

    -- ### 显示 ### --
    self:ActiveComponent()
end

function ElvenTreeBattleResultWinNode:Close()
    -- ### 隐藏 ### --
    self:InactiveComponent()

    -- TODO : 删除
end

return ElvenTreeBattleResultWinNode