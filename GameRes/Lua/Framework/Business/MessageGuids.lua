--
-- User: fbmly
-- Date: 4/7/17
-- Time: 5:10 PM
--

local messageGuids = {
    -- TODO 以后要把显式的函数调用  改成消息传递  业务的逻辑之间的消息都写在这里

    ----------------------------------------------------------------------------------------
    --- 网络连接状态的改变
    ----------------------------------------------------------------------------------------
    SessionStateChanged = "5dd31e91-e1e5-4322-96af-8f9752ace374",

	----------------------------------------------------------------------------------------
    --- 新手引导
    ----------------------------------------------------------------------------------------
	PlayerGuideEventDone = "bbe0f691-1dfb-4724-8172-226461d2c994",
	
    ----------------------------------------------------------------------------------------
    --- 登录管理相关
    ----------------------------------------------------------------------------------------
    GameServerStateChangedNotify = "bd4ec8b9-f7f0-4117-9317-a51be9c406c2",

    GameServerSelectionNodeClicked = "72a26194-99c8-4156-af5e-977632ae20ba",

    ----------------------------------------------------------------------------------------
    --- 震屏
    ----------------------------------------------------------------------------------------
    ShakeCameraEvent = "c01bfc8a-3dde-4bf0-ac74-30b49e66c3ac",

    ----------------------------------------------------------------------------------------
    --- 服务器时间
    ----------------------------------------------------------------------------------------
    ServerTimeUpdated = "16607515-2a3b-4ee2-96cd-961e365c4b5d",

    ----------------------------------------------------------------------------------------
    --- 跑马灯
    ----------------------------------------------------------------------------------------
    SendMarquee = "e011d71d-0d93-47fe-b231-43826df5df83",

    ----------------------------------------------------------------------------------------
    --- 视频播放器
    ----------------------------------------------------------------------------------------
    VideoEndReached = "146bfa6d-f364-4f09-b121-5aa2edbaeb17",
    VideoPrepared = "e61b7eff-ebfc-4829-b17b-21c69b93a33f",
    VideoError = "fe5f8dc7-487a-4ac2-8953-87d0f08dee6e",
    
    ----------------------------------------------------------------------------------------
    --- 主界面消息
    ----------------------------------------------------------------------------------------
    EnterLobbyScene = "c70b6f70-4e63-4416-ae5b-a882d951be8a",
    ExitLobbyScene = "64c44ba5-6d40-4dec-91ff-f94ff7f3916a",

    EnterPitScene = "f3a83744-0f8a-446d-aedd-b8f66aa268a9",
    EnterProtectScene = "d105d455-e35f-4ce9-bf06-f3ef90c8c248",
    EnterCastleScene = "e8bf4367-e483-405d-bd1a-ec61361d5f92",
    EnterElvenTreeScene = "a0b4361f-42a4-4a87-8c62-aa545ea7dcbb",
    EnterShopScene = "6714814f-83b2-4736-b617-9d783fb8b6a6",
    EnterGuildScene = "69dc99b5-f0a3-4254-87f2-42742897ef85",
    EnterMailScene = "17a95284-84c0-48ca-a962-5a5a61d26430",
    EnterChapterScene = "31821e66-ef3e-45c1-9fdd-cee68a1034a2",
    EnterArenaScene = "70b3c774-94b8-41c1-b40c-80031f086e07",
    EnterJourneyScene = "4d826ab5-bdcb-4332-96e6-2f781f28b7c9",



    --- 背包界面
    CloseKnapsackWindow = "d1547b73-08c0-45e3-94e5-6c4e2a66a326",
    UpdataKnapsackWindow = "c3f15e96-6e16-485b-bc46-27c8a5dc6208",
    --- 装备界面
    CloseEquipWindow = "b9ca3eca-4743-402b-9950-ee7570f58ffb",

    ----------------------------------------------------------------------------------------
    --- 用户数据相关
    ----------------------------------------------------------------------------------------

    ---- # 用户数据
    UpdatedPlayerData = "e799b4d5-a93d-4487-9122-3d04ed28b571",

    ---- # 所有地图更新
    UpdatedAllMapData = "0cf09800-3fd9-458c-ad0b-94a39384939a",


    ---- # 连接后 登录的 加载数据 业务
    LoadAllUserDataFinished = "cae213e4-9998-459e-a7da-0ec03cfb68b9",


    ---- # 增加卡牌
    AddedOneCard = "290522db-1fac-4279-b8c8-044a7117b440",

    ---- # 更新卡牌
    UpdatedOneCard = "a9792c33-339b-4d0e-855c-9929abd10e93",

    ---- # 删除卡牌
    RemovedOneCard = "d3848d3c-a08e-4819-9a35-16c7ded2758e",



    ---- # 增加卡牌碎片
    AddedOneCardCrap = "4913df6a-28ea-4138-9b5f-79ad6fea2d6e",

    ---- # 更新卡牌碎片
    UpdatedOneCardCrap = "fffb1866-65e2-4622-a6dd-1ff468fda7cb",

    ---- # 删除卡牌碎片
    RemovedOneCardCrap = "103f5f83-3762-40de-9844-ff7dcdbc6d8e",




    ---- # 增加物品
    AddedOneItem = "ce9632de-c325-4c8e-8d82-e42e96532975",

    ---- # 更新物品
    UpdatedOneItem = "55653962-7128-4221-8067-30a4c0caa0ea",

    ---- # 删除物品
    RemovedOneItem = "f75f12c6-180b-40cb-af75-d7458de10c1e",



    ---- # 增加装备
    AddedOneEquip = "29718163-65bd-4fe7-8574-322aa8a99c38",

    ---- # 更新装备
    UpdetedOneEquip = "029bcaaa-71a6-4f16-b261-98b9aea0de18",

    ---- # 删除装备
    RemovedOneEquip = "f8096ca0-a09b-4d91-9ea0-2765c929c6e1",


    ---- # 增加装备碎片
     AddedOneEquipDebris = "1fe2fc58-3dc0-4aff-8251-6a30475fa365",

    ---- # 更新装备碎片
    UpdetedOneEquipDebris = "ef34b1ec-b04b-4acd-a6cc-087e07cdb16d",

    ---- # 删除装备碎片
    RemovedOneEquipDebris = "0716a596-6597-4e11-a6f6-3b1ccdc899a7",

    ---- # 穿上皮肤
    CardSkinUpdate = "f8628167-9fdc-4187-a06b-d6b7dc2149c8",

    ---- # 卸下皮肤
    PutOffCardSkin = "4abbb885-aed4-4c9a-a31b-8656c4d64698",


    ---- # 扫荡成功(升级) 用于刷新章节View数据
    RefreshChapterView = "afc87a56-5735-4903-917f-6fa32f49e32d",


    ----------------------------------------------------------------------------------------
    --- 战斗UI控制
    ----------------------------------------------------------------------------------------

    -- @@@ Hp血条控制
    BattleActivateHpGroupObject = "e3a7f433-f128-4c7d-badb-70f8ecbbc612",

    -- @@@ 目前保留的3种控制模式 以后会不用删掉的!
    BattleActivateSystemButtonList = "dbe75b26-6799-480b-88b7-e17927bde0da",
    BattleActivateTopInformation = "f3ed8242-5632-49bf-967c-a320eb269202",
    BattleActivateRightProgress = "d351c876-f760-4655-a1ff-8f1b97cd4a4b",

    -- @@@ 战斗UI的几种模式控制 @@@ --
    BattleInactivateAllGroups = "96ab62c5-37a8-4f16-bfef-2e267c0a20fa",
    BattleActiveGroup1 = "70bf8131-b1ea-4652-b46d-0ab825ca0266",
    BattleActivateVideoInGroup2 = "57416bda-2825-4afb-b5b0-aa9694adaaaf",
    BattleActivateFirstStartImageInGroup2 = "5ec200e4-9fe3-48df-9a31-8c389ed47023",
    BattleActivateCommonBaseImageInGroup2 = "54f5ecad-d622-4e7e-a007-a86573a6513e",

    -- @@@ 战斗暂停/恢复控制 @@@ -- 
    BattlePauseFight = "e4b7b1cb-f201-4724-9cff-ad4ec1aec865",
    
    BattleResumeFight = "4c87e3cd-e0c9-411f-a7e0-3cdca840d4bd",

    BattleExitFight = "db56fec2-8dac-4856-823f-59a0c215c06c",

    ----------------------------------------------------------------------------------------
    --- 战斗UI技能特效控制
    ----------------------------------------------------------------------------------------
    BattleActivateUISkillAnimation = "ea14fe0c-2074-4f28-8da5-be8dc9e785a4", -- true : 播放  false: 停止

    ----------------------------------------------------------------------------------------
    --- 战斗时的
    ----------------------------------------------------------------------------------------
    BattleRoundChanged = "f0425f0c-1f62-4a81-8e13-f1c530fe570a",

    BattleInitFightingHeads = "f42fd632-2c7c-4265-aead-0e44f1f6915a",

    BattleTakeAction = "ff30ebda-d3c9-4f19-a986-b8094eb5194b",

    BattleBeginAssistAttack = "1ffe7287-831a-4d54-8fbd-646d09ec5790",

    BattleEndAssistAttack = "737181dd-6772-47c3-8bcb-53cbaae07451",

    BattleTakeAttackAction = "2766907d-c026-4da2-901c-e6b4ade47139",

    BattleUnitDead = "bd20de86-427d-4bc7-9ed2-8500372fc6bf",

    BattleSkillTargetSelection = "b8660e92-6edc-4e0b-b085-9fa8804a142f",

    BattleShowSkillPortraitEffect = "dd119e92-735a-48f5-8c01-85e6731c9148",
    BattleHideSkillPortraitEffect = "f569280d-51e5-411e-8a84-a61872c64a6f",
    BattleShowSkillBubble = "e5775b77-17a3-42b9-82f3-fc6a5c1b3972",
    --大招黑背板变黑
    BattleSkillBlackBoardBlack="0cfe0c41-0855-4077-ab3a-d40a8876b29f",
     --大招黑背板变黑
    BattleSkillBlackBoardWhite="15e5ad50-80c8-4a48-b17b-f62671b0c415",



    BattleActiveReplayButton = "ba6bc99c-b48c-4ae7-b19a-0b7d3a98c185",
    BattleReplayButtonClicked = "d04d8593-f711-4468-98f3-b711650fdac4",

	BattlePlaySkillHeadEffect = "44758598-ebbe-4a0b-8541-41d556b7e972",


    -- 推镜头 --
    BattleStartCameraZoomUp = "464dcbb0-ea7b-4390-bb15-8834a070adf4",
    BattleEndCameraZoomUp = "f7689e9d-092e-4a6f-957c-2bdeacaaacaf",



    -- 战斗单位扣血时
    BattleUnitLoseHp = "65d2b786-5cc0-4147-9f46-64e935b7dbbe",

    ----------------------------------------------------------------------------------------
    --- 战斗记录
    ----------------------------------------------------------------------------------------
    -- 战斗开始/结束
    FightFightEnter = "1dffc71e-b267-48e0-ba17-a4f8f27dc8b4",
    FightFightExit = "64ea1de2-d857-40b1-8786-eeb4bc4ac2c5",

    -- 新的波次开始/结束
    FightWaveEnter = "e29136ec-6949-4116-ac4f-6773321e6377",
    FightWaveExit = "a1604a64-4025-4926-8bbc-ae2e579a507e",

    -- 新的回合开始/结束 --
    FightRoundEnter = "ac02efd0-0861-4384-bdcb-e60483b0a749",
    FightRoundExit = "8647887f-2518-431b-9c87-f3e8d2384f8b",

    -- 添加伤害记录(用于总计每个人 在整场战斗中的 总伤害)
    FightAddDamageRecord = "e428862a-a123-405f-a1bc-742708ce3807",

    BattleSkillManuallySelection = "ea85efa6-75b5-47a9-be13-24c5e6e7acbe",


    ----------------------------------------------------------------------------------------
    --- 战斗结算
    ----------------------------------------------------------------------------------------
    BattleResultDataBackButton = "35d6a85d-100e-42d2-84b2-1d5ee60b9afb",

    ----------------------------------------------------------------------------------------
    --- 红点
    ----------------------------------------------------------------------------------------
    ModuleRedDotChanged = "FAF9151C-1F3F-4E46-87C3-CAB00B6F37FD",
    
    CardRedDotChanged = "C57A674B-B887-436D-8EAA-0080300EB90F",


    ----------------------------------------------------------------------------------------
    --- 英雄界面
    ----------------------------------------------------------------------------------------

    -- 点击的回调(HeroCardItem) --
    HeroCardItemClicked = "c6d2e1d8-f834-4134-911a-69a51a1c7638",

    -- 装备点击 --
    HeroEquipmentSlotClicked = "87ba0349-7372-4ec5-bb28-4ba015a00343",

    -- 详细页面的创新(heroID, heroData or nil) --
    HeroDetailViewRefresh = "a2627c05-9423-41c8-b8a2-cbb64cded338",

    -- 隐藏/显示 装备按钮(true or false)
    GoEquipmentButtonDisabled = "d19315e3-6b5b-4e07-ba3f-da6e09f92e50",

    -- 向左切换 --
    HeroCardLeftSwitch = "cafc3777-921f-422a-a7ca-b3bdb4f0ef49",

    -- 向右切换 --
    HeroCardRightSwitch = "92273ad4-65f2-43d4-a496-4adbd2812e48",

    -- 升级
    CardLevelUpClicked = "11aa17b2-1ed0-40d7-8d42-d5900dda7668",

    -- 进阶
    CardStageUpClicked = "1cd347b2-7b17-4bc7-b988-bbe809c4283b",

    -- 突破
    CardBreakClicked = "b5b0664d-f577-4732-bebe-948adffe636f",

    -- 天赋
    CardTalentClicked = "b328fbbb-7dea-42b0-b0e6-597e57793805",
	
	 -- 卡册
    CardSkinClicked = "055c1f7a-b1c0-4ca4-b096-531c663a4c46",

    ----------------------------------------------------------------------------------------
    --- 保卫公主
    ----------------------------------------------------------------------------------------
    ProtectDataQueryUpdate = "3328b9ab-17a9-48a7-a615-3631d3732cad",
    ProtectDataNextGate = "e331e8f2-2852-4eff-af5e-136326b21fe3",
    ProtectDataNextGateAnimFinished = "584095c3-bc71-48b7-915a-b6f726bb8dd0",
    ProtectDataDone = "a5efa41f-e6c6-44d4-9342-4be17d03d0df",

    ProtectShowInspectorTitle = "8f58a686-f738-41f3-8a49-28fd4e284794",

    ----------------------------------------------------------------------------------------
    --- 更换装备
    ----------------------------------------------------------------------------------------
    EquipChanged = "a3f8ec90-0c6c-4124-b527-fb67826b6c24",
    ----------------------------------------------------------------------------------------
    --- 改變音樂,音效
    ----------------------------------------------------------------------------------------
    BgMusicChanged = "a23aa500-b4ef-48b1-adec-f07f1caa61fa",
    EffectSoundChanged = "bd616179-df9e-403c-9344-b68fbb688ca7",
    EffectChanged = "840e7124-7705-4400-9ea4-71178ef47084",
    ----------------------------------------------------------------------------------------
    --- 点石成金
    OnCoinBuyWithDiamond = "a6f68bf8-a9ae-4a59-9f8f-01c9c8457692", 

    ----------------------------------------------------------------------------------------
    --- 抽卡新手引导
    NewGuideOnBackMain = "a31d00fb-5c9c-40ba-b032-788a5738fce2",
	
	----------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------
    -- # 跳转场景
    JumpToNormalScene = "286fc8de-a66a-454d-a617-2f062af9a935",
    

    -- # 塔罗牌状态变更
    TarotCardStateChanged = "2c1a5dec-759e-4cc3-921d-282f4d4ae53c",

    -- # 塔罗牌进度变更
    TarotProgressChanged = "dd119c47-94bf-4a4a-8db5-61935fcdace2",

    LocalRedDotChanged = "412d0cf8-350e-435c-be8a-5454f27cea14"

}

return messageGuids