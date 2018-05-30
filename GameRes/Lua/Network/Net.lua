local net = {}

-- request
-----------------------------------------------------------------------
--- 请求协议
-----------------------------------------------------------------------
net.C2SLoginRequest = require "Network.PB.C2SLoginRequest".C2SLoginRequest  -- # 登录
net.C2SChoosePlayerRequest = require "Network.PB.C2SChoosePlayerRequest".ChoosePlayerRequest -- # 选择初始卡牌
net.C2SCardBagQueryRequest = require "Network.PB.C2SCardBagQueryRequest".CardBagQueryRequest -- # 卡包数据查询
net.C2SPutOnZhenrongRequest = require "Network.PB.C2SPutOnZhenrongRequest".PutOnZhenrongRequest -- # 上阵
net.C2SPutOffZhenrongRequest = require "Network.PB.C2SPutOffZhenrongRequest".PutOffZhenrongRequest -- # 下阵
net.C2SFBQueryAllMapRequest = require "Network.PB.C2SFBQueryAllMapRequest".FBQueryAllMapRequest  -- # 查询所有副本

net.C2SActionRecordRequest = require "Network.PB.C2SActionRecordRequest".ClientActionRecordRequestMessage -- # 记录行为

net.C2SFBDrawCompleteAwardRequest = require "Network.PB.C2SFBDrawCompleteAwardRequest".FBDrawCompleteAwardRequest -- # 请求奖励
net.C2SFBBuyChallengeRequest = require "Network.PB.C2SFBBuyChallengeRequest".FBBuyChallengeRequest -- # 购买挑战次数

net.C2STarotQueryRequest = require "Network.PB.C2STarotQueryRequest".TarotQueryRequest -- # 塔罗牌数据请求
net.C2STarotCardActiveRequest = require "Network.PB.C2STarotCardActiveRequest".TarotCardActiveRequest -- # 塔罗牌激活请求
net.C2STarotProgressActiveRequest = require "Network.PB.C2STarotProgressActiveRequest".TarotProgressActiveRequest -- # 进度光环激活

net.C2SQuitGameRequest = require "Network.PB.C2SQuitGameRequest".QuitGameRequest   -- # 退出
net.C2SLoadPlayerRequest = require "Network.PB.C2SLoadPlayerRequest".LoadPlayerRequest
net.C2SChoukaQueryRequest = require "Network.PB.C2SChoukaQueryRequest".ChoukaQueryRequest  -- # 抽卡请求
net.C2SChoukaDaojuChooseRequest = require "Network.PB.C2SChoukaDaojuChooseRequest".ChoukaDaojuChooseRequest -- # 道具抽卡请求
net.C2SPing = require "Network.PB.C2SPing".PingMessage  -- ## 心跳包
net.C2STalkQueryRequest = require "Network.PB.C2STalkQueryRequest".TalkQueryRequest  -- # 聊天请求
net.C2STalkRequest = require "Network.PB.C2STalkRequest".TalkRequest  -- # 发送聊天请求
net.C2SFBSweepRequest = require "Network.PB.C2SFBSweepRequest".FBSweepRequest -- # 扫荡请求
net.C2SChangePlayerNameRequest = require "Network.PB.C2SChangePlayerNameRequest".ChangePlayerNameRequest -- #修改名字请求
net.C2SItemBagQueryRequest = require "Network.PB.C2SItemBagQueryRequest".ItemBagQueryRequest --# 背包道具查询请求
net.C2SEquipBagQueryRequest = require "Network.PB.C2SEquipBagQueryRequest".EquipBagQueryRequest -- # 背包装备查询请求
net.C2SEquipSuipianBagQueryRequest = require "Network.PB.C2SEquipSuipianBagQueryRequest".EquipSuipianBagQueryRequest -- # 碎片查询请求
net.C2SChoukaDiamondChooseRequest = require "Network.PB.C2SChoukaDiamondChooseRequest".ChoukaDiamondChooseRequest  --# 钻石抽卡一次请求
net.C2SChoukaDiamondChooseTenRequest = require "Network.PB.C2SChoukaDiamondChooseTenRequest".ChoukaDiamondChooseTenRequest  -- # 钻石抽卡十次请求
net.C2SCardProRequest = require"Network.PB.C2SCardProRequest".CardProRequest --#卡牌升级请求
net.C2SMailDelRequest = require"Network.PB.C2SMailDelRequest".MailDelRequest  -- # 删除邮件请求
net.C2SMailDrawRequest = require"Network.PB.C2SMailDrawRequest".MailDrawRequest  -- # ----领取附件请求
net.C2SMailRequest = require"Network.PB.C2SMailRequest".MailRequest  -- # ----邮件请求
net.C2SMailSetReadRequest = require"Network.PB.C2SMailSetReadRequest".MailSetReadRequest  -- # ----设置邮件已读
net.C2SMailDrawAllRequest = require "Network.PB.C2SMailDrawAllRequest".MailDrawAllRequest   --- # 邮件一键领取请求
net.C2STalkAddToBlackRequest = require "Network.PB.C2STalkAddToBlackRequest".TalkAddToBlackRequest  -- #好友 加入黑名单请求
net.C2STalkBlackQueryRequest = require "Network.PB.C2STalkBlackQueryRequest".TalkBlackQueryRequest -- 黑名单请求
net.C2STalkDismissFromBlackRequest = require "Network.PB.C2STalkDismissFromBlackRequest".TalkDismissFromBlackRequest -- 移除黑名单请求

net.C2SShopBuyRequest = require "Network.PB.C2SShopBuyRequest".ShopBuyRequest -- # 商店购买请求
net.C2SShopFlushRequest = require "Network.PB.C2SShopFlushRequest".ShopFlushRequest  -- #商店刷新请求
net.C2SShopQueryRequest = require "Network.PB.C2SShopQueryRequest".ShopQueryRequest  -- # 商店Query请求
net.C2SShopHeishiQueryRequest = require "Network.PB.C2SShopHeishiQueryRequest".ShopHeishiQueryRequest  --# 黑市Query请求
net.C2SShopHeishiForEverRequest = require "Network.PB.C2SShopHeishiForEverRequest".ShopHeishiForEverRequest --# 黑市永久开启请求

net.C2SUseAllTreasureRequest = require "Network.PB.C2SUseAllTreasureRequest".UseAllTreasureRequest -- # 抽卡一键开启寻宝令请求
net.C2SEquipSellRequest = require "Network.PB.C2SEquipSellRequest".EquipSellRequest -- # 出售装备请求
net.C2SCardSuipianBagQueryRequest = require "Network.PB.C2SCardSuipianBagQueryRequest".CardSuipianBagQueryRequest  -- # 卡牌碎片背包请求
net.C2SRobQueryRequest = require "Network.PB.C2SRobQueryRequest".RobQueryRequest -- # 抢夺robQurry 请求
net.C2SFriendsQueryRequest = require "Network.PB.C2SFriendsQueryRequest".FriendsQueryRequestMessage  -- # 好友Query请求
net.C2SFriendsAddRequest = require "Network.PB.C2SFriendsAddRequest".FriendsAddRequest   --- # 添加好友请求
net.C2SFriendsApplyListRequest = require "Network.PB.C2SFriendsApplyListRequest".FriendsApplyListRequestMessage  -- # 好友申请列表请求
net.C2SFriendsDealRequest = require "Network.PB.C2SFriendsDealRequest".FriendsDealRequestMessage  --- # 好友处理请求
net.C2SFriendSearchRequest = require "Network.PB.C2SFriendSearchRequest".FriendSearchRequest   --- # 好友查询请求
net.C2SFriendTiliDrawRequest = require "Network.PB.C2SFriendTiliDrawRequest".FriendTiliDrawRequest   --- # 好友体力领取请求
net.C2SFriendTiliQueryRequest = require "Network.PB.C2SFriendTiliQueryRequest".FriendTiliQueryRequest  --- # 好友体力领取列表请求
net.C2SFriendTiliSendRequest = require "Network.PB.C2SFriendTiliSendRequest".FriendTiliSendRequest   --- # 好友赠送体力请求
net.C2SFriendsDelRequest = require "Network.PB.C2SFriendsDelRequest".FriendsDelRequestMessage   --- # 删除好友请求
net.C2SFriendsViewListRequest = require "Network.PB.C2SFriendsViewListRequest".FriendsViewListRequestMessage  --- # 添加好友列表请求
net.C2SItemBagSellRequest  = require "Network.PB.C2SItemBagSellRequest".ItemBagSellRequest  -- # item背包Sell 请求

net.C2SGuideRedRequest = require "Network.PB.C2SGuideRedRequest".GuideRedRequest -- # 红点 指引请求
net.C2SGuideStateRequest = require "Network.PB.C2SGuideStateRequest".GuideStateRequest	-- # 新手引导请求
net.C2SGuideDoneRequest = require "Network.PB.C2SGuideDoneRequest".GuideDoneRequest	-- # 新手引导完成请求

