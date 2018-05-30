
local WindowNodeClass = require "Framework.Base.WindowNode"
local windowUtility = require "Framework.Window.WindowUtility"
local utility = require "Utils.Utility"

require "Collection.DataStack"
require "Collection.DataQueue"

require "Const"

require "LUT.StringTable"

local CheckpointFightModule = Class(WindowNodeClass)

-- # 设置为唯一
windowUtility.SetMutex(CheckpointFightModule, true)

function CheckpointFightModule:Ctor()
    self.awardItemPool = DataStack.New()
    self.awardItemList = DataQueue.New()
end

function CheckpointFightModule:OnInit()
    -- 加载 登录界面
    utility.LoadNewGameObjectAsync('UI/Prefabs/CheckpointFight', function(go)
        self:BindComponent(go)
    end)
end

-- 指定为Module层!
function CheckpointFightModule:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function CheckpointFightModule:OnWillShow(levelData)
    self.levelData = levelData
end

function CheckpointFightModule:OnComponentReady()
    self:InitControls()
end

local function SpawnAwardList(self)
    local rewardIds = self.levelData:GetRewardIds()
    local rewardCount = rewardIds.Count

    local GeneralItemClass = require "GUI.Item.GeneralItem"

    for i = 0, rewardCount - 1 do

        local currentId = rewardIds:get_Item(i)
        if currentId > 0 then

            -- 处理
            local currentItem = self.awardItemPool:Pop()
            if currentItem == nil then
                currentItem = GeneralItemClass.New(self.AwardListTrans, currentId, 1)
            end

            self:AddChild(currentItem)

            -- 加入!
            self.awardItemList:Enqueue(currentItem)
        end
    end
end

local function UnspawnAwardList(self)
    self.awardItemList:Foreach(function(item)
        self:RemoveChild(item)
        item:UnlinkComponent(self.AwardListPoolTrans)
    end)
end

function CheckpointFightModule:OnResume()
    CheckpointFightModule.base.OnResume(self)
    self:RegisterControlEvents()
    self:RegisterNetworkEvents()

    self:Refresh()

    SpawnAwardList(self)

	
	local guideMgr = utility.GetGame():GetGuideManager()
    self:FadeIn(function(self, t, finished)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)
        transform.localScale = Vector3(s, s, s)
		
		if finished then
			-- 新手引导
			guideMgr:AddGuideEvnt(kGuideEvnt_Challenge1stDungeon)
            guideMgr:AddGuideEvnt(kGuideEvnt_2ndFBLevelInfoFight)
            guideMgr:AddGuideEvnt(kGuideEvnt_3rdFBLevelInfoFight)
			guideMgr:SortGuideEvnt()
			guideMgr:ShowGuidance()
		end
		
    end)
	
    -- print("fight button position1:", tostring(self.CheckpointFightButton.transform.position))
end

local function SetStarStatus(self, image, active)
    if active then
        image.sprite = self.starLightSprite
    else
        image.sprite = self.starGraySprite
    end
end

local function ClearStarStatus(self, image)
    image.sprite = nil
end

-- 根据扫荡券可以扫荡的次数
local function GetSweepCardCount(self)
    local UserDataType = require "Framework.UserDataType"
    local itemCardData = self:GetCachedData(UserDataType.ItemBagData)
    return itemCardData:GetItemCountById(kItemId_SweepCard)
end

-- 当前关卡还剩可以扫荡的次数
local function GetLevelRemainingTimes(self)
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    return playerChapterData:GetLevelRemainingTimes(self.levelData:GetChapterId(), self.levelData:GetId())
end

-- 根据体力可以扫荡的次数
local function GetVigorRemainingTimes(self)
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local vigor = userData:GetVigor()
    return utility.ToInteger(vigor / self.levelData:GetVigorToConsume())
end

-- 根据钻石可以扫荡的次数
local function GetDiamondRemainingTimes(self)
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    local diamond = userData:GetDiamond()
    return utility.ToInteger(diamond / 5)
end

