--
-- User: fenghao
-- Date: 29/06/2017
-- Time: 11:20 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local ChallengeBattleResultWinNode = Class(BaseNodeClass)

local utility = require "Utils.Utility"

local function InitControls(self)
    local transform = self:GetUnityTransform()

    -- Layout
    self.Layout = transform:Find('ItemLayout/Viewport/Content')

end

function ChallengeBattleResultWinNode:Ctor(transform)
    print(">>>>>>>>>>>>>>>>  is me ****** ")
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function ChallengeBattleResultWinNode:OnResume()
end

function ChallengeBattleResultWinNode:OnPause()
end

-- TODO: 暂时定为FBResponse
function ChallengeBattleResultWinNode:Show(msg)
    -- -- # 等级
    print("+++++++++++++++++++++++    ",#msg.awards,msg.awards,msg.systemID,msg.success,msg.fbID,msg.fbID,msg.fbID)
    local color
    for i = 1, #msg.awards do
        color=nil
        if msg.awards[i].itemColor ~=0 then
            color=msg.awards[i].itemColor
        end
    print(msg.awards[i].itemID,msg.awards[i].itemNum,msg.awards[i].itemColor)
    local item = require 'GUI.Challenge.ChallengeGeneralItem'.New(self.Layout,msg.awards[i].itemID,msg.awards[i].itemNum,color)
    --     local awardItem = fbMsg.items[i]
    --     local newItem = GeneralItemClass.New(self.itemLayoutContentTrans, awardItem.itemID, awardItem.iSStemNum, awardItem.itemColor)
     self:AddChild(item)
    end


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

function ChallengeBattleResultWinNode:Close()
    -- ### 隐藏 ### --
    self:InactiveComponent()

    -- TODO : 删除
end

return ChallengeBattleResultWinNode