net.C2SChooseHeadImageRequest = require "Network.PB.C2SChooseHeadImageRequest".ChooseHeadImageRequest -- # 用户头像 请求
net.C2SExchangeCodeRequest = require "Network.PB.C2SExchangeCodeRequest".ExchangeCodeRequest -- 兑换码请求
net.C2SGuideGonggaoRequest = require "Network.PB.C2SGuideGonggaoRequest".GuideGonggaoRequest -- # 公告弹窗请求
net.C2SCardSuipianBuildRequest = require "Network.PB.C2SCardSuipianBuildRequest".CardSuipianBuildRequest -- #  卡牌碎片合成请求
net.C2SArenaQueryRequest = require "Network.PB.C2SArenaQueryRequest".ArenaQueryRequest  -- # 竞技场Query请求
net.C2SArenaTop50QueryRequest  = require "Network.PB.C2SArenaTop50QueryRequest".ArenaTop50QueryRequest -- # 竞技场top 50请求
net.C2SPlayerSimpleInfoQueryRequest = require "Network.PB.C2SPlayerSimpleInfoQueryRequest".PlayerSimpleInfoQueryRequest  --# 根据UId查询玩家信息请求
net.C2SArenaBuyChallengeRequest = require "Network.PB.C2SArenaBuyChallengeRequest".ArenaBuyChallengeRequest  -- # 竞技场购买挑战次数
net.C2SArenaClearCDRequest = require "Network.PB.C2SArenaClearCDRequest".ArenaClearCDRequest  -- # 竞技场清空CD请求
net.C2SCardGradeUpRequest = require "Network.PB.C2SCardGradeUpRequest".CardGradeUpRequest  -- # 卡牌升品请求
net.C2SCardStageUpRequest = require "Network.PB.C2SCardStageUpRequest".CardStageUpRequest  -- # 卡牌进阶请求
net.C2SCardBreakRequest = require "Network.PB.C2SCardBreakRequest".CardBreakRequestMessage -- # 卡牌突破请求
net.C2SDailySignInQueryRequest  = require "Network.PB.C2SDailySignInQueryRequest".DailySignInQueryRequest -- # 签到记录信息请求
net.C2SDailySignInDrawRequest  = require "Network.PB.C2SDailySignInDrawRequest".DailySignInDrawRequest -- # 签到信息请求
net.C2SOnlineAwardQueryRequest = require "Network.PB.C2SOnlineAwardQueryRequest".OnlineAwardQueryRequest -- # 新手任务查询请求
net.C2SOnlineAwardDrawRequest = require "Network.PB.C2SOnlineAwardDrawRequest".OnlineAwardDrawRequest -- # 新手任务领取请求
net.C2SRobOpenBoxRequest= require "Network.PB.C2SRobOpenBoxRequest".RobOpenBoxRequest -- # 精灵树中物品领取请求
net.C2STakeBoxInProtectedRequest = require "Network.PB.C2STakeBoxInProtectedRequest".TakeBoxInProtectedRequest -- # 请求保护
net.C2SProtectQueryRequest = require "Network.PB.C2SProtectQueryRequest".ProtectQueryRequest -- # 保护公主查询
net.C2SProtectCheckEnemyRequest = require "Network.PB.C2SProtectCheckEnemyRequest".ProtectCheckEnemyRequest -- # 保护公主 查询敌人
net.C2SProtectResetRequest = require "Network.PB.C2SProtectResetRequest".ProtectResetRequest -- # 保护公主重置
net.C2SProtectDrawAwardRequest = require "Network.PB.C2SProtectDrawAwardRequest".ProtectDrawAwardRequest -- # 打开保护公主里的箱子
net.C2SCardTalentResetRequest = require "Network.PB.C2SCardTalentResetRequest".CardTalentResetRequest -- # 重置天赋
net.C2SCardTalentChooseRequest = require "Network.PB.C2SCardTalentChooseRequest".CardTalentChooseRequest -- # 天赋选择
net.C2SEquipLevelUpRequest = require "Network.PB.C2SEquipLevelUpRequest".EquipLevelUpRequest  -- # 装备升级请求
net.C2SEquipSuipianComposeRequest = require "Network.PB.C2SEquipSuipianComposeRequest".EquipSuipianComposeRequest  -- # 装备碎片合成请求
net.C2SEquipSuipianSellRequest = require "Network.PB.C2SEquipSuipianSellRequest".EquipSuipianSellRequest  -- #装备出售请求
net.C2SEquipAutoLevelUpRequest = require "Network.PB.C2SEquipAutoLevelUpRequest".EquipAutoLevelUpRequest -- # 装备自动强化请求
net.C2SStoneComposeRequest = require "Network.PB.C2SStoneComposeRequest".StoneComposeRequest  -- # 宝石合成请求
net.C2SStoneQueryRequest = require "Network.PB.C2SStoneQueryRequest".StoneQueryRequest   -- # 宝石合成Query请求
net.C2SStoneToEquipRequest = require "Network.PB.C2SStoneToEquipRequest".StoneToEquipRequest  -- # 镶嵌宝石请求
net.C2SStoneRemoveRequest = require "Network.PB.C2SStoneRemoveRequest".StoneRemoveRequest  -- # 拆除宝石请求
net.C2SChengjiuDrawRequest = require "Network.PB.C2SChengjiuDrawRequest".ChengjiuDrawRequest  -- # 领取成就
net.C2SChengjiuQueryRequest = require "Network.PB.C2SChengjiuQueryRequest".ChengjiuQueryRequest  -- # 成就Query请求
net.TuJianDrawRequestMessage = require "Network.PB.TuJianDrawRequestMessage".TuJianDrawRequestMessage  -- # 领取图鉴
net.TuJianQueryRequestMessage = require "Network.PB.TuJianQueryRequestMessage".TuJianQueryRequestMessage  -- # 图鉴Query请求
net.C2STaskQueryRequest = require "Network.PB.C2STaskQueryRequest".TaskQueryRequest  -- # 任务Query请求
net.C2STaskDrawRequest = require "Network.PB.C2STaskDrawRequest".TaskDrawRequest  -- # 任务领取请求
net.C2SZhenrongInnerChangeRequest = require "Network.PB.C2SZhenrongInnerChangeRequest".ZhenrongInnerChangeRequest  -- # 交换阵容
net.C2SEquipDismissBindRequest = require "Network.PB.C2SEquipDismissBindRequest".EquipDismissBindRequest  --- # 解除装备绑定
net.C2SFashionLevelUpRequest = require "Network.PB.C2SFashionLevelUpRequest".FashionLevelUpRequest   --- # 时装升级
net.C2SVipBuyTiliCoin = require "Network.PB.C2SVipBuyTiliCoin".VipBuyTiliCoin  --- # 购买金币体力请求
net.C2SArenaMilestoneAwardRequest = require "Network.PB.C2SArenaMilestoneAwardRequest".ArenaMilestoneAwardRequest  --- # 竞技场里程碑领取请求
net.C2SArenaMilestoneQueryRequest = require "Network.PB.C2SArenaMilestoneQueryRequest".ArenaMilestoneQueryRequest  --- # 竞技场里程碑query请求
net.C2SCheckPlayerCardWithEquipRequest = require "Network.PB.C2SCheckPlayerCardWithEquipRequest".CheckPlayerCardWithEquipRequest   --- # 查看卡牌装备请求
net.C2SArenaHistoryRequest = require "Network.PB.C2SArenaHistoryRequest".ArenaHistoryRequest   --- # 竞技场战报请求
net.C2SFightHistoryQuery = require "Network.PB.C2SFightHistoryQuery".FightHistoryQuery   --- # 历史战斗Query请求
net.C2SFightSignOutQueryRequest = require "Network.PB.C2SFightSignOutQueryRequest".FightSignOutQueryRequest   --- # 战斗退出请求
net.C2SEquipChibangBuildRequest = require "Network.PB.C2SEquipChibangBuildRequest".EquipChibangBuildRequest   --- # 翅膀合成
net.C2SEquipBeishiLevelUpRequest = require "Network.PB.C2SEquipBeishiLevelUpRequest".EquipBeishiLevelUpRequest  --- # 翅膀升级
net.C2SEquipChibangColorUpRequest = require "Network.PB.C2SEquipChibangColorUpRequest".EquipChibangColorUpRequest   --- # 翅膀强化
net.C2SProtectGyjQueryRequest = require "Network.PB.C2SProtectGyjQueryRequest".ProtectGyjQueryRequest   --- # 雇佣军Query
net.C2SProtectUseGyjRequest = require "Network.PB.C2SProtectUseGyjRequest".ProtectUseGyjRequest   --- # 使用雇佣军请求
net.C2SZhenrongAdjustRequest = require "Network.PB.C2SZhenrongAdjustRequest".ZhenrongAdjustRequest    --- # 雇佣军操作
net.C2SArenaRefreshRequestMessage = require "Network.PB.C2SArenaRefreshRequestMessage".ArenaRefreshRequestMessage   --- # 竞技场刷新请求
net.C2SCardSkinBagQueryRequest = require "Network.PB.C2SCardSkinBagQueryRequest".CardSkinBagQueryRequestMessage  -- # 卡牌皮肤背包查询请求
net.C2SCardSkinPutOffRequest = require "Network.PB.C2SCardSkinPutOffRequest".CardSkinPutOffRequestMessage   --- # 卡牌皮肤卸下请求
net.C2SCardSkinPutOnRequest = require "Network.PB.C2SCardSkinPutOnRequest".CardSkinPutOnRequestMessage   --- # 卡牌皮肤穿上请求
net.C2SCardCorrCardSkinInfoQueryRequest = require "Network.PB.C2SCardCorrCardSkinInfoQueryRequest".CardCorrCardSkinInfoQueryRequestMessage   --- # 卡牌皮肤请求
net.C2SCardSkinActivationRequest = require "Network.PB.C2SCardSkinActivationRequest".CardSkinActivationRequestMessage   --- # 卡牌皮肤激活请求
net.C2SCardSkinUpgradeRequest = require "Network.PB.C2SCardSkinUpgradeRequest".CardSkinUpgradeRequestMessage   --- # 卡牌皮肤升级请求