-- 实际可扫荡的次数
local function GetAvailableTimes(self)
    local levelRemainingTimes = GetLevelRemainingTimes(self)
    local vigorRemainingTimes = GetVigorRemainingTimes(self)
    local sweepCards = GetSweepCardCount(self)
    local diamondRemainingTimes = GetDiamondRemainingTimes(self)
    --实际可扫荡的次数 = min(根据体力可以扫荡的次数, min(今天还剩可以扫荡的次数, max(根据扫荡券可以扫荡的次数, 根据钻石可以扫荡的次数)))
    return math.min(math.min(vigorRemainingTimes, levelRemainingTimes), math.max(sweepCards, diamondRemainingTimes))
end

-- 获得原因
local function GetAvailableTimesWithErrorReason(self)
    local remainingTimes = GetAvailableTimes(self)
    if remainingTimes > 0 then
        return true, remainingTimes
    end

    -- 因为关卡没有次数导致失败
    local levelRemainingTimes = GetLevelRemainingTimes(self)
    if levelRemainingTimes <= 0 then
        return false, SweepStringTable[5]
    end

    -- 因为体力没有次数导致失败
    local vigorRemainingTimes = GetVigorRemainingTimes(self)
    if vigorRemainingTimes <= 0 then
        return false, SweepStringTable[7]
    end

    -- -- 因为扫荡卡没有了导致的失败(这个不用判断, 因为没有扫荡卡, 可以用钻石来补)
    -- local sweepCards = GetSweepCardCount(self)
    -- if sweepCards <= 0 then
    --     return false, "NO SWEEP CARD"
    -- end 

    -- 因为没有钻石导致的失败
    local diamondRemainingTimes = GetDiamondRemainingTimes(self)
    if diamondRemainingTimes <= 0 then
        return false, SweepStringTable[8]
    end

    return false, SweepStringTable[2]
end

function CheckpointFightModule:Refresh()
    utility.ASSERT(self.levelData ~= nil, 'levelData必须有效!')

--    self.CheckpointFightNameLabel.text = string.format("%s - %d", self.levelData:GetLevelInfo():GetName(), self.levelData:GetId())
    self.CheckpointFightNameLabel.text = self.levelData:GetLevelInfo():GetName()

    self.CheckpointFightInformationLabel.text = self.levelData:GetLevelInfo():GetDesc()

    self.CheckpointFightTiLiNumLabel.text = self.levelData:GetVigorToConsume()

    -- 卷轴卡 --
    self.sweepCardNumLabel.text = GetSweepCardCount(self)

    -- 当前关卡还剩几次可以重置
    local levelRemainingTimes = GetLevelRemainingTimes(self)

    -- 只有小于等于0 才显示
    self.ResetButtonObject:SetActive(levelRemainingTimes <= 0)

    self.CheckpointFightTimesNumLabel.text = string.format("%d/%d",
        levelRemainingTimes,
        self.levelData:GetMaxAvailableTimes()
    )

    -- 判断星级 --
    if not self:HasStarControl() then
        self.starLayoutObject:SetActive(false)
        self.CheckpointFightRaidButtonObject:SetActive(false)
        self.CheckpointFightRaid5TimesButtonObject:SetActive(false)
        ClearStarStatus(self, self.starObjectImages[1])
        ClearStarStatus(self, self.starObjectImages[2])
        ClearStarStatus(self, self.starObjectImages[3])
        return
    end

    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local star = playerChapterData:GetLevelStar(self.levelData:GetChapterId(), self.levelData:GetId())
    SetStarStatus(self, self.starObjectImages[1], star >= 1)
    SetStarStatus(self, self.starObjectImages[2], star >= 2)
    SetStarStatus(self, self.starObjectImages[3], star >= 3)
    self.starLayoutObject:SetActive(true)
    self.CheckpointFightRaidButtonObject:SetActive(true)
    self.CheckpointFightRaid5TimesButtonObject:SetActive(true)



    self.CheckpointFightRaidText.text = SweepStringTable[0]


    -- 按钮上要显示副本剩余次数
    if levelRemainingTimes > 0 then
        self.CheckpointFightRait5TimesText.text = string.format(SweepStringTable[1], levelRemainingTimes)
    else
        self.CheckpointFightRait5TimesText.text = SweepStringTable[2]
    end

    -- note: 按钮上显示实际的次数
    -- local availableRemainingTimes = GetAvailableTimes(self)
    -- if availableRemainingTimes > 0 then
    --     self.CheckpointFightRait5TimesText.text = string.format(SweepStringTable[1], availableRemainingTimes)
    -- else
    --     self.CheckpointFightRait5TimesText.text = SweepStringTable[2]
    -- end
