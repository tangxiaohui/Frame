-----------------------------------------------------------------------
--- 业务的网络处理
-----------------------------------------------------------------------
require "Object.LuaObject"

local UserDataType = require "Framework.UserDataType"

local messageGuids = require "Framework.Business.MessageGuids"

local utility = require "Utils.Utility"
local calculateRed = require"Utils.CalculateRed"
    
local GameNetwork = Class(LuaObject)

local InternalUpdateFunctionTable = {}
local InternalBackgroundFunctionTable = {}

-----------------------------------------------------------------------
--- 注册
-----------------------------------------------------------------------
local function RegisterUpdateProtocols(dict)
    local ProtocolId = require "Network.PB.ProtocolId"

    -- # 加载玩家数据
    dict[ProtocolId.SND_ACCOUNT_LOAD_PLAYER_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnLoadPlayerResponse

    -- # 加载卡包数据
    dict[ProtocolId.SND_ZHENRONG_CARD_BAG_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnCardBagQueryResponse

    -- # 更新卡包数据
    dict[ProtocolId.SND_ZHENRONG_CARD_BAG_FLUSH_MESSAGE] = InternalUpdateFunctionTable.OnCardBagFlushResponse

    -- # 加载物品背包数据
    dict[ProtocolId.SND_ITEM_ITEM_BAG_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnItemBagQueryResponse

    -- # 更新物品背包数据
    dict[ProtocolId.SND_ITEM_ITEM_BAG_FLUSH_MESSAGE] = InternalUpdateFunctionTable.OnItemBagFlushResponse

    -- # 加载地图数据
    dict[ProtocolId.SND_FB_F_B_QUERY_ALL_MAP_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnQueryAllMapsResponse

    -- # 购买挑战次数
    dict[ProtocolId.SND_FB_F_B_BUY_CHALLENGE_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnBuyChallengeResponse

    -- # 副本挑战结束
    dict[ProtocolId.SND_FB_F_B_OVER_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnFBOverResponse

    -- # 扫荡
    dict[ProtocolId.SND_FB_F_B_SWEEP_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnSweepResponse

    -- # 领取奖励
    dict[ProtocolId.SND_FB_F_B_DRAW_COMPLETE_AWARD_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnDrawCompleteAwardResponse

    -- * 加载卡牌碎片背包数据
    dict[ProtocolId.SND_ZHENRONG_CARD_SUIPIAN_BAG_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnCardChipBagQueryResponse

      -- * 更新卡牌碎片背包数据
    dict[ProtocolId.SND_ZHENRONG_CARD_SUIPIAN_FLUSH_MESSAGE] = InternalUpdateFunctionTable.OnCardChipBagFlushResponse

    -- & 加载装备包数据
    dict[ProtocolId.SND_EQUIP_EQUIP_BAG_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnEquipBagQueryResponse

    -- & 更新装备包数据
    dict[ProtocolId.SND_EQUIP_EQUIP_BAG_FLUSH_MESSAGE] = InternalUpdateFunctionTable.OnEquipBagFlushResponse

    -- & 加载装备碎片包数据
    dict[ProtocolId.SND_EQUIP_EQUIP_SUIPIAN_BAG_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnEquipDebrisBagQueryResponse

    -- & 更新装备碎片包数据
    dict[ProtocolId.SND_EQUIP_EQUIP_SUIPIAN_BAG_FLUSH_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnEquipDebrisBagFlushResponse

    -- 保护公主
    dict[ProtocolId.SND_PROTECT_PROTECT_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnProtectQueryResponse

    -- 更新红点数据
    dict[ProtocolId.SND_GUIDE_GUIDE_RED_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnRedDotResponse

    -- 加载卡牌皮肤包数据
    dict[ProtocolId.SND_CARDPRO_CARD_SKIN_BAG_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnCardSkinBagQueryResponse

    -- 更新卡牌皮肤包数据
    dict[ProtocolId.SND_CARDPRO_CARD_SKIN_BAG_FLUSH_MESSAGE] = InternalUpdateFunctionTable.OnCardSkinUpdateResponse
    
    --世界boss出现
    dict[ProtocolId.SND_WORLD_BOSS_ACTIVATE_RESULT_MESSAGE] = InternalUpdateFunctionTable.WorldBossActivateResult

    --世界boss是否存在
    dict[ProtocolId.SND_WORLD_BOSS_TOTAL_RESULT_MESSAGE] = InternalUpdateFunctionTable.WorldBossTotalResultMessage

    --塔罗牌数据
    dict[ProtocolId.SND_TAROT_QUERY_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnTarotQueryResponse
    dict[ProtocolId.SND_TAROT_CARD_ACTIVE_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnTarotCardActiveResponse
    dict[ProtocolId.SND_TAROT_PROGRESS_ACTIVE_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnTarotProgressActiveResponse

    -- 跑马灯
    dict[ProtocolId.SND_MARQUEE_RESULT_MESSAGE] = InternalUpdateFunctionTable.OnMarqueeResponse
end

local function RegisterBackgroundProtocols(dict)
    local ProtocolId = require "Network.PB.ProtocolId"

    -- # 注册协议
    dict[ProtocolId.SND_ACCOUNT_LOGIN_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnLoginResponse

    -- # 创建初始卡牌和名字的协议
    dict[ProtocolId.SND_ACCOUNT_CHOOSE_PLAYER_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnChoosePlayerResponse

    -- # 碎片合成
    dict[ProtocolId.SND_CARDPRO_CARD_SUIPIAN_BUILD_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnCardSuipianBuildResponse

    -- # 对话公告协议
    dict[ProtocolId.SND_TALK_TALK_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnTalkMessageResponse

    -- # 错误消息
    dict[ProtocolId.SND_TALK_ERROR_MESSAGE] = InternalBackgroundFunctionTable.OnErrorMessageResponse

    -- # 玩家升级协议
    dict[ProtocolId.SND_ACCOUNT_PLAYER_LEVEL_UP_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnPlayerLevelUpResponse

    -- # 退出协议
    dict[ProtocolId.SND_ACCOUNT_QUIT_GAME_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnQuitGameResponse


    -- # 钻石奖励发送推送
    dict[ProtocolId.SND_ACCOUNT_GAME_REWARD_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnGameRewardResponse

    -- # 钻石消耗发送
    dict[ProtocolId.SND_ACCOUNT_GAME_PURCHASE_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnGameItemPurchaseResponse

    -- # Vip充值成功
    dict[ProtocolId.SND_VIP_VIP_CHARGE_DONE_RESULT] = InternalBackgroundFunctionTable.OnVipChargeDoneResponse

    -- # 活动逐额充值成功
    dict[ProtocolId.SND_VIP_VIP_CHARGE_DONE_DAILY_RESULT] = InternalBackgroundFunctionTable.OnActivityChargeDoneResponse

    -- # 邮箱请求
    dict[ProtocolId.SND_MAIL_MAIL_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnMailResponse

    -- # 邮箱更新
    dict[ProtocolId.SND_MAIL_MAIL_PUSH_RESULT_MESSAGE] = InternalBackgroundFunctionTable.OnMailPushResponse

end

-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

function GameNetwork:PostNotification(name, ...)
    local eventMgr = self.game:GetEventManager()
    eventMgr:PostNotification(name, nil, ...)
end

function GameNetwork:Ctor()
    -- 需要获取子系统
    self.game = utility.GetGame()

    self.updateProtocolDict = {} -- 协议的字典 (intId => function)
    self.backgroundProtocolDict = {} -- 统一处理的字典 (intId => function)

    -- # 注册
    RegisterUpdateProtocols(self.updateProtocolDict)
    RegisterBackgroundProtocols(self.backgroundProtocolDict)
end

function GameNetwork:HandleMsg(id, msg)
    -- 更新数据
    if self.updateProtocolDict[id] ~= nil then
        local func = self.updateProtocolDict[id]
        return func(self, msg)
    end

    -- 后台执行的
    if self.backgroundProtocolDict[id] ~= nil then
        local func = self.backgroundProtocolDict[id]
        return func(self, msg)
    end

    return nil
end


-----------------------------------------------------------------------
--- 数据更新相关协议
-----------------------------------------------------------------------
local function __DelayCloseDataBatcher__(self)
    coroutine.step(1)
    self.networkBatcher:Close()
    self.networkBatcher = nil
    self:PostNotification(messageGuids.LoadAllUserDataFinished)
end

local function __OnLoadAllDataFinished__(self)
    self.isLogined = true
    coroutine.start(__DelayCloseDataBatcher__, self)
    if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)        
    end
end

local function YijieUpdateInfoCheck(self, userData, key)
    local serverId, _,_, serverName = self.game:GetGameServer():GetCurrentServerReadonly()
    self.game:GetSDKManager():UpdateInfoCheck(
        userData:GetId(),
        userData:GetName(),
        userData:GetLevel(),
        serverId,
        serverName,
        userData:GetDiamond(),
        userData:GetVip(),
        userData:GetGuildNameToDisplay(),
        userData:GetCreateTime(),
        userData:GetLastLevelUpTime(),
        key
    )
end

-- @ 新创建的账号
local function OnPlayerCreated(self, userData)
    debug_print("@@新创建的账号@@")
    -- 这个游戏是注册即登录 所以在获取信息后立即发送注册和登录.(热云)
    require "Utils.GameAnalysisUtils".Register()
    require "Utils.GameAnalysisUtils".Login()
    require "Utils.GameTrackIOUtils".Register()
    require "Utils.GameTrackIOUtils".Login()
    YijieUpdateInfoCheck(self, userData, 1)
end

-- @ 旧账号登录(重连)
local function OnPlayerLogined(self, userData)
    debug_print("@@旧账号登录@@")
    require "Utils.GameAnalysisUtils".Login()
    require "Utils.GameTrackIOUtils".Login()
    YijieUpdateInfoCheck(self, userData, 3)
end

-- @ 玩家升级
local function OnPlayerLevelUp(self, userData)
    debug_print("@@账号升级@@")
    YijieUpdateInfoCheck(self, userData, 2)
end

-- @ 数据同步
local function OnPlayerLoaded(self, userData)
    debug_print("@@账号数据同步@@")
    YijieUpdateInfoCheck(self, userData, 0)
end

-- @ 玩家数据更新(可以处理自定义事件代码)
local function OnPlayerUpdated(self, userData)
    require "Utils.GameAnalysisUtils".RecordLocalAction(kTrackingId_LoginAction)
end

local function UpdateElvenTreePropertyCache(self)
    local dataCacheMgr = self.game:GetDataCacheManager()
    local cardBagData = dataCacheMgr:GetData(UserDataType.CardBagData)
    if cardBagData ~= nil then
        cardBagData:UpdateElvenTreeCache()
    end
end

-- # 加载玩家数据
function InternalUpdateFunctionTable.OnLoadPlayerResponse(self, msg)
    -- 同步 玩家数据 --
    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.PlayerData, function(oldData)
        require "Data.UserData"
        if oldData == nil then
            oldData = UserData.New()
        end
        oldData:SetBaseInfo(msg.roleBaseInfo)
        return oldData
    end)

    UpdateElvenTreePropertyCache(self)

    -- 玩家数据 本地通知 --
    local updatedUserData = dataCacheMgr:GetData(UserDataType.PlayerData)
    self:PostNotification(messageGuids.UpdatedPlayerData, updatedUserData)
   

    if self.isNewUser then
        -- @ 新号
        self.isNewUser = nil
        OnPlayerCreated(self, updatedUserData)
    elseif not self.isLogined then
        -- @ 登录
        OnPlayerLogined(self, updatedUserData)
    elseif updatedUserData:IsLevelUp() then
        -- @ 升级
        OnPlayerLevelUp(self, updatedUserData)
    else
        -- @ 数据同步
        OnPlayerLoaded(self, updatedUserData)
    end

    -- 更新统计 --
    OnPlayerUpdated(self, updatedUserData)
     hzj_print("OnLoadPlayerResponse", self.isLogined)
    if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)        
    end
    return nil  -- 这个消息分发给上层!!
end

--世界boss是否存在查询
function InternalUpdateFunctionTable.WorldBossTotalResultMessage(self, msg)
    debug_print("世界boss是否存在查询")

    local dataCacheMgr = self.game:GetDataCacheManager()

    local sharerIds = msg.sharerId

    dataCacheMgr:UpdateData(UserDataType.WorldBossData, function(oldData)
        require "Data.WorldBossData"
        if oldData == nil then
            oldData = WorldBossData.New()
        end
        oldData:SetAllData(sharerIds)
        return oldData
    end)

    return nil -- 这个消息分发给上层!!



end

--世界boss出现
function InternalUpdateFunctionTable.WorldBossActivateResult(self, msg)
    debug_print("++++++++++++++++++++++++++++世界boss出现++++++++++++++++++++++")

    local dataCacheMgr = self.game:GetDataCacheManager()
    local sharerId = msg.sharerId
    if msg.type==1 then        
        if  msg.myself then
            debug_print("自己的boss出现",msg.bossId)
            local windowManager = self.game:GetWindowManager()  
            --表示是第四个
            windowManager:Show(require"GUI.Boss.WorldBossShow",msg.bossId)
        else
            debug_print("别人的boss出现")

       end

      
        dataCacheMgr:UpdateData(UserDataType.WorldBossData, function(oldData)
            require "Data.WorldBossData"
            if oldData == nil then
                debug_print("oldData == nil")
                oldData = WorldBossData.New()
            end
            oldData:AddData(sharerId)
            return oldData
        end)
    elseif msg.type==2 then
        debug_print("boss消失")

        dataCacheMgr:UpdateData(UserDataType.WorldBossData, function(oldData)
        require "Data.WorldBossData"
        if oldData == nil then
            oldData = WorldBossData.New()
        end
        oldData:RemoveData(sharerId)
        return oldData

        end)

    end




end

-- # 卡包整体更新
function InternalUpdateFunctionTable.OnCardBagQueryResponse(self, msg)
    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    local cards = msg.cards

    dataCacheMgr:UpdateData(UserDataType.CardBagData, function(oldData)
        require "Data.CardBagData"
        if oldData == nil then
            oldData = CardBagData.New()
        end

        oldData:SetAllData(cards)

        return oldData
    end)
     hzj_print("OnCardBagQueryResponse", self.isLogined)
    if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end

    return nil -- 这个消息分发给上层!!
end

-- # 卡包单卡更新
function InternalUpdateFunctionTable.OnCardBagFlushResponse(self, msg)
    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    local oneCard = msg.card

    dataCacheMgr:UpdateData(UserDataType.CardBagData, function(oldData)
        require "Data.CardBagData"
        if oldData == nil then
            oldData = CardBagData.New()
        end

        local mode = msg.mod

        local S2CCardBagFlush = require "Network.PB.S2CCardBagFlush"

        if mode == S2CCardBagFlush.add or mode == S2CCardBagFlush.shizhuangAdd then
            -- 增加卡牌处理
            local newCard = oldData:Update(oneCard, true)
            self:PostNotification(messageGuids.AddedOneCard, newCard)
        elseif mode == S2CCardBagFlush.update then
            -- 更新卡牌处理
            local updatedCard = oldData:Update(oneCard, true)
            self:PostNotification(messageGuids.UpdatedOneCard, updatedCard)
        else
            -- 移除卡牌处理
            local removedCard = oldData:Remove(oneCard.uid)
            if removedCard ~= nil then
                self:PostNotification(messageGuids.RemovedOneCard, removedCard)
            end
        end

        return oldData
    end)
    hzj_print("OnCardBagFlushResponse", self.isLogined)
    if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end

--    print('uid', oneCard.cardUID, 'id', oneCard.cardID, 'pos', oneCard.cardPos[1], 'name', oneCard.cardName)

    return nil -- 这个消息分发给上层!!
end

-- # 物品背包整体更新
function InternalUpdateFunctionTable.OnItemBagQueryResponse(self, msg)
    -- 同步 物品背包数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.ItemBagData, function(oldData)
        require "Data.Item.ItemBagData"
        if oldData == nil then
            oldData = ItemBagData.New()
        end

        oldData:SetAllData(msg.items)

        return oldData
    end)
   if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
    return nil  -- 这个消息分发给上层!!
end

-- # 物品背包单个更新
function InternalUpdateFunctionTable.OnItemBagFlushResponse(self, msg)
    print('>>>>>>>>>> OnItemBagFlushResponse <<<<<<<<<<<<')

    -- 同步 物品背包数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.ItemBagData, function(oldData)
        require "Data.Item.ItemBagData"
        if oldData == nil then
            oldData = ItemBagData.New()
        end

        local item = msg.item
        local mode = msg.mod

        print('>>>>>>>>>>>>>>>>', 'mode', mode, item.itemID, item.itemNum, item.itemUID)

        local S2CItemBagFlush = require "Network.PB.S2CItemBagFlush"

        if mode == S2CItemBagFlush.add then
            
            local itemData = oldData:Update(item)
            self:PostNotification(messageGuids.AddedOneItem, itemData)
        elseif mode == S2CItemBagFlush.update then

            local itemData = oldData:Update(item)
            self:PostNotification(messageGuids.UpdatedOneItem, itemData)
        elseif mode == S2CItemBagFlush.del then
            
            local itemData = oldData:Remove(item.itemUID)
            if itemData ~= nil then            
                self:PostNotification(messageGuids.RemovedOneItem, itemData)
            end
        end
        print("物品吧更新了 Network")
        return oldData
    end)
       if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end

    return nil  -- 这个消息分发给上层!!
end

-- # 查询地图数据(更新所有)
function InternalUpdateFunctionTable.OnQueryAllMapsResponse(self, msg)
    local maps = msg.mapInfo

    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.PlayerChapterData, function(oldData)
        require "Data.Chapter.PlayerChapterData"
        if oldData == nil then
            oldData = PlayerChapterData.New()
        end
        oldData:SetAllData(maps)

        self:PostNotification(messageGuids.UpdatedAllMapData, oldData)

        return oldData
    end)

    return nil -- 这个消息分发给上层!!
end

function InternalUpdateFunctionTable.OnBuyChallengeResponse(self, msg)

    local fbItem = msg.fbItem

    -- 同步 玩家章节关卡数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.PlayerChapterData, function(oldData)
        require "Data.Chapter.PlayerChapterData"

        oldData:UpdateExistingLevel(fbItem, msg.mapID)

        return oldData
    end)


    return nil -- 这个消息分发给上层!!
end

function InternalUpdateFunctionTable.OnFBOverResponse(self, msg)

    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.PlayerChapterData, function(oldData)
        if oldData == nil then
            require "Data.Chapter.PlayerChapterData"
            oldData = PlayerChapterData.New()
        end
        oldData:UpdateFBOver(msg)

        return oldData
    end)
	--是否显示黑市
	if msg.showHeishi then
		local windowManager = utility.GetGame():GetWindowManager()
		windowManager:Show(require "GUI.BlackMarket.BlackMarket")
	-- 	self:ShopHeishiQueryRequest()
	end
    return nil -- 这个消息分发给上层!!
end

function InternalUpdateFunctionTable:ShopHeishiQueryRequest()
	--黑市Query请求
	self:GetGame():SendNetworkMessage( require "Network/ServerService".ShopHeishiQueryRequest())
end

function InternalUpdateFunctionTable.OnSweepResponse(self, msg)

    -- 同步 玩家章节关卡数据
    local fbItem = msg.fbItem

    -- TODO 隐藏副本信息

    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.PlayerChapterData, function(oldData)
        --require "Data.Chapter.PlayerChapterData"

        oldData:UpdateExistingLevel(fbItem, msg.mapID)

        return oldData
    end)

    return nil -- 这个消息分发给上层!!
end

function InternalUpdateFunctionTable.OnDrawCompleteAwardResponse(self, msg)
    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.PlayerChapterData, function(oldData)
        oldData:UpdateExistingChapterStage(msg)
        return oldData
    end)

    return nil -- 这个消息分发给上层!!
end

-- # 卡碎片包整体更新
function InternalUpdateFunctionTable.OnCardChipBagQueryResponse(self, msg)
    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    local cardChips = msg.cardSuipian

    dataCacheMgr:UpdateData(UserDataType.CardChipBagData, function(oldData)
        require "Data.CardChipBag.CardChipBagData"
        if oldData == nil then
            oldData = CardChipBagData.New()
        end

        oldData:SetAllData(cardChips)

        return oldData
    end)
   if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
    return nil -- 这个消息分发给上层!!
end

-- # 卡牌碎片背包单个更新
function InternalUpdateFunctionTable.OnCardChipBagFlushResponse(self, msg)
    -- 同步 卡牌碎片背包数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.CardChipBagData, function(oldData)
        require "Data.CardChipBag.CardChipBagData"
        if oldData == nil then
            oldData = CardChipBagData.New()
        end

        local cardSuipian = msg.cardSuipian
        local mode = msg.mod

        local S2CCardSuipianFlush = require "Network.PB.S2CCardSuipianFlush"

        if mode == S2CCardSuipianFlush.del or mode == S2CCardSuipianFlush.shizhuangDel then
            -- 删除卡牌碎片时的处理
            local removedCard = oldData:Remove(cardSuipian.cardSuipianID)
            if removedCard ~= nil then
                print("removed >>>")
                self:PostNotification(messageGuids.RemovedOneCardCrap, removedCard)
            end
        else
            -- 添加或更新
            local cardData = oldData:UpdateData(cardSuipian)

            if mode == S2CCardSuipianFlush.add or mode == S2CCardSuipianFlush.shizhuangAdd then
                -- > 添加
                print("added >>>")
                self:PostNotification(messageGuids.AddedOneCardCrap, cardData)
            else
                -- > 更新
                print("updated >>>")
                self:PostNotification(messageGuids.UpdatedOneCardCrap, cardData)
            end
        end
        
        return oldData
    end)
   if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
   return nil  -- 这个消息分发给上层!!
end

-- # 装备包整体更新
function InternalUpdateFunctionTable.OnEquipBagQueryResponse(self, msg)
    print("-------装备包整体更新----------")
    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    local equips = msg.equips

    dataCacheMgr:UpdateData(UserDataType.EquipBagData, function(oldData)
        require "Data.EquipBag.EquipBagData"
        if oldData == nil then
            oldData = EquipBagData.New()
        end

        oldData:SetAllData(equips)

        return oldData
    end)
   if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
    return nil -- 这个消息分发给上层!!
end

-- # 装备背包单个更新
function InternalUpdateFunctionTable.OnEquipBagFlushResponse(self, msg)
    -- 同步 装备背包数据
    print("-------装备背包单个更新----------")
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.EquipBagData, function(oldData)
        require "Data.EquipBag.EquipBagData"
        if oldData == nil then
            oldData = EquipBagData.New()
        end

        local equip = msg.equip
        local mode = msg.mod

        local S2CEquipBagFlush = require "Network.PB.S2CEquipBagFlush"
       
        if mode == S2CEquipBagFlush.add then

            local equipData = oldData:UpdateData(equip)
            self:PostNotification(messageGuids.AddedOneEquip, equipData)
        elseif mode == S2CEquipBagFlush.update then
            
            local equipData = oldData:UpdateData(equip)
            self:PostNotification(messageGuids.UpdetedOneEquip, equipData)
        else
            
            local equipData = oldData:Remove(equip.equipUID)
            if equipData ~= nil then
                self:PostNotification(messageGuids.RemovedOneEquip, equipData)
            end            
        end
        
        return oldData
    end)   
    if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end

   return nil  -- 这个消息分发给上层!!
end


-- # 装备碎片包整体更新
function InternalUpdateFunctionTable.OnEquipDebrisBagQueryResponse(self, msg)
    print("-------装备碎片包整体更新----------")
    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    local equipDebriss = msg.suipians

    dataCacheMgr:UpdateData(UserDataType.EquipDebrisBag, function(oldData)
        require "Data.EquipBag.EquipDebrisBagData"
        if oldData == nil then
            oldData = EquipDebrisBagData.New()
        end

        oldData:SetAllData(equipDebriss)

        return oldData
    end)
   if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
    return nil -- 这个消息分发给上层!!
end

-- # 装备碎片背包单个更新
function InternalUpdateFunctionTable.OnEquipDebrisBagFlushResponse(self, msg)
    -- 同步 装备背包数据
    print("-------装备碎片背包单个更新----------")
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.EquipDebrisBag, function(oldData)
        require "Data.EquipBag.EquipDebrisBagData"
        if oldData == nil then
            oldData = EquipDebrisBagData.New()
        end

        local equipSuipian = msg.equipSuipian
        local mode = msg.mod

        local S2CEquipSuipianBagFlushResult = require "Network.PB.S2CEquipSuipianBagFlushResult"
        if mode == S2CEquipSuipianBagFlushResult.add then

            local debrisData = oldData:UpdateData(equipSuipian)
            self:PostNotification(messageGuids.AddedOneEquipDebris, removedCard)
        elseif mode == S2CEquipSuipianBagFlushResult.update then
            
            local debrisData = oldData:UpdateData(equipSuipian)
            self:PostNotification(messageGuids.UpdetedOneEquipDebris, removedCard)
        else
            
            local debrisData = oldData:Remove(equipSuipian.equipSuipianID)
            if debrisData ~= nil then
                self:PostNotification(messageGuids.RemovedOneEquipDebris, removedCard)
            end
        end
        
        return oldData
    end)   
    if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end

   return nil  -- 这个消息分发给上层!!
end

-- 卡牌皮肤包整体更新
function InternalUpdateFunctionTable.OnCardSkinBagQueryResponse(self, msg)
    -- 同步 玩家数据
    local dataCacheMgr = self.game:GetDataCacheManager()
    local cards = msg.cards

    dataCacheMgr:UpdateData(UserDataType.CardSkinsData, function(oldData)
        local CardSkinBagData = require "Data.CardSkinBag.CardSkinBagData"
        if oldData == nil then
            oldData = CardSkinBagData.New()
        end

        oldData:SetAllData(cards)

        return oldData
    end)
       if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
    return nil -- 这个消息分发给上层!!
end

-- 卡牌皮肤包单个更新
function InternalUpdateFunctionTable.OnCardSkinUpdateResponse(self, msg)
    -- 同步 皮肤背包数据
    local dataCacheMgr = self.game:GetDataCacheManager()

    dataCacheMgr:UpdateData(UserDataType.CardSkinsData, function(oldData)
        local CardSkinBagData = require "Data.CardSkinBag.CardSkinBagData"
        if oldData == nil then
            oldData = CardSkinBagData.New()
        end

        local cardSkinData,skinData = oldData:UpdateData(msg.cards)
        self:PostNotification(messageGuids.CardSkinUpdate, cardSkinData,skinData)        
        return oldData
    end)
   if self.isLogined  then
        calculateRed.CalculateAllRoleRed()
        self:PostNotification(messageGuids.LocalRedDotChanged)
    end
   return nil  -- 这个消息分发给上层!!
end

-- 更新红点数据
function InternalUpdateFunctionTable.OnRedDotResponse(self, msg)
    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.RedDotData, function(oldData)
        require "Data.RedDotData"
        if oldData == nil then
            oldData = RedDotData.New()
        end
        
        -- 模块
        local modules = msg.modules

        -- 模块红点状态
        local moduleRedState = msg.red

        -- 卡牌
        local cardUIDs = msg.cardUID

        -- 卡牌红点状态
        local cardRedState = msg.cardRedState

        -- 更新成就
		oldData:SetChengjiuInfo(msg.chengjiu)
		oldData:SetCollectionCardInfo(msg.tujianCard)
		oldData:SetCollectionEquipInfo(msg.tujianEquip)
		oldData:SetActiveInfo(msg.huodong)
        debug_print(#msg.sevenDay)
		oldData:SetSevenDayInfo(msg.sevenDay)

        -- 发送成就红点
		self:PostNotification(messageGuids.ModuleRedDotChanged, msg.chengjiu)
		self:PostNotification(messageGuids.ModuleRedDotChanged, msg.tujianCard)
		self:PostNotification(messageGuids.ModuleRedDotChanged, msg.tujianEquip)
		self:PostNotification(messageGuids.ModuleRedDotChanged, msg.huodong)
		self:PostNotification(messageGuids.ModuleRedDotChanged, msg.sevenDay)
        -- 更新 & 发送模块红点状态变更消息
        for i = 1, #modules do
            if oldData:UpdateOneModuleRed(modules[i], moduleRedState[i]) then
                -- debug_print("-------红点更新 module----------", modules[i], moduleRedState[i])
                --print(modules[i])
                --print(moduleRedState[i])
                self:PostNotification(messageGuids.ModuleRedDotChanged, modules[i], moduleRedState[i])
            end
        end

        -- 更新 & 发送卡牌红点状态变更消息
        for i = 1, #cardUIDs do
            if oldData:UpdateOneCardRed(cardUIDs[i], cardRedState[i]) then
                self:PostNotification(messageGuids.CardRedDotChanged, cardUIDs[i], cardRedState[i])
            end
        end

        return oldData
    end)

    return nil
end

-- # 保护公主 (已废弃)
function InternalUpdateFunctionTable.OnProtectQueryResponse(_, _)
    return nil
end


local function GetTestData()
    local msg = {}
    msg.progressId = 1
    msg.cards = {}
    msg.cards[1] = {id = 0, flags = 1}
    msg.cards[2] = {id = 1, flags = 2}
    msg.cards[3] = {id = 2, flags = 1}
    return msg
end

local function UpdateRoleTarotCache(self)
    local dataCacheMgr = self.game:GetDataCacheManager()
    local cardBagData = dataCacheMgr:GetData(UserDataType.CardBagData)
    if cardBagData ~= nil then
        cardBagData:UpdateTarotCache()
    end
end

-- # 塔罗牌数据
function InternalUpdateFunctionTable.OnTarotQueryResponse(self, msg)
    -- msg = GetTestData()
    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.TarotData, function(oldData)
        if oldData == nil then
            oldData = require "Data.Tarot.TarotData".New()
        end
        oldData:UpdateAll(msg)
        return oldData
    end)
    UpdateRoleTarotCache(self)
    return nil
end

-- # 塔罗牌激活
function InternalUpdateFunctionTable.OnTarotCardActiveResponse(self, msg)
    if msg.success then
        -- 更新数据
        local dataCacheMgr = self.game:GetDataCacheManager()
        local tarotData = dataCacheMgr:GetData(UserDataType.TarotData)
        tarotData:UpdateTarotCard(msg)
        UpdateRoleTarotCache(self)
    end
    -- 发送消息
    self:PostNotification(messageGuids.TarotCardStateChanged, msg)
end

-- # 进度光环激活
function InternalUpdateFunctionTable.OnTarotProgressActiveResponse(self, msg)
    if msg.success then
        -- 更新数据
        local dataCacheMgr = self.game:GetDataCacheManager()
        local tarotData = dataCacheMgr:GetData(UserDataType.TarotData)
        tarotData:UpdateTarotProgress(msg)
        UpdateRoleTarotCache(self)
    end
    -- 发送消息
    self:PostNotification(messageGuids.TarotProgressChanged, msg)
end

-- # 跑马灯消息
function InternalUpdateFunctionTable.OnMarqueeResponse(self, msg)
    self:PostNotification(messageGuids.SendMarquee, msg)
    return true
end

-----------------------------------------------------------------------
--- 背景执行相关协议
-----------------------------------------------------------------------

-- # 登录
function InternalBackgroundFunctionTable.OnLoginResponse(self, msg)
    -- 先切换到主界面 --
    local sceneManager = self.game:GetSceneManager()

    local result = msg.result

    if result == 0 then
        self.isLogined = nil

        -- 批量请求 --
        self.networkBatcher = utility.LoadAllUserData(self, __OnLoadAllDataFinished__)
        self.networkBatcher:Start()
    elseif result == 3 then
        -- 跳转到新角色注册页面!! --
        local playerCreatedClass = require "Scenes.PlayerCreated"
        sceneManager:ReplaceScene(playerCreatedClass.New())
    else
        -- 错误!!
        print('error code: ', result)
    end
end

function InternalBackgroundFunctionTable.OnChoosePlayerResponse(self, msg)
    --0=success;1=other error
    if msg.state == 0 then
        -- 注册完毕
        self.isNewUser = true
        -- 批量请求 --
        self.networkBatcher = utility.LoadAllUserData(self, __OnLoadAllDataFinished__)
        self.networkBatcher:Start()
    else
        print('state:', msg.state)
    end
    return nil
end

function InternalBackgroundFunctionTable.OnCardSuipianBuildResponse(self, msg)
    local roleID = require "StaticData.RoleCrap":GetData(msg.cardSuipianID):GetRoleId()
    local cardDrawHeroShowClass = require "GUI.GeneralCard.GetCardWin"
    require "Collection.OrderedDictionary"
    local windowManager = self.game:GetWindowManager()
    local dict = OrderedDictionary.New()
    dict:Add(roleID, true)
    windowManager:Show(cardDrawHeroShowClass, roleID, dict)
    return true
end

local function SetChatData(self,msg)
    if not (msg.retState == require "Network.PB.S2CTalkResult".success) then
        return
    end
    local UserDataType = require "Framework.UserDataType"
    local dataCacheMgr = self.game:GetDataCacheManager()
    dataCacheMgr:UpdateData(UserDataType.ChatMessageData, function(oldData)
        require "Data.ChatMessageCache"
        if oldData == nil then
            oldData = ChatMessageCache.New()
        end
        oldData:AddMessage(msg)
        return oldData
        end)
end

-- # 对话公告
function InternalBackgroundFunctionTable.OnTalkMessageResponse(self, msg)
    SetChatData(self,msg)
    local eventMgr = self.game:GetEventManager()
    eventMgr:PostNotification('ChangeChatMessage', nil, msg)
    -- # 跑马灯和聊天拆分了, 4这个类型不再使用!
    -- for i = 1 , #msg.msgItem do
    --     if msg.msgItem[i].type == 4 then
    --         eventMgr:PostNotification('PlayNoticeRoll', nil, msg)
    --         return true
    --     end
    -- end
end

-- # 错误消息
function InternalBackgroundFunctionTable.OnErrorMessageResponse(self, msg)
	local serverData = require "StaticData.Server.ServerString":SafeGetData(msg.msgId)
	if serverData ~= nil then
		local content = serverData:GetContent()
		if type(msg.param) == "table" and #msg.param > 0 then
			content = System.String.Format(content, unpack(msg.param))
		end
		utility.ShowErrorDialog(content)
	else
		utility.ShowErrorDialog(msg.msgId)
	end
    return true
end

-- # 玩家升级协议
function InternalBackgroundFunctionTable.OnPlayerLevelUpResponse(self, msg)

end

-- # 退出协议
function InternalBackgroundFunctionTable.OnQuitGameResponse(self, _)
    utility.ShowErrorDialog("退出了游戏, 还没处理重连")
end

-- # 钻石奖励发送推送
function InternalBackgroundFunctionTable.OnGameRewardResponse(self, msg)
    require "Utils.GameAnalysisUtils".Reward(msg.id, msg.reason, msg.virtualCurrencyAmount)
end

-- # 钻石消耗发送
function InternalBackgroundFunctionTable.OnGameItemPurchaseResponse(self, msg)
    require "Utils.GameAnalysisUtils".Consume(msg.item, msg.itemNumber, msg.priceInVirtualCurrency)
end

-- # Vip充值完成(普通充值)
local function GetRechargeTipText(msg)
	if msg.success then
        local data = require "StaticData.Activity.RechargeSDK":GetData(msg.chargeId)
        local rechargeType = data:GetRechargeType()

        local tip = "恭喜您, 成功购买了 %s!"

        if rechargeType == 2 then
            if msg.diamond == data:GetFirstDiamond() then
                tip = tip .. string.format("\n(首次购买获得 %d 钻石)", msg.diamond)
            end
        end

        return string.format(tip, data:GetName())
	else
		return string.format("很遗憾, 充值失败了\n您的订单号是: %s\n请您联系游戏客服为您处理(QQ群:373813529)", msg.orderID)
	end
end

local function FinishRechargePayment(msg)
    if msg.success then
        local data = require "StaticData.Activity.RechargeSDK":GetData(msg.chargeId)
        require "Utils.GameAnalysisUtils".EndPayment(msg.orderID, data:GetPrice()/100, msg.diamond, data:GetName(), 1)
        require "Utils.GameTrackIOUtils".EndPayment(msg.orderID, data:GetPrice()/100)
    end
end

function InternalBackgroundFunctionTable.OnVipChargeDoneResponse(self, msg)
    FinishRechargePayment(msg)
    utility.ShowErrorDialog(GetRechargeTipText(msg))
end

local function FinishActivityChargePayment(msg)
    if msg.success then
        local data = require "StaticData.Activity.topupActivity":GetData(msg.tabId)
        require "Utils.GameAnalysisUtils".EndPayment(msg.orderID, data:GetPrice()/100, msg.getDiamNum, data:GetName(), 1)
        require "Utils.GameTrackIOUtils".EndPayment(msg.orderID, data:GetPrice()/100)
    end
end

function InternalBackgroundFunctionTable.OnActivityChargeDoneResponse(self, msg)
    FinishActivityChargePayment(msg)
end

function InternalBackgroundFunctionTable.OnMailResponse(self, msg)
    debug_print("@@@@@ 邮件整体刷新!")
    for i = 1, #msg.mailItems do
        local curMailItem = msg.mailItems[i]
        debug_print("title", curMailItem.title, "msg", curMailItem.msg)
    end
    return nil
end

function InternalBackgroundFunctionTable.OnMailPushResponse(self, msg)
    debug_print("@@@@@ 新邮件推送")
    for i = 1, #msg.mailItems do
        local curMailItem = msg.mailItems[i]
        debug_print("title", curMailItem.title, "msg", curMailItem.msg)
    end
    return nil
end

return GameNetwork