net.C2SEquipAdvancedRequest = require "Network.PB.C2SEquipAdvancedRequest".EquipAdvancedRequestMessage   --- # 装备进阶
---- ### 战斗相关 ### ----
net.C2SBossFightRequest = require "Network.PB.C2SBossFightRequest".BossFightRequest -- Boss
net.C2SExploreStartFightRequest = require "Network.PB.C2SExploreStartFightRequest".ExploreStartFightRequest -- 探索战斗
net.C2SFBStartFightRequest = require "Network.PB.C2SFBStartFightRequest".FBStartFightRequest -- # 请求开始战斗
net.C2SGHFbStartFightRequest = require "Network.PB.C2SGHFbStartFightRequest".GHFbStartFightRequest -- 工会副本战斗
net.C2SProtectStartFightRequest = require "Network.PB.C2SProtectStartFightRequest".ProtectStartFightRequest -- 保护公主战斗
net.C2SRobFightRequest = require "Network.PB.C2SRobFightRequest".RobFightRequest -- 抢夺战斗
net.C2STowerFightRequest = require "Network.PB.C2STowerFightRequest".TowerFightRequest  -- 爬塔战斗
net.C2SWorldBossFightRequest = require "Network.PB.C2SWorldBossFightRequest".WorldBossFightRequest -- 世界BOSS
net.C2SArenaStartFightRequest = require "Network.PB.C2SArenaStartFightRequest".ArenaQueryRequest  -- # 竞技场战斗请求
net.C2SRobZhanbaoRequest = require "Network.PB.C2SRobZhanbaoRequest".RobZhanbaoRequest --精灵树战报

net.C2SEquipPutOnRequest = require "Network.PB.C2SEquipPutOnRequest".EquipPutOnRequest -- #装备装备
net.C2SEquipPutOffRequest = require "Network.PB.C2SEquipPutOffRequest".EquipPutOffRequest  -- #卸下装备
net.C2SOpenTreasureChestRewardRequest = require "Network.PB.C2SOpenTreasureChestRewardRequest".OpenTreasureChestRewardRequestMessage  -- #装备宝箱使用

---探险相关协议
net.C2SExploreQueryRequest = require "Network.PB.C2SExploreQueryRequest".ExploreQueryRequest -- # 探索请求
net.C2SExploreMapQueryRequest = require "Network.PB.C2SExploreMapQueryRequest".ExploreMapQueryRequest -- # 探索地图查询
net.C2SExploreFightOverRequest = require "Network.PB.C2SExploreFightOverRequest".ExploreFightOverRequest -- # 探索战斗请求
--军团相关协议
net.C2SGHAddGuyongjunRequest = require "Network.PB.C2SGHAddGuyongjunRequest".GHAddGuyongjunRequest
net.C2SGHCheckInRequest = require "Network.PB.C2SGHCheckInRequest".GHCheckInRequest
net.C2SGHCreateRequest = require "Network.PB.C2SGHCreateRequest".GHCreateRequest
net.C2SGHDelGuyongjunRequest = require "Network.PB.C2SGHDelGuyongjunRequest".GHDelGuyongjunRequest
net.C2SGHDismissRequest = require "Network.PB.C2SGHDismissRequest".GHDismissRequest
net.C2SGHHandleApplyRequest = require "Network.PB.C2SGHHandleApplyRequest".GHHandleApplyRequest
net.C2SGHJoinRequest = require "Network.PB.C2SGHJoinRequest".GHJoinRequest
net.C2SGHManagerMemRequest = require "Network.PB.C2SGHManagerMemRequest".GHManagerMemRequest
net.C2SGHQieCuoRequest = require "Network.PB.C2SGHQieCuoRequest".GHQieCuoRequest
net.C2SGHQueryApplyRequest = require "Network.PB.C2SGHQueryApplyRequest".GHQueryApplyRequest
net.C2SGHQueryGuyongjunRequest = require "Network.PB.C2SGHQueryGuyongjunRequest".GHQueryGuyongjunRequest
net.C2SGHQueryRequest = require "Network.PB.C2SGHQueryRequest".GHQueryRequest
net.C2SGHQuitRequest = require "Network.PB.C2SGHQuitRequest".GHQuitRequest
net.C2SGHRankRequest = require "Network.PB.C2SGHRankRequest".GHRankRequest
net.C2SGHRecordRequest = require "Network.PB.C2SGHRecordRequest".GHRecordRequest
net.C2SGHSearchRequest = require "Network.PB.C2SGHSearchRequest".GHSearchRequest
net.C2SGHSetLogoRequest = require "Network.PB.C2SGHSetLogoRequest".GHSetLogoRequest
net.C2SGHSetShowMsgRequest = require "Network.PB.C2SGHSetShowMsgRequest".GHSetShowMsgRequest
net.C2SGHUpdateRequestMessage = require "Network.PB.C2SGHUpdateRequestMessage".GHUpdateRequest

--公会积分战相关协议
net.C2SGHPointQueryRequest = require "Network.PB.C2SGHPointQueryRequest".GHPointQueryRequest
net.C2SGHPointGroupRequest = require "Network.PB.C2SGHPointGroupRequest".GHPointGroupRequest
net.C2SGHPointBuyChallengeRequest = require "Network.PB.C2SGHPointBuyChallengeRequest".GHPointBuyChallengeRequest
net.C2SGHPointClearCDRequest = require "Network.PB.C2SGHPointClearCDRequest".GHPointClearCDRequest
net.C2SGHPointStartFightRequest = require "Network.PB.C2SGHPointStartFightRequest".GHPointStartFightRequest
net.C2SGHPointHistoryRequest = require "Network.PB.C2SGHPointHistoryRequest".GHPointHistoryRequest
net.C2SGHPointMilestoneAwardRequest = require "Network.PB.C2SGHPointMilestoneAwardRequest".GHPointMilestoneAwardRequest
net.C2SGHPointMilestoneQueryRequest = require "Network.PB.C2SGHPointMilestoneQueryRequest".GHPointMilestoneQueryRequest
net.C2SGHPointTop50QueryRequest = require "Network.PB.C2SGHPointTop50QueryRequest".GHPointTop50QueryRequest

--爬塔相关协议
net.C2SAddAttributeRequest = require "Network.PB.C2SAddAttributeRequest".AddAttributeRequest
net.C2SAttributeQueryRequest = require "Network.PB.C2SAttributeQueryRequest".AttributeQueryRequest
net.C2STowerQueryRequest = require "Network.PB.C2STowerQueryRequest".TowerQueryRequest
net.C2STowerRankQueryRequest = require "Network.PB.C2STowerRankQueryRequest".TowerRankQueryRequest
net.C2STowerResetRequest = require "Network.PB.C2STowerResetRequest".TowerResetRequest
net.C2STowerSweepRequest = require "Network.PB.C2STowerSweepRequest".TowerSweepRequest
net.C2SBossQueryRequest = require "Network.PB.C2SBossQueryRequest".BossQueryRequestMessage
net.C2SBuyBossResetCountRequest = require "Network.PB.C2SBuyBossResetCountRequest".BuyBossResetCountRequestMessage
net.C2SBuyRequest = require "Network.PB.C2SBuyRequest".BuyRequest