end

-- 是否显示星级, 是否可以扫荡!
function CheckpointFightModule:HasStarControl()
    local levelType = self.levelData:GetFbType()
    return levelType ~= kLevelType_Normal and levelType ~= kLevelType_Hidden
end

function CheckpointFightModule:OnPause()
    CheckpointFightModule.base.OnPause(self)
    UnspawnAwardList(self)
    self:UnregisterControlEvents()
    self:UnregisterNetworkEvents()
end


function CheckpointFightModule:InitControls()
    local transform = self:GetUnityTransform()
    self.tweenObjectTrans = transform:Find("TweenObject")

    -- 星级获取
    self.starLayoutTrans = transform:Find('TweenObject/Level/StarLayout')
    self.starLayoutObject = self.starLayoutTrans.gameObject
    self.starObjectImages = {
        self.starLayoutTrans:Find('Star01'):GetComponent(typeof(UnityEngine.UI.Image)),
        self.starLayoutTrans:Find('Star02'):GetComponent(typeof(UnityEngine.UI.Image)),
        self.starLayoutTrans:Find('Star03'):GetComponent(typeof(UnityEngine.UI.Image))
    }
    self.starGraySprite = self.starObjectImages[1].sprite
    self.starLightSprite = self.starObjectImages[2].sprite

    -- 扫荡
    self.CheckpointFightRaidButton = transform:Find('TweenObject/CheckpointFightRaidButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.CheckpointFightRaidButtonObject = self.CheckpointFightRaidButton.gameObject
    self.CheckpointFightRaidText = transform:Find('TweenObject/CheckpointFightRaidButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 扫荡5次
    self.CheckpointFightRaid5TimesButton = transform:Find('TweenObject/CheckpointFightRaid5TimesButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.CheckpointFightRaid5TimesButtonObject = self.CheckpointFightRaid5TimesButton.gameObject
    self.CheckpointFightRait5TimesText = transform:Find('TweenObject/CheckpointFightRaid5TimesButton/Text'):GetComponent(typeof(UnityEngine.UI.Text))


    -- 按钮
    self.CheckpointFightReturnButton = transform:Find('TweenObject/CheckpointFightReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.CheckpointFightButton = transform:Find('TweenObject/CheckpointFightButton'):GetComponent(typeof(UnityEngine.UI.Button))

    -- 关卡名字
    self.CheckpointFightNameLabel = transform:Find('TweenObject/Information/CheckpointFightNameTitle/CheckpointFightNameLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 关卡描述
    self.CheckpointFightInformationLabel = transform:Find('TweenObject/Information/CheckpointFightInformationLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 消耗体力
    self.CheckpointFightTiLiNumLabel = transform:Find('TweenObject/Information/TiLi/CheckpointFightTiLiNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 剩余次数
    self.CheckpointFightTimesNumLabel = transform:Find('TweenObject/Information/Times/CheckpointFightTimesNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 扫荡卡
    self.sweepCardNumLabel = transform:Find('TweenObject/Information/Consumables/CheckpointFightConsumablesNumLabel'):GetComponent(typeof(UnityEngine.UI.Text))

    -- 重置按钮
    self.ResetButton = transform:Find('TweenObject/Information/ResetButton'):GetComponent(typeof(UnityEngine.UI.Button))
    self.ResetButtonObject = self.ResetButton.gameObject

    -- 奖励的Transform
    self.AwardListTrans = transform:Find("TweenObject/Information/AwardList/Viewport/Content")
    self.AwardListPoolTrans = transform:Find("TweenObject/Information/AwardItemPool")

    --背景按钮
    self.BackgroundButton = transform:Find('Background'):GetComponent(typeof(UnityEngine.UI.Button))
end

function CheckpointFightModule:RegisterControlEvents()
    -- 注册 CheckpointFightReturnButton 的事件
    self.__event_button_onCheckpointFightReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointFightReturnButtonClicked, self)
    self.CheckpointFightReturnButton.onClick:AddListener(self.__event_button_onCheckpointFightReturnButtonClicked__)

    -- 注册 CheckpointFightButton 的事件
    self.__event_button_onCheckpointFightButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointFightButtonClicked, self)
    self.CheckpointFightButton.onClick:AddListener(self.__event_button_onCheckpointFightButtonClicked__)

    -- 注册 CheckpointFightRaidButton 的事件
    self.__event_button_onCheckpointFightRaidButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointFightRaidButtonClicked, self)
    self.CheckpointFightRaidButton.onClick:AddListener(self.__event_button_onCheckpointFightRaidButtonClicked__)

    -- 注册 CheckpointFightRaid5TimesButton 的事件
    self.__event_button_onCheckpointFightRaid5TimesButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointFightRaid5TimesButtonClicked, self)
    self.CheckpointFightRaid5TimesButton.onClick:AddListener(self.__event_button_onCheckpointFightRaid5TimesButtonClicked__)

    -- 注册 ResetButton 事件
    self.__event_button_onResetButtonClicked__ = UnityEngine.Events.UnityAction(self.OnResetButtonClicked, self)
    self.ResetButton.onClick:AddListener(self.__event_button_onResetButtonClicked__)

    -- 注册 BackgroundButton 的事件
    self.__event_backgroundButton_onButtonClicked__ = UnityEngine.Events.UnityAction(self.OnCheckpointFightReturnButtonClicked,self)
    self.BackgroundButton.onClick:AddListener(self.__event_backgroundButton_onButtonClicked__)
end

function CheckpointFightModule:UnregisterControlEvents()
    -- 取消注册 CheckpointFightReturnButton 的事件
    if self.__event_button_onCheckpointFightReturnButtonClicked__ then
        self.CheckpointFightReturnButton.onClick:RemoveListener(self.__event_button_onCheckpointFightReturnButtonClicked__)
        self.__event_button_onCheckpointFightReturnButtonClicked__ = nil
    end

    -- 取消注册 CheckpointFightButton 的事件
    if self.__event_button_onCheckpointFightButtonClicked__ then
        self.CheckpointFightButton.onClick:RemoveListener(self.__event_button_onCheckpointFightButtonClicked__)
        self.__event_button_onCheckpointFightButtonClicked__ = nil
    end

    -- 取消注册 CheckpointFightRaidButton 的事件
    if self.__event_button_onCheckpointFightRaidButtonClicked__ then
        self.CheckpointFightRaidButton.onClick:RemoveListener(self.__event_button_onCheckpointFightRaidButtonClicked__)
        self.__event_button_onCheckpointFightRaidButtonClicked__ = nil
    end

    -- 取消注册 CheckpointFightRaid5TimesButton 的事件
    if self.__event_button_onCheckpointFightRaid5TimesButtonClicked__ then
        self.CheckpointFightRaid5TimesButton.onClick:RemoveListener(self.__event_button_onCheckpointFightRaid5TimesButtonClicked__)
        self.__event_button_onCheckpointFightRaid5TimesButtonClicked__ = nil
    end

    -- 取消注册 ResetButton 事件
    if self.__event_button_onResetButtonClicked__ then
        self.ResetButton.onClick:RemoveListener(self.__event_button_onResetButtonClicked__)
        self.__event_button_onResetButtonClicked__ = nil
    end

    
    -- 取消注册 BackgroundButton 的事件
    if self.__event_backgroundButton_onButtonClicked__ then
       self.BackgroundButton.onClick:RemoveListener(self.__event_backgroundButton_onButtonClicked__)
       self.__event_backgroundButton_onButtonClicked__ = nil
    end
end

function CheckpointFightModule:RegisterNetworkEvents()
    local net = require "Network.Net"
    self:GetGame():RegisterMsgHandler(net.S2CFBBuyChallengeResult,self,self.OnBuyChallengeResponse)
    self:GetGame():RegisterMsgHandler(net.S2CFBSweepResult, self, self.OnFBSweepResponse)
end

function CheckpointFightModule:UnregisterNetworkEvents()
    local net = require "Network.Net"
    self:GetGame():UnRegisterMsgHandler(net.S2CFBBuyChallengeResult, self, self.OnBuyChallengeResponse)
    self:GetGame():UnRegisterMsgHandler(net.S2CFBSweepResult, self, self.OnFBSweepResponse)
end

function CheckpointFightModule:IsTransition()
    return true
end

function CheckpointFightModule:OnExitTransitionDidStart(immediately)
    CheckpointFightModule.base.OnExitTransitionDidStart(self, immediately)
    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans
            local TweenUtility = require "Utils.TweenUtility"
            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function CheckpointFightModule:OnCheckpointFightReturnButtonClicked()
    --CheckpointFightReturnButton控件的点击事件处理
    self:Hide()
end

function CheckpointFightModule:OnCheckpointFightButtonClicked()
    --CheckpointFightButton控件的点击事件处理

    -- 判断剩余次数
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local remainTimes = playerChapterData:GetLevelRemainingTimes(self.levelData:GetChapterId(), self.levelData:GetId())

    if remainTimes <= 0 then
        utility.ShowErrorDialog(SweepStringTable[5])
        return
    end

    -- 判断体力
    local isEnough, errorRoutine = utility.IsVigorEnough(self.levelData:GetVigorToConsume())
    if not isEnough then
        errorRoutine()
        return
    end

    self:Close(true)

    local ServerService = require "Network.ServerService"
    local net = require "Network.Net"

    local levelData = self.levelData
    local LocalDataType = require "LocalData.LocalDataType"
    local BattleUtility = require "Utils.BattleUtility"

    -- 获取关卡敌人队伍 --
    local foeTeamParameters = BattleUtility.CreateBattleTeamsByLevelID(levelData:GetId())

    local battleParams = require "LocalData.Battle.BattleParams".New()

    -- print("场景ID >>>> ", self.levelData:GetSceneID())

    battleParams:SetSceneID(self.levelData:GetSceneID())
    -- TODO : 音乐
    -- battleParams:SetBGM(self.levelData:GetBGM())

    battleParams:SetScriptID(self.levelData:GetPlotID())
    battleParams:SetBattleType(kLineup_Attack)
    battleParams:SetBattleOverLocalDataName(LocalDataType.FBBattleResult)
    battleParams:SetBattleStartProtocol( ServerService.FBStartFightRequest(levelData:GetId()) )
    battleParams:SetBattleResultResponsePrototype( net.S2CFBOverResult )
    battleParams:SetBattleResultViewClassName("GUI.Modules.BattleResultModule")
    battleParams:SetMaxBattleRounds(30)
    battleParams:SetBattleResultWhenReachMaxRounds(false)
    battleParams:SetPVPMode(false)
    battleParams:SetSkillRestricted(levelData:GetMapType() == kMapType_SkillRestricted)
    battleParams:SetUnlimitedRage(levelData:GetMapType() == kMapType_UnlimitedRage)

    utility.StartBattle(battleParams, foeTeamParameters, nil, function()
        -- 记录关卡开始
        require "Utils.GameAnalysisUtils".LevelStart(levelData:GetId())
    end)
end

local function SendSweep(self, sweepCount)
    -- 检测是否够三星
    local UserDataType = require "Framework.UserDataType"
    local playerChapterData = self:GetCachedData(UserDataType.PlayerChapterData)
    local star = playerChapterData:GetLevelStar(self.levelData:GetChapterId(), self.levelData:GetId())
    if star < 3 then
        utility.ShowErrorDialog(SweepStringTable[4])
        return
    end

    -- 还是判断体力是否足够, 如果不足依然不可以.
    local isEnough, errorRoutine = utility.IsVigorEnough(self.levelData:GetVigorToConsume() * sweepCount)
    if isEnough then
        -- 如果扫荡卡不足 就弹出提示
        local sweepCardNumber = GetSweepCardCount(self)
        if sweepCardNumber < sweepCount then
            -- 需要花费钻石, 走钻石扫荡 --
            utility.ShowConfirmDialog(
                string.format(SweepStringTable[3], (sweepCount * 5)),
                self,
                function(self)
                    local levelId = self.levelData:GetId()
                    local ServerService = require "Network.ServerService"
                    local msg, prototype = ServerService.BattleSweep(levelId, sweepCount, 1)
                    self:GetGame():SendNetworkMessage(msg, prototype)
                end
            )
            return
        end

        -- 走扫荡卡扫荡
        local levelId = self.levelData:GetId()
        local ServerService = require "Network.ServerService"
        hzj_print("levelId, sweepCount",levelId, sweepCount)
        local msg, prototype = ServerService.BattleSweep(levelId, sweepCount, 0)
        self:GetGame():SendNetworkMessage(msg, prototype)
    else
        errorRoutine()
    end
end

local function SweepImpl(self, maxCount)
    if self.levelData == nil then
        print('ignore!')
        return
    end

    local res, value = GetAvailableTimesWithErrorReason(self)

    if res and value > 0 then
        if type(maxCount) == "number" and maxCount > 0 then
            maxCount = math.min(maxCount, value)
        else
            maxCount = value
        end
        SendSweep(self, maxCount)
        return
    end

    utility.ShowErrorDialog(value)

    -- if type(maxCount) == "number" and maxCount > 0 then
    --     maxCount = math.min(maxCount, GetAvailableTimes(self))
    -- else
    --     maxCount = GetAvailableTimes(self)
    -- end

    -- if maxCount > 0 then
    --     SendSweep(self, maxCount)
    --     return
    -- end

    -- utility.ShowErrorDialog(SweepStringTable[2])
end

function CheckpointFightModule:OnCheckpointFightRaidButtonClicked()
    SweepImpl(self, 1)
end

function CheckpointFightModule:OnCheckpointFightRaid5TimesButtonClicked()
    SweepImpl(self)
end

local function GetPlayerVip(self)
    local UserDataType = require "Framework.UserDataType"
    local userData = self:GetCachedData(UserDataType.PlayerData)
    return userData:GetVip()
end

function CheckpointFightModule:OnResetButtonClicked()
    if self.levelData == nil then
        print('ignore!')
        return
    end

    local chapterLevelUtils = require "Utils.ChapterLevelUtils"
    local boughtTimes = chapterLevelUtils.GetLevelBuyTimes(self.levelData:GetId())
    local maxBuyTimes = chapterLevelUtils.GetMaxLevelBuyTimes(GetPlayerVip(self))
    if boughtTimes >= maxBuyTimes then
        utility.ShowErrorDialog("今日已经无法继续购买\n(提升VIP等级可增加每日重置次数)")
        return
    end
    
    
    utility.ShowConfirmDialog(
        string.format( "花费 %d 钻石 可重置当前副本\n(%d/%d)", chapterLevelUtils.GetDiamondBuyLevel(self.levelData:GetId()), boughtTimes, maxBuyTimes ),
        self,
        function()
            local ServerService = require "Network.ServerService"
            self:GetGame():SendNetworkMessage(ServerService.BuyChallengeCount(self.levelData:GetChapterId(), self.levelData:GetId()))
        end
    )
end


function CheckpointFightModule:OnBuyChallengeResponse(_)
    self:Refresh()
end

function CheckpointFightModule:OnFBSweepResponse(msg)
    self:Refresh()
	
    if msg.levelUp then
        local MessageGuids = require "Framework.Business.MessageGuids"
        self:DispatchEvent(MessageGuids.RefreshChapterView)
    end
	
	if msg.showHeishi then
		local windowManager = utility.GetGame():GetWindowManager()
		windowManager:Show(require "GUI.BlackMarket.BlackMarket")
	end

    local CheckpointRaidModuleClass = require "GUI.Modules.Raid.CheckpointRaidModule"
    self:GetWindowManager():Show(CheckpointRaidModuleClass, msg)
end

return CheckpointFightModule