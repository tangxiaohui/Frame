
require "Object.LuaObject"

-----------------------------------------------------------------------
---
--- 这里放所有网络协议请求的接口
---
-----------------------------------------------------------------------

local ServerService = {}

-----------------------------------------------------------------------
--- 记录行为请求
-----------------------------------------------------------------------
function ServerService.ActionRecordRequest(trackingId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SActionRecordRequest")
    msg.actionID = trackingId
    return msg, prototype
end

-----------------------------------------------------------------------
--- 登录请求
-----------------------------------------------------------------------
function ServerService.Login(account, server_id, signature, channel, sdkId, deviceId, deviceModel)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SLoginRequest")
    msg.account = account
    msg.server_id = server_id
    msg.signature = signature
    msg.channel = channel
    msg.uid = ""
    msg.sdkId = sdkId
    msg.deviceId = deviceId
    msg.deviceModel = deviceModel
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求选择用户(注册初始卡牌和名字)
-----------------------------------------------------------------------
function ServerService.ChoosePlayer(cardId, playerName)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SChoosePlayerRequest")
    msg.cardID = cardId
    msg.playerName = playerName
    -- 发送消息
    return msg, prototype
end
-----------------------------------------------------------------------
--- 请求用户基本数据(在有用户的时候进行调用)
-----------------------------------------------------------------------
function ServerService.LoadPlayer()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SLoadPlayerRequest")
end

-----------------------------------------------------------------------
--- 请求用户卡包数据
-----------------------------------------------------------------------
function ServerService.CardBagQuery()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SCardBagQueryRequest")
end

-----------------------------------------------------------------------
--- 查询所有地图情况
-----------------------------------------------------------------------
function ServerService.QueryAllMaps()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SFBQueryAllMapRequest")
end


function ServerService.DrawCompleteAward(chapterId, stage)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SFBDrawCompleteAwardRequest")
    msg.mapID = chapterId
    msg.stage = stage   --[1,2,3]分别对应完成度[50%,80%,100%]
    return msg, prototype
end
-----------------------------------------------------------------------
--- 购买挑战次数
-----------------------------------------------------------------------
function ServerService.BuyChallengeCount(chapterId, levelId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SFBBuyChallengeRequest")
    msg.mapID = chapterId
    msg.fbID = levelId
    return msg, prototype
end


-----------------------------------------------------------------------
--- 请求上阵
-----------------------------------------------------------------------
function ServerService.PutCardOnLineup(uid, type, pos,zhanli)
    debug_print(zhanli,"PutCardOnLineup zhanli")

    local messageManager = require "Network.MessageManager"
    local msg, protoType = messageManager:CreateMessageByName("C2SPutOnZhenrongRequest")
    msg.type = type
    msg.cardUIDFrom = uid
    msg.toPos = pos
    if zhanli~=nil then
        msg.head.sid=zhanli
    end
    return msg, protoType
end

-----------------------------------------------------------------------
--- 请求下阵
-----------------------------------------------------------------------
function ServerService.PutCardOffLineup(type, pos,uid,zhanli)
    debug_print(zhanli,"PutCardOffLineup zhanli")
    
    local messageManager = require "Network.MessageManager"
    local msg, protoType = messageManager:CreateMessageByName("C2SPutOffZhenrongRequest")
    msg.type = type
    msg.fromPos = pos
    if zhanli~=nil then
        msg.head.sid=zhanli
    end

    return msg, protoType
end

-----------------------------------------------------------------------
--- 退出
-----------------------------------------------------------------------
function ServerService.QuitGame()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SQuitGameRequest")
end

-----------------------------------------------------------------------
--- 心跳包
-----------------------------------------------------------------------
function ServerService.Ping()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SPing")
end

-----------------------------------------------------------------------
--- 抽卡请求
-----------------------------------------------------------------------
function ServerService.ChoukaQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SChoukaQueryRequest")
end

-----------------------------------------------------------------------
--- 道具抽卡请求
-----------------------------------------------------------------------
function ServerService.ChoukaDaojuChooseRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SChoukaDaojuChooseRequest")
end

-----------------------------------------------------------------------
--- 聊天请求
-----------------------------------------------------------------------
function ServerService.TalkQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STalkQueryRequest")
    msg.head.sid = 100
    return msg ,prototype
end
-----------------------------------------------------------------------
--- 发送聊天请求
-----------------------------------------------------------------------
function ServerService.TalkRequest(msg,msgType,toPlayerUID,toPlayerName,gonghuiID,broadcastID)
    local messageManager = require "Network.MessageManager"
    local msgTable, prototype = messageManager:CreateMessageByName("C2STalkRequest")
    msgTable.msg = msg
    msgTable.type = msgType 
    msgTable.toPlayerUID = toPlayerUID
    msgTable.toPlayerName = toPlayerName
    msgTable.gonghuiID = gonghuiID
    msgTable.broadcastID = broadcastID

    return msgTable,prototype
end
-----------------------------------------------------------------------
--- 扫荡请求(普通战斗)
-----------------------------------------------------------------------
-- # consumableType  0=扫荡卡扫荡 1=钻石扫荡
function ServerService.BattleSweep(levelID, sweepCount, consumableType)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SFBSweepRequest")
    print(levelID, sweepCount, consumableType)
    msg.fbID = levelID
    msg.sweepCount = sweepCount
    msg.type = consumableType
    return msg, prototype
end
-----------------------------------------------------------------------
--- 背包道具查询请求
-----------------------------------------------------------------------
function ServerService.ItemBagQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SItemBagQueryRequest")
end
-----------------------------------------------------------------------
--- 背包装备查询请求
-----------------------------------------------------------------------
function ServerService.EquipBagQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SEquipBagQueryRequest")
end

-----------------------------------------------------------------------
--- 背包装备宝箱使用请求
-----------------------------------------------------------------------
function ServerService.OpenTreasureChestRewardRequest(id,ranBoxItemId,itemNum)
    debug_print("id,ranBoxItemId",id,ranBoxItemId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SOpenTreasureChestRewardRequest")
    msg.optionalBoxId = id
    msg.ranBoxItemId = ranBoxItemId
    msg.itemNum = itemNum
    return msg,prototype
end

-----------------------------------------------------------------------
--- 背包进阶请求
-----------------------------------------------------------------------
function ServerService.EquipAdvancedRequest(needType,advancedId,consumeEquipUIDList)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipAdvancedRequest")
    msg.needType = needType
    msg.advancedId = advancedId
    msg.consumeEquipUIDList = consumeEquipUIDList
    return msg,prototype
end

-----------------------------------------------------------------------
--- 装备碎片查询请求
-----------------------------------------------------------------------
function ServerService.EquipSuipianBagQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SEquipSuipianBagQueryRequest")
end
-----------------------------------------------------------------------
--- 钻石抽卡一次请求
-----------------------------------------------------------------------
function ServerService.ChoukaDiamondChooseRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SChoukaDiamondChooseRequest")
end
-----------------------------------------------------------------------
--- 钻石抽卡十次请求
-----------------------------------------------------------------------
function ServerService.ChoukaDiamondChooseTenRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SChoukaDiamondChooseTenRequest")
end

-----------------------------------------------------------------------
--- 修改名字请求
-----------------------------------------------------------------------
function ServerService.ChangePlayerNameRequest(NewName)
     local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SChangePlayerNameRequest")
    msg.newName = NewName
    return msg, prototype
end

-----------------------------------------------------------------------
--- 邮件请求
-----------------------------------------------------------------------
function ServerService.MailRequest()
	local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SMailRequest")
end

-----------------------------------------------------------------------
--- 邮件删除请求
-----------------------------------------------------------------------
function ServerService.MailDelRequest(ids)
	local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SMailDelRequest")
    print('MailDelRequest '..ids)
    msg.ids = tostring(ids) 
	return msg,prototype
end

-----------------------------------------------------------------------
--- 邮件奖励领取请求
-----------------------------------------------------------------------
function ServerService.MailDrawRequest(id)
	local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SMailDrawRequest")
    print(id)
    msg.mialId = id
	return msg,prototype
end

-----------------------------------------------------------------------
--- 设置邮件已读请求
-----------------------------------------------------------------------
function ServerService.MailSetReadRequest(id)
	local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SMailSetReadRequest")
    print('---------设置邮件已读请求----------------------------'..id)
    msg.mailId = id
	return msg,prototype
end

-----------------------------------------------------------------------
--- 卡牌升级请求
-----------------------------------------------------------------------
function ServerService.CardProRequest(cardUid,num1,num2,num3)
	--- id 卡牌ID，消耗经验电池1，高能经验电池2，超能经验电池3的数量
	local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardProRequest")
    print(cardUid ..type(cardUid))
    msg.cardUID = tostring(cardUid)
	msg.xiaojingyandanNum = num1
	msg.zhongjingyandanNum = num2
	msg.dajingyandanNum = num3
	
	return msg,prototype
end

-----------------------------------------------------------------------
--- 加入黑名单请求
-----------------------------------------------------------------------
function ServerService.TalkAddToBlackRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STalkAddToBlackRequest")
    msg.playerUID = id
    return msg,prototype
end
-----------------------------------------------------------------------
--- 黑名单查询请求
-----------------------------------------------------------------------
function ServerService.TalkBlackQueryResult()
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STalkBlackQueryRequest")
    return msg,prototype
end
-----------------------------------------------------------------------
--- 删除黑名单请求
-----------------------------------------------------------------------
function ServerService.TalkDismissFromBlackResult(id)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STalkDismissFromBlackRequest")
    msg.playerUID = id
    return msg,prototype
end
-----------------------------------------------------------------------
--- 商店Query请求
-----------------------------------------------------------------------
function ServerService.ShopQueryRequest(shopType)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SShopQueryRequest")
    msg.type = shopType
    return msg,prototype
end

-----------------------------------------------------------------------
--- 商店购买请求
-----------------------------------------------------------------------
function ServerService.ShopBuyRequest(shopType,itemGid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SShopBuyRequest")
    msg.type = shopType
    msg.gid = itemGid
    return msg,prototype
end

-----------------------------------------------------------------------
--- 商店刷新请求
-----------------------------------------------------------------------
function ServerService.ShopFlushRequest(shopType)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SShopFlushRequest")
    msg.type = shopType
    return msg,prototype
end

-----------------------------------------------------------------------
--- 黑市Query请求
-----------------------------------------------------------------------
function ServerService.ShopHeishiQueryRequest()
	local messageManager = require "Network.MessageManager"
	return messageManager:CreateMessageByName("C2SShopHeishiQueryRequest")
end

-----------------------------------------------------------------------
--- 黑市永久开启请求
-----------------------------------------------------------------------
function ServerService.ShopHeishiForEverRequest()
	local messageManager = require "Network.MessageManager"
	return messageManager:CreateMessageByName("C2SShopHeishiForEverRequest")
end

-----------------------------------------------------------------------
--- 道具抽卡一键开启请求
-----------------------------------------------------------------------
function ServerService.UseAllTreasureRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SUseAllTreasureRequest")
end
-----------------------------------------------------------------------
--- 装备出售请求
-----------------------------------------------------------------------
function ServerService.EquipsSellRequest(equipsUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipSellRequest")
    msg.equips = equipsUID
    return msg, prototype
end
-----------------------------------------------------------------------
--- 卡牌碎片背包请求
-----------------------------------------------------------------------
function ServerService.CardSuipianBagQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SCardSuipianBagQueryRequest")
end

-----------------------------------------------------------------------
--- Item出售请求
-----------------------------------------------------------------------
function ServerService.ItemBagSellRequest(uids)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SItemBagSellRequest")
    msg.uids = uids
    return msg, prototype
end

-----------------------------------------------------------------------
--- 用户头像请求
-----------------------------------------------------------------------
function ServerService.PlayerHeadRequest(type,cardID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SChooseHeadImageRequest")
    msg.type = type
    msg.cardID = cardID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 兑换码
-----------------------------------------------------------------------
function ServerService.Code(code)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SExchangeCodeRequest")
    msg.code = code
    print(msg.code)
    return msg, prototype
end

-----------------------------------------------------------------------
--- 主场景公告请求
------------------------------------------------------------------------
function ServerService.GuideGonggaoRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SGuideGonggaoRequest")
end

-----------------------------------------------------------------------
--- 红点状态请求
------------------------------------------------------------------------
function ServerService.GuideRedRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SGuideRedRequest")
end

-----------------------------------------------------------------------
--- 卡牌碎片合成请求
-----------------------------------------------------------------------
function ServerService.CardSuipianBuildRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardSuipianBuildRequest")
    msg.cardSuipianID = id
    return msg, prototype
end

-----------------------------------------------------------------------
--- 竞技场Query请求
-----------------------------------------------------------------------
function ServerService.ArenaQueryRequest(const)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SArenaQueryRequest")
    msg.head.sid = const
    return msg, prototype
end

-----------------------------------------------------------------------
--- 竞技场Top请求
-----------------------------------------------------------------------
function ServerService.ArenaTop50QueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SArenaTop50QueryRequest")
end

-----------------------------------------------------------------------
--- 根据Uid 查询玩家信息请求
-----------------------------------------------------------------------
function ServerService.PlayerSimpleInfoQueryRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SPlayerSimpleInfoQueryRequest")
    msg.playerUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 竞技场购买挑战请求请求
-----------------------------------------------------------------------
function ServerService.ArenaBuyChallengeRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SArenaBuyChallengeRequest")
end

-----------------------------------------------------------------------
--- 竞技场清空CD请求请求
-----------------------------------------------------------------------
function ServerService.ArenaClearCDRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SArenaClearCDRequest")
end

-----------------------------------------------------------------------
--- 卡牌升品请求
-----------------------------------------------------------------------
function ServerService.CardGradeUpRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardGradeUpRequest")
    msg.cardUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 卡牌进阶请求
-----------------------------------------------------------------------
function ServerService.CardStageUpRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardStageUpRequest")
    msg.cardUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求签到信息
-----------------------------------------------------------------------
function ServerService.DailySignInQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SDailySignInQueryRequest")
end

-----------------------------------------------------------------------
--- 请求签到
-----------------------------------------------------------------------
function ServerService.DailySignInDrawRequest(day,sid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SDailySignInDrawRequest")
    msg.head.sid=sid
    msg.day = day    
    return msg, prototype    
end

-----------------------------------------------------------------------
--- 请求新手任务
-----------------------------------------------------------------------
function ServerService.OnlineAwardQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SOnlineAwardQueryRequest") 
end

-----------------------------------------------------------------------
--- 请求领取新手任务奖励
-----------------------------------------------------------------------
function ServerService.OnlineAwardDrawRequest(index)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SOnlineAwardDrawRequest")
    msg.index = index    
    return msg, prototype    
end

-----------------------------------------------------------------------
--- 请求查询精灵树信息
-----------------------------------------------------------------------
function ServerService.RobQueryRequest(sid,index)
    print(sid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SRobQueryRequest")    
    msg.head.sid = sid
    msg.buyPos=index
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求领取精灵树物品
-----------------------------------------------------------------------
function ServerService.RobOpenBoxRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SRobOpenBoxRequest")
    msg.repairBoxUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求保护精灵树物品
-----------------------------------------------------------------------
function ServerService.TakeBoxInProtectedRequest(uid,type)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STakeBoxInProtectedRequest")
    msg.repairBoxUID = uid
    msg.type = type
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求宠物升级
-----------------------------------------------------------------------
function ServerService.PetLevelUpRequest(uid,equipUIDList)
    print(equipUIDList)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SPetLevelUpRequest")
    msg.equipUID = uid
    msg.consumeEquipUIDList = equipUIDList
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求精灵树抢夺次数
-----------------------------------------------------------------------
function ServerService.ElvenTreeBuyRobTimeRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SRobBuyTimesRequest")
end

-----------------------------------------------------------------------
--- 请求宠物进阶
-----------------------------------------------------------------------
function ServerService.PetAdvancedRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SPetAdvancedRequest")
    msg.equipUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求查询保护公主信息
-----------------------------------------------------------------------
function ServerService.ProtectQueryRequest(sid)
    sid = sid or 0
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SProtectQueryRequest")
    msg.head.sid = sid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求保护公主敌人信息
-----------------------------------------------------------------------
function ServerService.CheckProtectEnemyRequest(gateID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SProtectCheckEnemyRequest")
    msg.gate = gateID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 请求打开保护公主的箱子
-----------------------------------------------------------------------
function ServerService.ProtectDrawAwardRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SProtectDrawAwardRequest")
end

-----------------------------------------------------------------------
--- 请求重置保护公主信息
-----------------------------------------------------------------------
function ServerService.ProtectResetRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SProtectResetRequest")
end

-----------------------------------------------------------------------
--- ######## 战斗请求 #######
--- note: 这些函数会填充各自不同的参数, 等待战斗后填充 fightRecord 字段
-----------------------------------------------------------------------

-- # Boss战斗(暂不知道是哪的, 好像是爬塔的)
function ServerService.BossFightRequest(bossID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SBossFightRequest")
    msg.bossID = bossID
    return msg, prototype
end

-- # 探索 战斗
function ServerService.ExploreFightRequest(systemID, levelID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SExploreStartFightRequest")
    msg.systemID = systemID
    msg.fbID = levelID
    return msg, prototype
end

-- # 副本战斗
function ServerService.FBStartFightRequest(levelID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SFBStartFightRequest")
    msg.fbID = levelID
    return msg, prototype
end

-- # 工会副本 战斗
function ServerService.GHFBStartFightRequest(chapterID, levelID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHFbStartFightRequest")
    msg.mapID = chapterID
    msg.fbID = levelID
    return msg, prototype
end

-- # 保护公主 战斗
function ServerService.ProtectStartFightRequest(gateID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SProtectStartFightRequest")
    msg.gate = gateID
    return msg, prototype
end

-- # 抢夺 战斗
function ServerService.RobFightRequest(playerUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SRobFightRequest")
    msg.playerUID = playerUID
    return msg, prototype
end

-- # 爬塔 战斗 (layer: 挑战层数, star: 挑战星数)
function ServerService.TowerFightRequest(layer, star)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STowerFightRequest")
    msg.layer = layer
    msg.star = star
    return msg, prototype
end

-- # 世界BOSS 战斗
function ServerService.WorldBossFightRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SWorldBossFightRequest")
end

-- # 竞技场 战斗
function ServerService.ArenaStartFightRequest(playerUID)
     local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SArenaStartFightRequest")
    msg.playerUID = playerUID
    return msg, prototype
end

-- ## 战斗退出 ## --
function ServerService.FightSignOutQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SFightSignOutQueryRequest")
end

-----------------------------------------------------------------------
--- 卡牌天赋选择
-----------------------------------------------------------------------
function ServerService.CardTalentChooseRequest(uid,talent1,talent2,talentA,talentBID,talentCID)
   debug_print("CardTalentChooseRequest")
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardTalentChooseRequest")
    msg.cardUID = uid
    msg.talent1 = talent1
    msg.talent2 = talent2
    msg.talentA = talentA
    msg.talentBID = talentBID
    msg.talentCID = talentCID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 卡牌天赋重置
-----------------------------------------------------------------------
function ServerService.CardTalentResetRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardTalentResetRequest")
    msg.cardUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 装备升级请求
-----------------------------------------------------------------------
function ServerService.EquipLevelUpRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipLevelUpRequest")
    msg.equipUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 装备自动升级请求
-----------------------------------------------------------------------
function ServerService.EquipAutoLevelUpRequest(uid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipAutoLevelUpRequest")
    msg.equipUID = uid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 装备碎片合成请求
-----------------------------------------------------------------------
function ServerService.EquipSuipianComposeRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipSuipianComposeRequest")
    msg.equipSuipian = id
    return msg, prototype
end

-----------------------------------------------------------------------
--- 装备碎片出售请求
-----------------------------------------------------------------------
function ServerService.EquipSuipianSellRequest(ids)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipSuipianSellRequest")
    for i = 1 ,#ids do
        msg.equipSuipian:append(ids[i])
    end
    return msg, prototype
end

-----------------------------------------------------------------------
--- 探索请求
-----------------------------------------------------------------------
function ServerService.ExploreQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SExploreQueryRequest")
end

-----------------------------------------------------------------------
--- 探索地图查询
-----------------------------------------------------------------------
function ServerService.ExploreMapQueryRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SExploreMapQueryRequest")
    msg.systemID = id
    return msg, prototype
end

-----------------------------------------------------------------------
--- 探索战斗请求
-----------------------------------------------------------------------
function ServerService.ExploreFightOverRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SExploreFightOverRequest")
    msg.systemID = id
    return msg, prototype
end

-----------------------------------------------------------------------
--- 宝石合成请求
-----------------------------------------------------------------------
function ServerService.StoneComposeRequest(list,costType)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SStoneComposeRequest")
    msg.consumeStoneUIDList = list
    msg.consumType = costType
    return msg, prototype
end

-----------------------------------------------------------------------
--- 宝石合成Query请求
-----------------------------------------------------------------------
function ServerService.StoneQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SStoneQueryRequest")
end

-----------------------------------------------------------------------
--- 宝石镶嵌请求
-----------------------------------------------------------------------
function ServerService.StoneToEquipRequest(stoneUID,equipUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SStoneToEquipRequest")
    msg.stoneUID = stoneUID
    msg.equipUID = equipUID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 宝石拆除请求
-----------------------------------------------------------------------
function ServerService.StoneRemoveRequest(stoneUID,equipUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SStoneRemoveRequest")
    msg.stoneUID = stoneUID
    msg.equipUID = equipUID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 新手引导状态请求
-----------------------------------------------------------------------
function ServerService.GuideStateRequest()
    local messageManager = require "Network.MessageManager"
	return messageManager:CreateMessageByName("C2SGuideStateRequest")
end

-----------------------------------------------------------------------
--- 新手引导步骤完成
-----------------------------------------------------------------------
function ServerService.GuideDoneRequest(stepId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGuideDoneRequest")
    msg.step = stepId
    return msg, prototype
end

-----------------------------------------------------------------------
--- 军团请求
-----------------------------------------------------------------------
function ServerService.GHAddGuyongjunRequest(gonghuiID, cardUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHAddGuyongjunRequest")
    msg.ghID = gonghuiID
    msg.cardUID = cardUID
    return msg, prototype
end

function ServerService.GHCheckInRequest(gonghuiID, checkType)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHCheckInRequest")
    msg.ghID = gonghuiID    --工会ID
    msg.type = checkType    --签到类型 1=免费签 2=金币签
    return msg, prototype
end

function ServerService.GHCreateRequest(gonghuiName, logoID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHCreateRequest")
    msg.ghName = gonghuiName
    msg.logoID = logoID
    return msg, prototype
end

function ServerService.GHDelGuyongjunRequest(gonghuiID, cardUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHDelGuyongjunRequest")
    msg.ghID = gonghuiID
    msg.cardUID = cardUID
    return msg, prototype
end

function ServerService.GHDismissRequest(gonghuiID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHDismissRequest")
    msg.ghID = gonghuiID
    return msg, prototype
end

function ServerService.GHHandleApplyRequest(gonghuiID, applyUID, applyState)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHHandleApplyRequest")
    msg.ghID = gonghuiID
    msg.applyUID = applyUID
    msg.state = applyState  --0=通过 1=拒绝
    return msg, prototype
end

function ServerService.GHJoinRequest(gonghuiID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHJoinRequest")
    msg.ghID = gonghuiID
    return msg, prototype
end

function ServerService.GHManagerMemRequest(gonghuiID, memUID, operState)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHManagerMemRequest")
    msg.ghID = gonghuiID
    msg.memUID = memUID
    msg.state = operState   --0=移交指挥 1=任命参谋 2=取消参谋 3=踢出工会 4=任命代理指挥官 5=取消代理指挥官
    return msg, prototype
end

function ServerService.GHQieCuoRequest(playerUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHQieCuoRequest")
    msg.playerUID = playerUID
    return msg, prototype
end

function ServerService.GHQueryApplyRequest(gonghuiID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHQueryApplyRequest")
    msg.ghID = gonghuiID
    return msg, prototype
end

function ServerService.GHQueryGuyongjunRequest(gonghuiID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHQueryGuyongjunRequest")
    msg.ghID = gonghuiID
    return msg, prototype
end

function ServerService.GHQuitRequest(gonghuiID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHQuitRequest")
    msg.ghID = gonghuiID
    return msg, prototype
end

function ServerService.GHQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHQueryRequest")
    return msg, prototype
end

function ServerService.GHRankRequest()
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHRankRequest")
    return msg, prototype
end

function ServerService.GHRecordRequest(gonghuiID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHRecordRequest")
    msg.ghID = gonghuiID
    return msg, prototype
end

function ServerService.GHSearchRequest(word)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHSearchRequest")
    msg.word = word
    return msg, prototype
end

function ServerService.GHSetLogoRequest(type, name, gonghuiID, logoID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHSetLogoRequest")
    msg.type = type
    msg.name = name
    msg.ghID = gonghuiID
    msg.logoID = logoID
    return msg, prototype
end

function ServerService.GHSetShowMsgRequest(gonghuiID, showMsg)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHSetShowMsgRequest")
    msg.ghID = gonghuiID
    msg.showMsg = showMsg
    return msg, prototype
end

function ServerService.GHUpdateRequest(type, aid, playerUID, worshipUID)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SGHUpdateRequestMessage")
    msg.type = type
    msg.aid = aid
    msg.playerUID = playerUID
    msg.worshipUID = worshipUID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 领取成就请求
-----------------------------------------------------------------------
function ServerService.ChengjiuDrawRequest(cid,key)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SChengjiuDrawRequest")
    msg.cid = cid 
    msg.key = key
    return msg, prototype
end

-----------------------------------------------------------------------
--- 成就Query请求
-----------------------------------------------------------------------
function ServerService.ChengjiuQueryRequest(sonid,typeId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SChengjiuQueryRequest")
    msg.sonid = sonid
    msg.head.sid = typeId
    return msg, prototype
end

-----------------------------------------------------------------------
--- 图鉴Query请求
-----------------------------------------------------------------------
function ServerService.TuJianQueryRequest(sonid,typeId)
	local messageManager = require "Network.MessageManager"
	local msg,prototype = messageManager:CreateMessageByName("TuJianQueryRequestMessage")
	msg.son = sonid
	msg.head.sid = typeId
	return msg,prototype
end

-----------------------------------------------------------------------
--- 领取图鉴请求
-----------------------------------------------------------------------
function ServerService.TuJianDrawRequest(oid,typeId)
	local messageManager = require "Network.MessageManager"
	local msg,prototype = messageManager:CreateMessageByName("TuJianDrawRequestMessage")
	msg.oid = oid
	msg.type = typeId
	return msg,prototype
end

-----------------------------------------------------------------------
--- 领取任务请求
-----------------------------------------------------------------------
function ServerService.TaskDrawRequest(ctype,taskid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STaskDrawRequest")
    msg.type = ctype
    msg.taskid = taskid
    return msg, prototype
end

-----------------------------------------------------------------------
--- 任务Query请求
-----------------------------------------------------------------------
function ServerService.TaskQueryRequest()    
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STaskQueryRequest")
    return msg, prototype
end

-----------------------------------------------------------------------
--- 交换阵容请求
-----------------------------------------------------------------------
function ServerService.ZhenrongInnerChangeRequest(ctype,fromPos,toPos)    
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SZhenrongInnerChangeRequest")
    msg.type = ctype
    msg.fromPos = fromPos
    msg.toPos = toPos
    return msg, prototype
end

-----------------------------------------------------------------------
--- 穿装备
-----------------------------------------------------------------------
function ServerService.EquipPutOnRequest(cardUID,equipUID,toPos)    
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipPutOnRequest")
    msg.cardUID = cardUID
    msg.equipUID = equipUID
    msg.toPos = toPos
    return msg, prototype
end

-----------------------------------------------------------------------
--- 卸下装备
-----------------------------------------------------------------------
function ServerService.EquipPutOffRequest(cardUID,equipUID)    
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SEquipPutOffRequest")
    msg.cardUID = cardUID
    msg.equipUID = equipUID
    return msg, prototype
end

-----------------------------------------------------------------------
--- 活动请求
-----------------------------------------------------------------------
function ServerService.ActivityQueryRequest(activeid)
	local messageManager = require "Network.MessageManager"
	local msg,prototype = messageManager:CreateMessageByName("ActivityQueryRequest")
    msg.activityId = activeid
	return msg,prototype
end

-----------------------------------------------------------------------
--- 活动列表请求
-----------------------------------------------------------------------
function ServerService.ActivityListQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("ActivityListQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 活动奖励请求
-----------------------------------------------------------------------
function ServerService.ActivityGetAwardRequest(tid,activeid)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("ActivityGetAwardRequest")
    msg.tid = tid
    msg.activityId = activeid
    return msg,prototype
end

function ServerService.ActivityFirstChargeRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("ActivityGetAwardRequest")
    msg.head.sid = 10000
    msg.tid = 0
    msg.activityId = 0
    return msg,prototype
end

-----------------------------------------------------------------------
--- 七日狂欢请求
-----------------------------------------------------------------------
function ServerService.ActivitySevenDayHappyRequest(hid)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SActivitySevenDayHappyRequest")
    msg.hid = hid
    return msg,prototype
end

-----------------------------------------------------------------------
--- 七日狂欢领取
-----------------------------------------------------------------------
function ServerService.ActivitySevenDayAwardRequest(tid,activityId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SActivitySevenDayAwardRequest")
    msg.tid = tid
    msg.activityId = activityId
    return msg,prototype
end

-----------------------------------------------------------------------
--- 招财猫
-----------------------------------------------------------------------
function ServerService.ZhaoCaiCatActivityQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SZhaoCaiCatActivityQueryRequest")
    return msg,prototype
end

function ServerService.ZhaoCaiCatActivityChouJiangRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SZhaoCaiCatActivityChouJiangRequest")
    msg.zhaoCaiCatId = id
    return msg,prototype
end

function ServerService.ConRecActivityAwaQueryRequest(awaType,id)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SConRecActivityAwaQueryRequest")
	msg.awaType = awaType
    msg.awaId = id
    return msg,prototype
end

function ServerService.ConRecActivityQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SConRecActivityQueryRequest")
    return msg,prototype
end

function ServerService.SinglContiRecharActivityQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SSinglContiRecharActivityQueryRequest")
    return msg,prototype
end

function ServerService.SinglContiRecharActivityAwaQueryRequest(awaType,id)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SSinglContiRecharActivityAwaQueryRequest")
    msg.awaType = awaType
    msg.awaId = id
    return msg,prototype
end

function ServerService.DailyRechargeActivityAwardQueryRequest(purProId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SDailyRechargeActivityAwardQueryRequest")
    msg.purProId = purProId
    return msg,prototype
end

function ServerService.DailyRechargeActivityQueryRequest(id)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SDailyRechargeActivityQueryRequest")
    msg.dailyRechargeId = id
    return msg,prototype
end

-----------------------------------------------------------------------
--- 活動轉轉樂
-----------------------------------------------------------------------
function ServerService.HappyTurnMusicRequest(turnType)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SHappyTurnMusicRequest")
    msg.turnType = turnType
    return msg,prototype
end

function ServerService.HappyTurnMusicQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SHappyTurnMusicQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 一元礼包请求
-----------------------------------------------------------------------
--function ServerService.OneYuanReceiveRequest()
--    local messageManager = require "Network.MessageManager"
--    local msg,prototype = messageManager:CreateMessageByName("C2SOneYuanChargeRequest")
--    return msg,prototype
--end

-----------------------------------------------------------------------
--- Vip请求
-----------------------------------------------------------------------
function ServerService.VipChargeQuery()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SVipChargeQuery")
    return msg,prototype
end

-----------------------------------------------------------------------
--- Vip购买礼包请求
-----------------------------------------------------------------------
function ServerService.VipDiamondLibaoBuyRequest(vipLevel)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SVipDiamondLibaoBuyRequest")
    msg.vipLevel = vipLevel
    return msg,prototype
end

-----------------------------------------------------------------------
--- 解除装备绑定
-----------------------------------------------------------------------
function ServerService.OnEquipDismissBindRequest(equipUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SEquipDismissBindRequest")
    msg.equipUID = equipUID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 时装升级 
-----------------------------------------------------------------------
function ServerService.OnFashionLevelUpRequest(fashionUID,consumeFashionUIDList)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFashionLevelUpRequest")
    msg.fashionUID = fashionUID
    msg.consumeFashionUIDList = consumeFashionUIDList
    return msg,prototype
end

-----------------------------------------------------------------------
--- 购买体力金币 
-----------------------------------------------------------------------
function ServerService.OnVipBuyTiliCoin(btype)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SVipBuyTiliCoin")
    msg.type = btype
    return msg,prototype
end

-----------------------------------------------------------------------
--- 竞技场里程碑领取奖励
-----------------------------------------------------------------------
function ServerService.OnArenaMilestoneAwardRequest(aid)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SArenaMilestoneAwardRequest")
    msg.aid = aid
    msg.head.sid = aid
    return msg,prototype
end

-----------------------------------------------------------------------
--- 竞技场里程碑Query
-----------------------------------------------------------------------
function ServerService.OnArenaMilestoneQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SArenaMilestoneQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 查看卡牌装备
-----------------------------------------------------------------------
function ServerService.OnCheckPlayerCardWithEquipRequest(playerUID,cardID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCheckPlayerCardWithEquipRequest")
    msg.playerUID = playerUID
    msg.cardID = cardID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 竞技场战报查询
-----------------------------------------------------------------------
function ServerService.OnArenaHistoryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SArenaHistoryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 战斗历史查询
-----------------------------------------------------------------------
function ServerService.OnFightHistoryQuery(historyKey,type)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFightHistoryQuery")
    msg.historyKey = historyKey
    msg.type = type
    return msg,prototype
end

-----------------------------------------------------------------------
--- 翅膀合成
-----------------------------------------------------------------------
function ServerService.OnEquipChibangBuildRequest(chibangID,cardUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SEquipChibangBuildRequest")
    msg.chibangID = chibangID
    msg.cardUID = cardUID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 翅膀升级
-----------------------------------------------------------------------
function ServerService.OnEquipBeishiLevelUpRequest(equipUID,consumeEquipUIDList)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SEquipBeishiLevelUpRequest")
    msg.equipUID = equipUID
    msg.consumeEquipUIDList = consumeEquipUIDList
    return msg,prototype
end

-----------------------------------------------------------------------
--- 翅膀进阶
-----------------------------------------------------------------------
function ServerService.OnEquipChibangColorUpRequest(equipUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SEquipChibangColorUpRequest")
    msg.equipUID = equipUID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 雇佣军Querry
-----------------------------------------------------------------------
function ServerService.OnSProtectGyjQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SProtectGyjQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 雇用 雇佣军
-----------------------------------------------------------------------
function ServerService.OnProtectUseGyjRequest(gyjcardUID,playerID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SProtectUseGyjRequest")
    msg.gyjcardUID = gyjcardUID
    msg.playerID = playerID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 雇佣军阵容操作
-----------------------------------------------------------------------
function ServerService.OnSZhenrongAdjustRequest(itype,cardUID,cardPos,gyjcardPos,sid)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SZhenrongAdjustRequest")
    msg.type = itype
    if #cardPos > 0 then
        msg.cardUID = cardUID
        for i = 1 ,#cardPos do
            msg.cardPos:append(cardPos[i])
        end
    end
    msg.gyjcardPos = gyjcardPos
    msg.head.sid = sid
    return msg,prototype
end

-----------------------------------------------------------------------
--- 公会积分战请求
-----------------------------------------------------------------------
function ServerService.GHPointQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointQueryRequest")
    return msg,prototype
end

function ServerService.GHPointGroupRequest(groupId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointGroupRequest")
    msg.groupId = groupId
    return msg,prototype
end

function ServerService.GHPointBuyChallengeRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointBuyChallengeRequest")
    return msg,prototype
end

function ServerService.GHPointClearCDRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointClearCDRequest")
    return msg,prototype
end

function ServerService.GHPointFightQueryRequest(playerUID,isSeam)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointStartFightRequest")
    msg.playerUID  = playerUID
    msg.isSameGroup  = isSeam
    return msg, prototype
end

function ServerService.GHPointHistoryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointHistoryRequest")
    return msg,prototype
end

function ServerService.GHPointMilestoneAwardRequest(awardId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointMilestoneAwardRequest")
    msg.aid = awardId
    return msg,prototype
end

function ServerService.GHPointTop50QueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointTop50QueryRequest")
    return msg,prototype
end

function ServerService.GHPointMilestoneQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGHPointMilestoneQueryRequest")
    return msg,prototype
end
-----------------------------------------------------------------------
--- 竞技场刷新
-----------------------------------------------------------------------
function ServerService.ArenaRefreshRequest(needType)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SArenaRefreshRequestMessage")
    msg.type = needType
    return msg,prototype
end

--精灵树战报
function ServerService.RobZhanbaoRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SRobZhanbaoRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 好友
-----------------------------------------------------------------------
function ServerService.FriendsQueryRequest(QueryType,playerUid)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SFriendsQueryRequest")
    msg.type = QueryType
    msg.playerUid = playerUid
    return msg,prototype
end

function ServerService.FriendsAddRequest(playerUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendsAddRequest")
    msg.playerUID = playerUID
    return msg,prototype
end

function ServerService.FriendsApplyListRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendsApplyListRequest")
    return msg,prototype
end

function ServerService.RobZhanbaoRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SRobZhanbaoRequest")
    return msg,prototype
end

function ServerService.FriendsDealRequest(playerUID,type)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendsDealRequest")
    msg.playerUID = playerUID
    msg.type = type
    return msg,prototype
end

function ServerService.FriendSearchRequest(playerName)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendSearchRequest")
    msg.playerName = playerName
    return msg,prototype
end

function ServerService.FriendTiliDrawRequest(playerUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendTiliDrawRequest")
    msg.playerUID = playerUID
    return msg,prototype
end

function ServerService.FriendTiliQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendTiliQueryRequest")
    return msg,prototype
end

function ServerService.FriendTiliSendRequest(playerUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendTiliSendRequest")
    msg.playerUID = playerUID
    return msg,prototype
end

function ServerService.FriendsDelRequest(playerUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendsDelRequest")
    msg.playerUID = playerUID
    return msg,prototype
end

--爬塔相关
function ServerService.AddAttributeRequest(needStar,attributeID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SAddAttributeRequest")
    msg.needStar = needStar
    msg.attributeID = attributeID
    return msg,prototype
end

function ServerService.AttributeQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SAttributeQueryRequest")
    return msg,prototype
end

function ServerService.TowerQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STowerQueryRequest")
    return msg,prototype
end

function ServerService.TowerRankQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STowerRankQueryRequest")
    return msg,prototype
end

function ServerService.TowerResetRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STowerResetRequest")
    return msg,prototype
end

function ServerService.TowerSweepRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STowerSweepRequest")
    return msg,prototype
end

function ServerService.BuyBossResetCountRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBuyBossResetCountRequest")
    return msg,prototype
end

function ServerService.FriendsViewListRequest(sid)
     local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SFriendsViewListRequest")
    msg.head.sid = sid
    return msg,prototype
end

function ServerService.BossQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBossQueryRequest")
    return msg,prototype
end

function ServerService.BuyRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBuyRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 邮件一键领取
-----------------------------------------------------------------------
function ServerService.MailDrawAllRequest()
     local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SMailDrawAllRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- VIP充值
-----------------------------------------------------------------------
function ServerService.VipChongZhiQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SVipChongZhiQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 卡牌皮肤背包查询
-----------------------------------------------------------------------
function ServerService.CardSkinBagQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardSkinBagQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 卡牌皮肤查询
-----------------------------------------------------------------------
function ServerService.CardCorrCardSkinInfoQueryRequest(cardId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardCorrCardSkinInfoQueryRequest")
	msg.cardId = cardId
    return msg,prototype
end

-----------------------------------------------------------------------
--- 卡牌皮肤激活
-----------------------------------------------------------------------
function ServerService.CardSkinActivationRequest(fettersId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardSkinActivationRequest")
	msg.fettersId = fettersId
    return msg,prototype
end


-----------------------------------------------------------------------
--- 卡牌皮肤升级
-----------------------------------------------------------------------
function ServerService.CardSkinUpgradeRequest(cardSkinUID,num1,num2,num3,num4)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardSkinUpgradeRequest")
	msg.cardSkinUID = cardSkinUID
	msg.ordExpCardNum = num1
	msg.senExpCardNum = num2
	msg.supExpCardNum = num3
	msg.uitExpCardNum = num4
    return msg,prototype
end

-----------------------------------------------------------------------
--- 卡牌皮肤穿戴
-----------------------------------------------------------------------
function ServerService.CardSkinPutOnRequest(cardUID,cardSkinUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardSkinPutOnRequest")
    msg.cardUID = cardUID
    msg.cardSkinUID = cardSkinUID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 卡牌皮肤卸下
-----------------------------------------------------------------------
function ServerService.CardSkinPutOffRequest(cardUID,cardSkinUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardSkinPutOffRequest")
    msg.cardUID = cardUID
    msg.cardSkinUID = cardSkinUID
    return msg,prototype
end

-----------------------------------------------------------------------
--- 世界boss是否存在
-----------------------------------------------------------------------
function ServerService.WorldBossTotalRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWorldBossTotalRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 世界boss查询
-----------------------------------------------------------------------
function ServerService.WorldBossQueryRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWorldBossQueryRequest")
    return msg,prototype
end



-----------------------------------------------------------------------
--- 世界分享
-----------------------------------------------------------------------
function ServerService.WBossSharerRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWBossSharerRequest")
    return msg,prototype
end
-----------------------------------------------------------------------
--- 世界分享列表
-----------------------------------------------------------------------
function ServerService.WBossListRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWBossListRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 世界Boss 战斗
-----------------------------------------------------------------------
function ServerService.WBossFightStartRequest(type,sharerId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWBossFightStartRequest")
    msg.type = type
    msg.sharerId = sharerId
    return msg,prototype
end


-----------------------------------------------------------------------
--- 世界Boss 战斗结束
-----------------------------------------------------------------------
function ServerService.WBossFightEndRequest(type,sharerId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWBossFightEndRequest")
    msg.type = type
    msg.sharerId = sharerId 
    return msg,prototype
end

-----------------------------------------------------------------------
--- 世界购买次数
-----------------------------------------------------------------------
function ServerService.BuyWBossKeyRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBuyWBossKeyRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 世界购买三倍
-----------------------------------------------------------------------
function ServerService.BuyThreefoldKeyRequest(num)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBuyThreefoldKeyRequest")
    msg.num = num
    return msg,prototype
end


-----------------------------------------------------------------------
--- 探险请求
-----------------------------------------------------------------------
function ServerService.AdvanceAdventureRequest(count)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SAdvanceAdventureRequestMessage")
    msg.count = count
    return msg,prototype
end


-----------------------------------------------------------------------
--- 探险购买次数
-----------------------------------------------------------------------
function ServerService.BuyAdventureTimesRequest(count)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBuyAdventureTimesRequestMessage")
    msg.count = count
    return msg,prototype
end


-----------------------------------------------------------------------
--- 探险开始请求
-----------------------------------------------------------------------
function ServerService.StartAdventureRequest()
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SStartAdventureRequestMessage")
    return msg,prototype
end



-----------------------------------------------------------------------
---体力倒计时
-----------------------------------------------------------------------
function ServerService.TiliCountDownRequest(type)
    debug_print("TiliCountDownRequest",type)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STiliCountDownRequest")
    msg.type = type
    return msg,prototype
end

-----------------------------------------------------------------------
--- 是否是首次改名
-----------------------------------------------------------------------
function ServerService.WhetherTheFirstRenameRequest()
    debug_print("WhetherTheFirstRenameRequest")
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SWhetherTheFirstRenameRequest")
    return msg,prototype
end
--流派请求
function ServerService.GenreQueryRequest()
   
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGenreQueryRequest")
    return msg,prototype
end

-----------------------------------------------------------------------
--- 突破
-----------------------------------------------------------------------
function ServerService.CardBreakRequest(cardId, count, sid)
    debug_print("cardId, count",cardId, count)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SCardBreakRequest")
    msg.cardId = cardId
    msg.count = count
    msg.head.sid = sid
    return msg, prototype
end

--流派请求
function ServerService.BreakGetUserData()
 
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SBreakGetUserData")
    return msg,prototype
end



--达成领取奖励
function ServerService.GenreChangeStateRequest(genreId,awardRankId)
  
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGenreChangeStateRequest")
    msg.genreId = genreId
    msg.awardRankId = awardRankId
    return msg,prototype
end

--限时神降
function ServerService.ActivityGodComingRequest()
   
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("ActivityGodComingRequest")
    return msg,prototype
end

--限时神降1抽
function ServerService.GodChooseOneRequet()
   
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGodChooseOneRequet")
    return msg,prototype
end

--限时神降10抽
function ServerService.GodChooseTenRequest()
   
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SGodChooseTenRequest")
    return msg,prototype
end

-- 塔罗牌数据查询
function ServerService.TarotQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2STarotQueryRequest")
end

-- 塔罗牌激活
function ServerService.TarotCardActiveRequest(tarotId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STarotCardActiveRequest")
    msg.cardId = tarotId
    return msg, prototype
end

-- 进度光环
function ServerService.TarotProgressActiveRequest(progressId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2STarotProgressActiveRequest")
    msg.progressId = progressId
    return msg, prototype
end

--精灵树升级
function ServerService.RobTreeLevelUpRequest()
   
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SRobTreeLevelUpRequest")
    return msg,prototype
end

--精灵树秒蛋
function ServerService.RobBoxSecondKillRequest(repairBoxUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STakeBoxSecondKillRequest")
    msg.repairBoxUID = repairBoxUID
    return msg,prototype
end

--精灵树秒蛋信息
function ServerService.RobBoxSecondKillInfoRequest(repairBoxUID)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2STakeBoxSecondKillInfoRequest")
    msg.repairBoxUID = repairBoxUID
    return msg,prototype
end
--团队天赋
function ServerService.CardTeamTalentChooseRequest(cardUID,teamTalentA,teamTalentB,teamTalentC)
    debug_print("CardTeamTalentChooseRequest")
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardTeamTalentChooseRequest")
    msg.cardUID = cardUID
    msg.teamTalentA = teamTalentA
    msg.teamTalentB = teamTalentB
    msg.teamTalentC = teamTalentC
    return msg,prototype
end

--小宇宙点开启
function ServerService.CardTheSmallUniverseRequest(cardUID, spotId)
	local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SCardTheSmallUniverseRequest")
    msg.cardUID = cardUID
    msg.curLigSpot = spotId
    return msg,prototype
end

--星愿金币抽
function ServerService.StarCoinWishRequest()
	local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SStarCoinWishRequest")
    return msg,prototype
end

--星愿钻石抽
function ServerService.StarDiamondWishRequest()
	local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SStarDiamondWishRequest")
    return msg,prototype
end

--星愿查询
function ServerService.StarQueryRequest()
	local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("C2SStarQueryRequest")
    return msg,prototype
end

--限时兑换
function ServerService.ActivityTimeLimitRefreshRequest(type,activityId)
    debug_print(type,activityId)
    local messageManager = require "Network.MessageManager"
    local msg,prototype = messageManager:CreateMessageByName("ActivityTimeLimitRefreshRequest")
    msg.type = type
    msg.activityId = activityId
    return msg,prototype
end

-- 请求运营活动查询
function ServerService.OperationActicityQueryRequest()
    local messageManager = require "Network.MessageManager"
    return messageManager:CreateMessageByName("C2SOperationActivityQueryRequest")
end

-- 请求选择物品接口
function ServerService.OperationActivityPickItemRequest(activityType, activityId, itemGroupId)
    local messageManager = require "Network.MessageManager"
    local msg, prototype = messageManager:CreateMessageByName("C2SOperationActivityPickItemRequest")
    msg.activityType = activityType
    msg.activityId = activityId
    msg.itemGroupId = itemGroupId
    return msg, prototype
end


return ServerService