net.C2SPetAdvancedRequest = require "Network.PB.C2SPetAdvancedRequest".PetAdvancedRequest
net.C2SPetLevelUpRequest = require "Network.PB.C2SPetLevelUpRequest".PetLevelUpRequest


--活动相关协议
net.ActivityQueryRequest = require "Network.PB.ActivityQueryRequest".ActivityQueryRequestMessage
net.ActivityListQueryRequest = require "Network.PB.ActivityListQueryRequest".ActivityListQueryRequestMessage
net.ActivityGetAwardRequest = require "Network.PB.ActivityGetAwardRequest".ActivityGetAwardRequestMessage
net.C2SActivitySevenDayHappyRequest = require "Network.PB.C2SActivitySevenDayHappyRequest".ActivitySevenDayHappyRequestMessage
net.C2SActivitySevenDayAwardRequest = require "Network.PB.C2SActivitySevenDayAwardRequest".ActivitySevenDayAwardRequestMessage
net.C2SZhaoCaiCatActivityChouJiangRequest = require "Network.PB.C2SZhaoCaiCatActivityChouJiangRequest".ZhaoCaiCatActivityChouJiangRequestMessage
net.C2SZhaoCaiCatActivityQueryRequest = require "Network.PB.C2SZhaoCaiCatActivityQueryRequest".ZhaoCaiCatActivityQueryRequestMessage
net.C2SConRecActivityAwaQueryRequest = require "Network.PB.C2SConRecActivityAwaQueryRequest".ConRecActivityAwaQueryRequestMessage
net.C2SConRecActivityQueryRequest = require "Network.PB.C2SConRecActivityQueryRequest".ConRecActivityQueryRequestMessage
net.C2SSinglContiRecharActivityAwaQueryRequest = require "Network.PB.C2SSinglContiRecharActivityAwaQueryRequest".SinglContiRecharActivityAwaQueryRequestMessage
net.C2SSinglContiRecharActivityQueryRequest = require "Network.PB.C2SSinglContiRecharActivityQueryRequest".SinglContiRecharActivityQueryRequestMessage
net.C2SDailyRechargeActivityAwardQueryRequest = require "Network.PB.C2SDailyRechargeActivityAwardQueryRequest".DailyRechargeActivityAwardQueryRequestMessage
net.C2SDailyRechargeActivityQueryRequest = require "Network.PB.C2SDailyRechargeActivityQueryRequest".DailyRechargeActivityQueryRequestMessage
net.C2SHappyTurnMusicRequest = require "Network.PB.C2SHappyTurnMusicRequest".HappyTurnMusicRequestMessage
net.C2SHappyTurnMusicQueryRequest = require "Network.PB.C2SHappyTurnMusicQueryRequest".HappyTurnMusicQueryRequestMessage

net.C2SOperationActivityQueryRequest = require "Network.PB.OperationActivityNetMessage".OperationActivityQueryRequestMessage
net.C2SOperationActivityPickItemRequest = require "Network.PB.OperationActivityNetMessage".OperationActivityPickItemRequestMessage

--Vip相关协议
net.C2SVipChargeQuery = require "Network.PB.C2SVipChargeQuery".VipChargeQuery
net.C2SVipDiamondLibaoBuyRequest = require "Network.PB.C2SVipDiamondLibaoBuyRequest".VipDiamondLibaoBuyRequest

net.C2SVipChongZhiQueryRequest = require "Network.PB.C2SVipChongZhiQueryRequest".VipChongZhiQueryRequest



net.C2SWorldBossTotalRequest=require "Network.PB.C2SWorldBossTotalRequest".WorldBossTotalRequestMessage
net.C2SWorldBossQueryRequest=require "Network.PB.C2SWorldBossQueryRequest".WorldBossQueryRequestMessage
net.C2SWBossListRequest=require "Network.PB.C2SWBossListRequest".WBossListRequestMessage
net.C2SWBossSharerRequest=require "Network.PB.C2SWBossSharerRequest".WBossSharerRequestMessage
net.C2SWBossFightStartRequest=require "Network.PB.C2SWBossFightStartRequest".WBossFightStartRequestMessage
net.C2SBuyWBossKeyRequest=require "Network.PB.C2SBuyWBossKeyRequest".BuyWBossKeyRequestMessage
net.C2SBuyThreefoldKeyRequest=require "Network.PB.C2SBuyThreefoldKeyRequest".BuyThreefoldKeyRequestMessage
net.C2SWBossFightEndRequest=require "Network.PB.C2SWBossFightEndRequest".WBossFightEndRequestMessage




net.C2SBuyAdventureTimesRequestMessage=require "Network.PB.C2SBuyAdventureTimesRequestMessage".BuyAdventureTimesRequestMessage


net.C2SStartAdventureRequestMessage=require "Network.PB.C2SStartAdventureRequestMessage".StartAdventureRequestMessage


net.C2SAdvanceAdventureRequestMessage=require "Network.PB.C2SAdvanceAdventureRequestMessage".AdvanceAdventureRequestMessage

--体力回复
net.C2STiliCountDownRequest=require "Network.PB.C2STiliCountDownRequest".TiliCountDownRequestMessage


--是否是首次改名
net.C2SWhetherTheFirstRenameRequest=require "Network.PB.C2SWhetherTheFirstRenameRequest".WhetherTheFirstRenameRequestMessage


--流派
net.C2SGenreQueryRequest=require "Network.PB.C2SGenreQueryRequest".GenreQueryRequestMessage

--流派达成
net.C2SGenreChangeStateRequest=require "Network.PB.C2SGenreChangeStateRequest".GenreChangeStateRequest

--限时神降一次抽
net.C2SGodChooseOneRequet=require "Network.PB.C2SGodChooseOneRequet".GodChooseOneRequet
--限时神降10次抽
net.C2SGodChooseTenRequest=require "Network.PB.C2SGodChooseTenRequest".GodChooseTenRequest
--限时神降请求
net.ActivityGodComingRequest=require "Network.PB.ActivityGodComingRequest".ActivityGodComingRequestMessage
--精灵树升级
net.C2SRobTreeLevelUpRequest=require "Network.PB.C2SRobTreeLevelUpRequest".RobTreeLevelUpRequest
--精灵树秒蛋
net.C2STakeBoxSecondKillRequest=require "Network.PB.C2STakeBoxSecondKillRequest".RobBoxSecondKillRequest
--精灵树秒蛋信息
net.C2STakeBoxSecondKillInfoRequest=require "Network.PB.C2STakeBoxSecondKillInfoRequest".RobBoxSecondKillInfoRequest
--精灵树购买抢夺次数信息
net.C2SRobBuyTimesRequest=require "Network.PB.C2SRobBuyTimesRequest".RobBuyTimesRequestMessage
--团队天赋
net.C2SCardTeamTalentChooseRequest=require "Network.PB.C2SCardTeamTalentChooseRequest".CardTalentChooseRequest
--限时兑换请求
net.ActivityTimeLimitRefreshRequest=require "Network.PB.ActivityTimeLimitRefreshRequest".ActivityTimeLimitRefreshRequestMessage

-----------------------------------------------------------------------
--- response 协议
-----------------------------------------------------------------------
net.S2CLoginResult = require "Network.PB.S2CLoginResult".S2CLoginResult
net.S2CChoosePlayerResult = require "Network.PB.S2CChoosePlayerResult".ChoosePlayerResult
net.S2CPlayerLevelUpResult = require "Network.PB.S2CPlayerLevelUpResult".PlayerLevelUpResult -- 玩家升级
net.S2CCardBagQueryResult = require "Network.PB.S2CCardBagQueryResult".CardBagQueryResult   -- 卡包数据 response
net.S2CPutOnZhenrongResult = require "Network.PB.S2CPutOnZhenrongResult".PutOnZhenrongResult -- 上阵 response
net.S2CPutOffZhenrongResult = require "Network.PB.S2CPutOffZhenrongResult".PutOffZhenrongResult -- 下阵 response
net.S2CCardBagFlush = require "Network.PB.S2CCardBagFlush".S2CCardBagFlush  -- 卡包更新
net.S2CFBQueryAllMapResult = require "Network.PB.S2CFBQueryAllMapResult".FBQueryAllMapResult -- 查询副本结果
net.S2CFBDrawCompleteAwardResult = require "Network.PB.S2CFBDrawCompleteAwardResult".FBDrawCompleteAwardResult -- 领取奖励结果
net.S2CFBBuyChallengeResult = require "Network.PB.S2CFBBuyChallengeResult".FBBuyChallengeResult -- # 购买挑战次数
net.S2CLoadPlayerResult = require "Network.PB.S2CLoadPlayerResult".LoadPlayerResult
net.S2CGameRewardResult = require "Network.PB.S2CGameReward".GameRewardMessage
net.S2CGameItemPurchaseResult = require "Network.PB.S2CGameItemPurchase".GameItemPurchaseMessage
net.S2CPingResult = require "Network.PB.S2CPingResult".PingResult -- ## 心跳包 response
net.S2CTalkQueryResult = require "Network.PB.S2CTalkQueryResult".TalkQueryResult   -- # 聊天请求结果
net.S2CTalkResultResult = require "Network.PB.S2CTalkResult".TalkResult  --  # 发送聊天请求结果
net.S2CChoukaQueryResult = require "Network.PB.S2CChoukaQueryResult".ChoukaQueryResult  -- # 抽卡请求结果
net.S2CChoukaDaojuChooseResult = require "Network.PB.S2CChoukaDaojuChooseResult".ChoukaDaojuChooseResult -- # 道具抽卡结果
net.S2CFBSweepResult = require "Network.PB.S2CFBSweepResult".FBSweepResult  -- # 扫荡结果
net.S2CChangePlayerNameResult = require "Network.PB.S2CChangePlayerNameResult".ChangePlayerNameResult -- # 修改名字请求结果
net.S2CItemBagQueryResult = require "Network.PB.S2CItemBagQueryResult".ItemBagQueryResult  -- 背包道具查询请求结果
net.S2CItemBagFlush = require "Network.PB.S2CItemBagFlush".ItemBagFlush -- 背包道具增删改
net.S2CEquipBagQueryResult = require "Network.PB.S2CEquipBagQueryResult".EquipBagQueryResult -- # 装备查询结果
net.S2CChoukaDiamondChooseResult = require "Network.PB.S2CChoukaDiamondChooseResult".ChoukaDiamondChooseResult  --钻石抽卡一次请求结果
net.S2CChoukaDiamondChooseTenResult = require "Network.PB.S2CChoukaDiamondChooseTenResult".ChoukaDiamondChooseTenResult  -- # 钻石抽卡十次请求
net.S2CCardProResult = require"Network.PB.S2CCardProResult".CardProResult -- # 卡牌升级结果
net.S2CMailDelResult = require"Network.PB.S2CMailDelResult".MailDelResult  -- # 删除邮件结果
net.S2CMailPushResult = require"Network.PB.S2CMailPushResult".MailPushResult  -- # ----删除邮件结果
net.S2CMailResult = require"Network.PB.S2CMailResult".MailResult  -- # 邮件结果
net.S2CMailDrawResult = require"Network.PB.S2CMailDrawResult".MailDrawResult  -- # 领取附件结果
net.S2CMailSetReadResult = require"Network.PB.S2CMailSetReadResult".MailSetReadResult  -- # 邮件设置已读结果
net.S2CMailDrawAllResult =  require "Network.PB.S2CMailDrawAllResult".MailDrawAllResult  --- # 一键领取邮件结果
net.S2CShopBuyResult = require "Network.PB.S2CShopBuyResult".ShopBuyResult -- # 商店购买结果
net.S2CShopFlushResult = require "Network.PB.S2CShopFlushResult".ShopFlushResult  --# 商店刷新结果
net.S2CShopQueryResult = require "Network.PB.S2CShopQueryResult".ShopQueryResult  -- # 商店Query结果
net.S2CShopHeishiQueryResult = require "Network.PB.S2CShopHeishiQueryResult".ShopHeishiQueryResult --# 黑市Query结果
net.S2CShopHeishiForEverResult = require "Network.PB.S2CShopHeishiForEverResult".ShopHeishiForEverResult --# 黑市永久开启结果

net.S2CEquipSuipianBagQueryResult = require "Network.PB.S2CEquipSuipianBagQueryResult".EquipSuipianBagQueryResult -- # 碎片查询结果
net.S2CUseAllTreasureResult = require "Network.PB.S2CUseAllTreasureResult".UseAllTreasureResult -- # 抽卡一键开启寻宝令结果

--新手引导相关协议
net.S2CGuideRedResult = require "Network.PB.S2CGuideRedResult".GuideRedResult -- # 红点 引导 结果
net.S2CGuideStateResult = require "Network.PB.S2CGuideStateResult".GuideStateResult
net.S2CGuideDoneResult = require "Network.PB.S2CGuideDoneResult".GuideDoneResult
net.S2CGuideAwardResult = require "Network.PB.S2CGuideAwardResult".GuideDoneAwardResultMessage

net.S2CEquipSellResult = require "Network.PB.S2CEquipSellResult".EquipSellResult -- # 出售装备请求结果
net.S2CCardSuipianBagQueryResult = require "Network.PB.S2CCardSuipianBagQueryResult".CardSuipianBagQueryResult  -- # 卡牌碎片背包查询结果
net.S2CRobQueryResult = require "Network.PB.S2CRobQueryResult".RobQueryResult  -- # 抢夺robQurry 结果
net.S2CFriendsAddResult = require "Network.PB.S2CFriendsAddResult".FriendsAddResultMessage  --- # 添加好友结果
net.S2CFriendsApplyListResult = require "Network.PB.S2CFriendsApplyListResult".FriendsApplyListResultMessage   --- # 好友申请结果列表
net.S2CFriendsDealResult = require "Network.PB.S2CFriendsDealResult".FriendsDealResultMessage   --- # 好友处理结果
net.S2CFriendSearchResult = require "Network.PB.S2CFriendSearchResult".FriendSearchResult   --- # 好友查询结果
net.S2CFriendsQueryResult = require "Network.PB.S2CFriendsQueryResult".FriendsQueryResultMessage  --- # 好友查询结果
net.S2CFriendTiliDrawResult = require "Network.PB.S2CFriendTiliDrawResult".FriendTiliDrawResult   --- # 好友体力领取结果
net.S2CFriendTiliSendResult = require "Network.PB.S2CFriendTiliSendResult".FriendTiliSendResultMessage   --- # 好友体力赠送结果
net.S2CFriendTiliQueryResult = require "Network.PB.S2CFriendTiliQueryResult".S2CFriendTiliQueryResult   --- # 好友体力查询列表结果
net.S2CFriendsDelResult = require "Network.PB.S2CFriendsDelResult".FriendsDelResult   --- # 删除好友结果
net.S2CFriendsViewListResult = require "Network.PB.S2CFriendsViewListResult".FriendsViewListResultMessage   --- 添加好友列表结果
net.S2CFriendsUpdateFlush = require "Network.PB.S2CFriendsUpdateFlush".FriendsUpdateListFlushMessage   --- # 好友列表刷新结果
net.S2CItemBagSellResult = require "Network.PB.S2CItemBagSellResult".ItemBagSellResult   -- # Item 背包Sell 请求结果
net.S2CChooseHeadImageResult = require "Network.PB.S2CChooseHeadImageResult".ChooseHeadImageResult  -- # 用户头像请求结果

net.S2CTalkBlackQueryResult = require "Network.PB.S2CTalkBlackQueryResult".TalkBlackQueryResult --黑名单请求结果
net.S2CTalkDismissFromBlackResult = require "Network.PB.S2CTalkDismissFromBlackResult".TalkDismissFromBlackResult --移除黑名单结果
net.S2CExchangeCodeResult = require "Network.PB.S2CExchangeCodeResult".ExchangeCodeResult -- 兑换码请求结果
net.S2CGuideGonggaoResult = require "Network.PB.S2CGuideGonggaoResult".GuideGonggaoResult  -- 登陆 公告弹窗界面Response
net.S2CCardSuipianFlush = require "Network.PB.S2CCardSuipianFlush".CardSuipianFlush  -- # 英雄碎片包刷新Response
net.S2CCardSuipianBuildResult = require "Network.PB.S2CCardSuipianBuildResult".CardSuipianBuildResult  -- # 英雄碎片合成结果
net.S2CArenaQueryResult = require "Network.PB.S2CArenaQueryResult".ArenaQueryResultMessage   -- # 竞技场Query请求Response
net.S2CArenaTop50QueryResult = require "Network.PB.S2CArenaTop50QueryResult".ArenaTop50QueryResult -- # 竞技场top 50请求Response
net.S2CPlayerSimpleInfoQueryResult = require "Network.PB.S2CPlayerSimpleInfoQueryResult".PlayerSimpleInfoQueryResult  --# 根据UId查询玩家信息请求Response
net.S2CArenaBuyChallengeResult = require "Network.PB.S2CArenaBuyChallengeResult".ArenaBuyChallengeResult  -- # 竞技场购买挑战次数Response
net.S2CArenaClearCDResult = require "Network.PB.S2CArenaClearCDResult".ArenaClearCDResult   -- # 竞技场清空CD请求Response
net.S2CCardGradeUpResult = require "Network.PB.S2CCardGradeUpResult".CardGradeUpResult  -- # 卡牌升品Response
net.S2CCardStageUpResult = require "Network.PB.S2CCardStageUpResult".CardStageUpResult  -- # 卡牌进阶Response
net.S2CCardBreakResult = require "Network.PB.S2CCardBreakResult".CardBreakResultMessage -- # 卡牌突破Response
net.S2CDailySignInQueryResult = require "Network.PB.S2CDailySignInQueryResult".DailySignInQueryResult -- # 请求签到记录信息的返回
net.S2CDailySignInDrawResult = require "Network.PB.S2CDailySignInDrawResult".DailySignInDrawResult -- # 请求签到信息的返回
net.S2CEquipBagFlush = require "Network.PB.S2CEquipBagFlush".EquipBagFlush -- # 装备推送消息
net.S2COnlineAwardDrawResult = require "Network.PB.S2COnlineAwardDrawResult".OnlineAwardDrawResult -- # 新手任务查询结果
net.S2COnlineAwardQueryResult = require "Network.PB.S2COnlineAwardQueryResult".OnlineAwardQueryResult -- # 新手任务领取结果
--net.S2CRobQueryResult= require "Network.PB.S2CRobQueryResult".RobQueryResult -- # 精灵树查询返回结果
net.S2CRobOpenBoxResult= require "Network.PB.S2CRobOpenBoxResult".RobOpenBoxResult -- # 精灵树中物品领取请求
net.S2CTakeBoxInProtectedResult= require "Network.PB.S2CTakeBoxInProtectedResult".TakeBoxInProtectedResult -- # 精灵树中请求保护

net.S2CEquipSuipianBagFlushResult = require "Network.PB.S2CEquipSuipianBagFlushResult".EquipSuipianBagFlushResult  -- # 装备碎片刷新Response


net.S2CProtectQueryResult = require "Network.PB.S2CProtectQueryResult".ProtectQueryResult -- # 保护公主
net.S2CProtectCheckEnemyResult = require "Network.PB.S2CProtectCheckEnemyResult".ProtectCheckEnemyResult -- # 保护公主 查询敌人
net.S2CProtectDrawAwardResult = require "Network.PB.S2CProtectDrawAwardResult".ProtectDrawAwardResult -- # 保卫公主 打开箱子的 回调
net.S2CProtectResetResult = require "Network.PB.S2CProtectResetResult".ProtectResetResult -- # 重置保护公主

net.S2CCardTalentResetResult = require "Network.PB.S2CCardTalentResetResult".CardTalentResetResult  -- # 重置天赋
net.S2CCardTalentChooseResult = require "Network.PB.S2CCardTalentChooseResult".CardTalentChooseResult   --点天赋
net.S2CEquipLevelUpResult = require "Network.PB.S2CEquipLevelUpResult".EquipLevelUpResult  -- # 装备升级结果
net.S2CEquipSuipianComposeResult = require "Network.PB.S2CEquipSuipianComposeResult".EquipSuipianComposeResult -- # 装备碎片合成Response
net.S2CEquipSuipianSellResult = require "Network.PB.S2CEquipSuipianSellResult".EquipSuipianSellResult  -- # 装备碎片出售Response
net.S2CEquipAutoLevelUpResult = require "Network.PB.S2CEquipAutoLevelUpResult".EquipAutoLevelUpResult  -- # 自动强化装备Response
net.S2CStoneComposeResult = require "Network.PB.S2CStoneComposeResult".StoneComposeResult  -- # 宝石合成Response
net.S2CStoneQueryResult = require "Network.PB.S2CStoneQueryResult".StoneQueryResult  -- # 宝石合成Query Response
net.S2CStoneToEquipResult = require "Network.PB.S2CStoneToEquipResult".StoneToEquipResult  -- # 镶嵌宝石Response
net.S2CStoneRemoveResult = require "Network.PB.S2CStoneRemoveResult".StoneRemoveResult  -- # 拆除宝石Response
net.S2CChengjiuDrawResult = require "Network.PB.S2CChengjiuDrawResult".ChengjiuDrawResult  -- # 领取成就Response
net.S2CChengjiuQueryResult = require "Network.PB.S2CChengjiuQueryResult".ChengjiuDrawResult  -- # 成就Query Response
net.TuJianDrawResultMessage = require "Network.PB.TuJianDrawResultMessage".TuJianDrawResultMessage  -- # 领取图鉴
net.TuJianQueryResultMessage = require "Network.PB.TuJianQueryResultMessage".TuJianQueryResultMessage  -- # 图鉴Query
net.S2CTaskQueryResult = require "Network.PB.S2CTaskQueryResult".TaskQueryResult -- # 任务QueryResponse
net.S2CTaskDrawResult = require "Network.PB.S2CTaskDrawResult".TaskDrawResult  -- # 任务领取Response
net.S2CZhenrongInnerChangeResult = require "Network.PB.S2CZhenrongInnerChangeResult".ZhenrongInnerChangeResult -- # 阵容交换Response
net.S2CEquipDismissBindResult = require "Network.PB.S2CEquipDismissBindResult".EquipDismissBindResult   --- # 解除装备绑定Response
net.S2CFashionLevelUpResult = require "Network.PB.S2CFashionLevelUpResult".EquipAutoLevelUpResult   --- # 时装升级Response
net.S2CVipBuyTiliCoinResult = require "Network.PB.S2CVipBuyTiliCoinResult".VipBuyTiliCoinResult   --- # 购买体力金币Response
net.S2CArenaMilestoneAwardResult = require "Network.PB.S2CArenaMilestoneAwardResult".ArenaMilestoneAwardResult   --- # 竞技场里程碑领取奖励Response
net.S2CArenaMilestoneQueryResult = require "Network.PB.S2CArenaMilestoneQueryResult".ArenaMilestoneQueryResult   --- # 竞技场里程碑QueryResponse
net.S2CCheckPlayerCardWithEquipResult = require "Network.PB.S2CCheckPlayerCardWithEquipResult".CheckPlayerCardWithEquipResult   --- # 查看卡牌装备Response
net.S2CFightSignOutQueryResult = require "Network.PB.S2CFightSignOutQueryResult".FightSignOutQueryResult --- # 战斗退出response
net.S2CArenaHistoryResult = require "Network.PB.S2CArenaHistoryResult".ArenaHistoryResult   --- # 竞技场战报Response
net.S2CEquipChibangBuildResult = require "Network.PB.S2CEquipChibangBuildResult".EquipChibangBuildResult    ---- # 翅膀合成Response
net.S2CEquipBeishiLevelUpResult = require "Network.PB.S2CEquipBeishiLevelUpResult".EquipBeishiLevelUpResult   ---- # 翅膀升级Response
net.S2CEquipChibangColorUpResult = require "Network.PB.S2CEquipChibangColorUpResult".EquipChibangColorUpResult   ---- # 翅膀进阶Response
net.S2CProtectGyjQueryResult = require "Network.PB.S2CProtectGyjQueryResult".ProtectGyjQueryResult   --- # 雇佣军QueryResponse
net.S2CProtectUseGyjResult = require "Network.PB.S2CProtectUseGyjResult".ProtectUseGyjResult   --- # 雇佣军使用Response
net.S2CZhenrongAdjustResult = require "Network.PB.S2CZhenrongAdjustResult".ZhenrongAdjustResult   --- # 雇佣军操作Response
net.S2CArenaRefreshResultMessage = require "Network.PB.S2CArenaRefreshResultMessage".ArenaRefreshResultMessage   --- # 竞技场刷新Response
net.S2CCardSkinBagQueryResult = require "Network.PB.S2CCardSkinBagQueryResult".CardSkinBagQueryResultMessage   --- # 卡牌皮肤背包Response
net.S2CCardSkinBagUpdateResult = require "Network.PB.S2CCardSkinBagUpdateResult".CardSkinBagFlushMessage   --- # 卡牌皮肤背包更新Response
net.S2CCardSkinPutOnResult = require "Network.PB.S2CCardSkinPutOnResult".CardSkinPutOnResultMessage   --- # 卡牌皮肤穿上Response
net.S2CCardSkinPutOffResult = require "Network.PB.S2CCardSkinPutOffResult".CardSkinPutOffResultMessage   --- # 卡牌皮肤穿下Response
net.S2CCardCorrCardSkinInfoQueryResult = require "Network.PB.S2CCardCorrCardSkinInfoQueryResult".CardCorrCardSkinInfoQueryResultMessage   --- # 卡牌皮肤Response
net.S2CCardSkinActivationResult = require "Network.PB.S2CCardSkinActivationResult".CardSkinActivationResultMessage   --- # 卡牌皮肤激活返回结果协议
net.S2CCardSkinUpgradeResult = require "Network.PB.S2CCardSkinUpgradeResult".CardSkinUpgradeResultMessage   --- # 卡牌皮肤升级返回结果协议
net.S2CCardCorrCardSkinInfoRefreshPushResult = require "Network.PB.S2CCardCorrCardSkinInfoRefreshPushResult".CardCorrCardSkinInfoRefreshPushResultMessage   --- # 卡牌皮肤刷新协议

net.S2CEquipAdvancedResult = require "Network.PB.S2CEquipAdvancedResult".EquipAdvancedResultMessage   --- # 装备进阶
---- ### 战斗相关 ### ----
net.FightRecordResult = require "Network.PB.FightRecordResult".StartFightResult -- # 战斗记录统一响应消息 # --
net.S2CRobZhanbaoResult = require "Network.PB.S2CRobZhanbaoResult".RobZhanbaoResult --精灵树抢夺
net.S2CRobBuyTimesResult = require "Network.PB.S2CRobBuyTimesResult".RobBuyTimesResultMessage --精灵树抢夺次数返回结果

-- >>> 掉落相关的推送协议
net.S2CFBOverResult = require "Network.PB.S2CFBOverResult".FBOverResult -- ## 副本战斗结束
net.S2CBossFightResult = require "Network.PB.S2CBossFightResult".BossFightResult -- # (爬塔111)
net.S2CExploreStartFightResult = require "Network.PB.S2CExploreStartFightResult".ExploreStartFightResult -- # 探索战斗返回结果
net.S2CGHFbStartFightResult = require "Network.PB.S2CGHFbStartFightResult".GHFbStartFightResult -- # 工会战斗结果
net.S2CProtectStartFightResult = require "Network.PB.S2CProtectStartFightResult".ProtectStartFightResult -- # 保护公主结果
net.S2CRobFightResult = require "Network.PB.S2CRobFightResult".RobFightResult -- # 抢夺战斗结果
net.S2CTowerFightResult = require "Network.PB.S2CTowerFightResult".TowerFightResult -- # 爬塔战斗结果
net.S2CWorldBossFightResult = require "Network.PB.S2CWorldBossFightResult".WorldBossFightResult -- # 世界BOSS战斗结果
net.S2CArenaFightOverResult = require "Network.PB.S2CArenaFightOverResult".ArenaFightOverResult -- # 竞技场战斗结果
---探险相关协议
net.S2CExploreQueryResult = require "Network.PB.S2CExploreQueryResult".ExploreQueryResult -- # 探索请求结果
net.S2CExploreMapQueryResult = require "Network.PB.S2CExploreMapQueryResult".ExploreMapQueryResult -- # 探索地图查询结果
net.S2CExploreFightOverResult = require "Network.PB.S2CExploreFightOverResult".ExploreFightOverResult -- # 探索战斗返回结果

net.S2CEquipPutOnResult = require "Network.PB.S2CEquipPutOnResult".EquipPutOnResult -- #装备装备
net.S2CEquipPutOffResult = require "Network.PB.S2CEquipPutOffResult".EquipPutOffResult  -- #卸下装备
net.S2COpenTreasureChestRewardResult = require "Network.PB.S2COpenTreasureChestRewardResult".OpenTreasureChestRewardResultMessage  -- #装备宝箱使用

--军团相关协议
net.S2CGHAddGuyongjunResult = require "Network.PB.S2CGHAddGuyongjunResult".GHAddGuyongjunResult
net.S2CGHCheckInResult = require "Network.PB.S2CGHCheckInResult".GHCheckInResult
net.S2CGHCreateResult = require "Network.PB.S2CGHCreateResult".GHCreateResult
net.S2CGHDelGuyongjunResult = require "Network.PB.S2CGHDelGuyongjunResult".GHDelGuyongjunResult
net.S2CGHDismissResult = require "Network.PB.S2CGHDismissResult".GHDismissResult
net.S2CGHHandleApplyResult = require "Network.PB.S2CGHHandleApplyResult".GHHandleApplyResult
net.S2CGHItemUpdate = require "Network.PB.S2CGHItemUpdate".GHItemUpdate
net.S2CGHJoinResult = require "Network.PB.S2CGHJoinResult".GHJoinResult
net.S2CGHManagerMemResult = require "Network.PB.S2CGHManagerMemResult".GHManagerMemResult
net.S2CGHQieCuoResult = require "Network.PB.S2CGHQieCuoResult".GHQieCuoResult
net.S2CGHQueryApplyResult = require "Network.PB.S2CGHQueryApplyResult".GHQueryApplyResult
net.S2CGHQueryGuyongjunResult = require "Network.PB.S2CGHQueryGuyongjunResult".GHQueryGuyongjunResult
net.S2CGHQueryResult = require "Network.PB.S2CGHQueryResult".GHQueryResultMessage
net.S2CGHQuitResult = require "Network.PB.S2CGHQuitResult".GHQuitResult
net.S2CGHRankResult = require "Network.PB.S2CGHRankResult".GHRankResult
net.S2CGHRecordResult = require "Network.PB.S2CGHRecordResult".GHRecordResult
net.S2CGHSearchResult = require "Network.PB.S2CGHSearchResult".GHSearchResult
net.S2CGHSetLogoResult = require "Network.PB.S2CGHSetLogoResult".GHSetLogoResult
net.S2CGHSetShowMsgResult = require "Network.PB.S2CGHSetShowMsgResult".GHSetShowMsgResult
net.S2CGHUpdateResultMessage = require "Network.PB.S2CGHUpdateResultMessage".GHUpdateResultMessage

--公会积分战相关协议
net.S2CGHPointQueryResult = require "Network.PB.S2CGHPointQueryResult".GHPointQueryResult
net.S2CGHPointGroupResult = require "Network.PB.S2CGHPointGroupResult".GHPointGroupResult
net.S2CGHPointBuyChallengeResult = require "Network.PB.S2CGHPointBuyChallengeResult".GHPointBuyChallengeResult
net.S2CGHPointClearCDResult = require "Network.PB.S2CGHPointClearCDResult".GHPointClearCDResult
net.S2CGHPointFightOverResult = require "Network.PB.S2CGHPointFightOverResult".GHPointFightOverResult
net.S2CGHPointHistoryResult = require "Network.PB.S2CGHPointHistoryResult".GHPointHistoryResult
net.S2CGHPointMilestoneAwardResult = require "Network.PB.S2CGHPointMilestoneAwardResult".GHPointMilestoneAwardResult
net.S2CGHPointMilestoneQueryResult = require "Network.PB.S2CGHPointMilestoneQueryResult".GHPointMilestoneQueryResult
net.S2CGHPointTop50QueryResult = require "Network.PB.S2CGHPointTop50QueryResult".GHPointTop50QueryResult

-- 活动相关协议
net.ActivityQueryResult = require "Network.PB.ActivityQueryResult".ActivityQueryResultMessage
net.ActivityListQueryResult = require "Network.PB.ActivityListQueryResult".ActivityListQueryResultMessage
net.ActivityGetAwardResult = require "Network.PB.ActivityGetAwardResult".ActivityGetAwardResultMessage
net.S2CActivitySevenDayHappyResult = require "Network.PB.S2CActivitySevenDayHappyResult".ActivitySevenDayHappyResultMessage
net.S2CActivitySevenDayAwardResult = require "Network.PB.S2CActivitySevenDayAwardResult".ActivitySevenDayAwardResultMessage
net.S2CActivityTimeLimitExchangeResult = require "Network.PB.S2CActivityTimeLimitExchangeResult".ActivityTimeLimitExchangeResultMessage
net.S2CZhaoCaiCatActivityQueryResult = require "Network.PB.S2CZhaoCaiCatActivityQueryResult".ZhaoCaiCatActivityQueryResultMessage
net.S2CZhaoCaiCatActivityChouJiangResult = require "Network.PB.S2CZhaoCaiCatActivityChouJiangResult".ZhaoCaiCatActivityChouJiangResultMessage
net.S2CZhaoCaiCatActivityChouJiangRecordResult = require "Network.PB.S2CZhaoCaiCatActivityChouJiangRecordResult".ZhaoCaiCatActivityChouJiangRecordResultMessage
net.S2CConRecActivityAwaQueryResult = require "Network.PB.S2CConRecActivityAwaQueryResult".ConRecActivityAwaQueryResultMessage
net.S2CConRecActivityQueryResult = require "Network.PB.S2CConRecActivityQueryResult".ConRecActivityQueryResultMessage
net.S2CSinglContiRecharActivityQueryResult = require "Network.PB.S2CSinglContiRecharActivityQueryResult".SinglContiRecharActivityQueryResultMessage
net.S2CSinglContiRecharActivityAwaQueryResult = require "Network.PB.S2CSinglContiRecharActivityAwaQueryResult".SinglContiRecharActivityAwaQueryResultMessage
net.S2CDailyRechargeActivitySuccessFushResult = require "Network.PB.S2CDailyRechargeActivitySuccessFushResult".DailyRechargeActivitySuccessFushResultMessage
net.S2CDailyRechargeActivityQueryResult = require "Network.PB.S2CDailyRechargeActivityQueryResult".DailyRechargeActivityQueryResultMessage
net.S2CDailyRechargeActivityAwardQueryResult = require "Network.PB.S2CDailyRechargeActivityAwardQueryResult".DailyRechargeActivityAwardQueryResultMessage
net.S2CDailyRechargeActivityRecordResult = require "Network.PB.S2CDailyRechargeActivityRecordResult".DailyRechargeActivityRecordResultMessage
net.S2CHappyTurnMusicResult = require "Network.PB.S2CHappyTurnMusicResult".HappyTurnMusicResultMessage
net.S2CHappyTurnMusicQueryResult = require "Network.PB.S2CHappyTurnMusicQueryResult".HappyTurnMusicQueryResultMessage

--Vip相关协议
net.S2CVipChargeQueryResult = require "Network.PB.S2CVipChargeQueryResult".VipChargeQueryResult
net.S2CVipDiamondLibaoBuyResult = require "Network.PB.S2CVipDiamondLibaoBuyResult".VipDiamondLibaoBuyResult
net.S2CVipChongZhiQueryResult = require "Network.PB.S2CVipChongZhiQueryResult".VipChongZhiQueryResult
net.S2CVipChargeDoneResult = require "Network.PB.S2CVipChargeDoneResult".VipChargeDoneResult
net.S2CVipChargeDoneDailyResult = require "Network.PB.S2CVipChargeDoneDailyResult".VipChargeDoneDailyResult

--宠物进阶强化
net.S2CPetAdvancedResult = require "Network.PB.S2CPetAdvancedResult".PetAdvancedResult
net.S2CPetLevelUpResult = require "Network.PB.S2CPetLevelUpResult".PetLevelUpResult

--爬塔相关协议
net.S2CAddAttributeResult = require "Network.PB.S2CAddAttributeResult".AddAttributeResult
net.S2CAttributeQueryResult = require "Network.PB.S2CAttributeQueryResult".AttributeQueryResult
net.S2CTowerQueryResult = require "Network.PB.S2CTowerQueryResult".TowerQueryResult
net.S2CTowerRankQueryResult = require "Network.PB.S2CTowerRankQueryResult".TowerRankQueryResult
net.S2CTowerResetResult = require "Network.PB.S2CTowerResetResult".TowerResetResult
net.S2CTowerSweepResult = require "Network.PB.S2CTowerSweepResult".TowerSweepResult
net.S2CBossQueryResult = require "Network.PB.S2CBossQueryResult".BossQueryResult
net.S2CBuyBossResetCountResult = require "Network.PB.S2CBuyBossResetCountResult".BuyBossResetCountResult
net.S2CBuyResult = require "Network.PB.S2CBuyResult".BuyResult
net.S2CTowerBigStageAwardResult = require "Network.PB.S2CTowerBigStageAwardResult".TowerBigStageAwardResultMessage

-- error
net.S2CErrorMessage = require "Network.PB.S2CErrorMessage".S2CErrorMessage

-- 即是 request 又是 response 协议
net.FightRecordMessage = require "Network.PB.FightRecordMessage".FightRecordMessage --- ### 战斗记录协议 ### ---
--充值成功回复页面

--抢夺刷新
net.RobBoxFlushMessage = require "Network.PB.S2CRobBoxFlush".RobBoxFlushMessage




net.S2CWorldBossActivateResult = require "Network.PB.S2CWorldBossActivateResult".WorldBossActivateResultMessage  
net.S2CWorldBossTotalResult = require "Network.PB.S2CWorldBossTotalResult".WorldBossTotalResultMessage
net.S2CWorldBossQueryResult = require "Network.PB.S2CWorldBossQueryResult".WorldBossQueryResultMessage
net.S2CWBossListResult=require "Network.PB.S2CWBossListResult".WBossListResultMessage
net.S2CWBossSharerResult=require "Network.PB.S2CWBossSharerResult".WBossSharerResultMessage
net.S2CWBossFightStartResult=require "Network.PB.S2CWBossFightStartResult".WBossFightStartResultMessage
net.S2CBuyWBossKeyResult=require "Network.PB.S2CBuyWBossKeyResult".BuyWBossKeyResultMessage
net.S2CWBossFightEndResult=require "Network.PB.S2CWBossFightEndResult".WorldBossTotalResultMessage



net.S2CStartAdventureResultMessage=require "Network.PB.S2CStartAdventureResultMessage".StartAdventureResultMessage
net.S2CBuyAdventureTimesResultMessage=require "Network.PB.S2CBuyAdventureTimesResultMessage".BuyAdventureTimesResultMessage
net.S2CAdvanceAdventureResultMessage=require "Network.PB.S2CAdvanceAdventureResultMessage".AdvanceAdventureResultMessage
net.C2STiliCountDownRequest=require "Network.PB.C2STiliCountDownRequest".TiliCountDownRequestMessage
net.S2CVipDiamondBuyCoinQueryResult=require "Network.PB.S2CVipDiamondBuyCoinQueryResult".VipDiamondBuyCoinQueryResult

--体力回复
net.S2CTiliCountDownResult=require "Network.PB.S2CTiliCountDownResult".TiliCountDownResultMessage

--是否是首次改名
net.S2CWhetherTheFirstRenameResult=require "Network.PB.S2CWhetherTheFirstRenameResult".WhetherTheFirstRenameResultMessage

--流派回复
net.S2CGenreQueryResult=require "Network.PB.S2CGenreQueryResult".GenreQueryResultMessage

--流派达成回复
net.S2CGenreChangeStateResult=require "Network.PB.S2CGenreChangeStateResult".GenreChangeStateResult
--限时神降请求
net.S2CActivityGodComingResult=require "Network.PB.S2CActivityGodComingResult".ActivityGodComingResultMessage

-- 塔罗牌相关
net.S2CTarotQueryResult = require "Network.PB.S2CTarotQueryResult".TarotQueryResult
net.S2CTarotCardActiveResult = require "Network.PB.S2CTarotCardActiveResult".TarotCardActiveResult
net.S2CTarotProgressActiveResult = require "Network.PB.S2CTarotProgressActiveResult".TarotProgressActiveResult

--精灵树升级
net.S2CRobTreeLevelUpResult=require "Network.PB.S2CRobTreeLevelUpResult".RobTreeLevelUpResult
--精灵树秒蛋
net.S2CTakeBoxSecondKillResult=require "Network.PB.S2CTakeBoxSecondKillResult".S2CTakeBoxSecondKillResult
--精灵树秒蛋信息
net.S2CTakeBoxSecondKillInfoResult=require "Network.PB.S2CTakeBoxSecondKillInfoResult".TakeBoxSecondKillInfoResult

--小宇宙相关协议
net.C2SCardTheSmallUniverseRequest = require "Network.PB.C2SCardTheSmallUniverseRequest".CardTheSmallUniverseRequestMessage
net.S2CCardTheSmallUniverseResult = require "Network.PB.S2CCardTheSmallUniverseResult".CardTheSmallUniverseResultMessage
--团队天赋
net.S2CCardTeamTalentChooseResult=require "Network.PB.S2CCardTeamTalentChooseResult".CardTeamTalentChooseResult

--星愿相关
net.C2SStarCoinWishRequest = require "Network.PB.C2SStarCoinWishRequest".StarCoinWishRequestMessage
net.S2CStarCoinWishResult = require "Network.PB.S2CStarCoinWishResult".StarCoinWishResultMessage
net.C2SStarDiamondWishRequest = require "Network.PB.C2SStarDiamondWishRequest".StarDiamondWishRequestMessage
net.S2CStarDiamondWishResult = require "Network.PB.S2CStarDiamondWishResult".StarDiamondWishResultMessage
net.C2SStarQueryRequest = require "Network.PB.C2SStarQueryRequest".StarQueryRequestMessage
net.S2CStarQueryResult = require "Network.PB.S2CStarQueryResult".StarQueryResultMessage
net.S2CTalkAddToBlackResult = require "Network.PB.S2CTalkAddToBlackResult".TalkAddToBlackResult

-- 跑马灯
net.S2CMarqueeResult = require "Network.PB.S2CMarqueeResult".MarqueeResult

net.S2COperationActivityQueryResult = require "Network.PB.OperationActivityNetMessage".OperationActivityQueryResultMessage
net.S2COperationActivityPickItemResult = require "Network.PB.OperationActivityNetMessage".OperationActivityPickItemResultMessage

return net