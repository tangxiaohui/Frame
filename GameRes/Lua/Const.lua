-- 登录状态
kLoginState_None                = 0
kLoginState_Notice              = 1
kLoginState_Login               = 2
kLoginState_Logout              = 3
kLoginState_ChannelLogin        = 4
kLoginState_RequestServerList   = 5
kLoginState_RequestRoleList     = 6
kLoginState_WaitingForConnect   = 7
kLoginState_Connecting          = 8
kLoginState_Connected           = 9

-- Socket 连接状态
kSessionState_Default       = 0
kSessionState_Connected     = 1
kSessionState_ConnectFailed = 2
kSessionState_Disconnect    = 3

-- 资源池Tag分类
kPoolTag_Battle = "18707f34-070b-4ba5-a60c-cc5d4b8b1b6b"  -- 战斗内资源Tag


-- 关卡类型
kMapType_Normal = 0
kMapType_SkillRestricted = 1
kMapType_UnlimitedRage = 2

-- 队伍阵营
kTeamSide_Left = 0
kTeamSide_Right = 1

-- 技能类型
kSkillType_Melee 		= 0		--近战
kSkillType_LongRange 	= -1	--远程
kSkillType_Passive 		= -2	--被动
kSkillType_Blink		= -3	--闪烁

-- 连带类型
kSkillLinearType_Horizontal = 0  -- 横向
kSkillLinearType_Vertical   = 1	 -- 纵向
kSkillLinearType_Cross      = 2  -- 十字

-- 技能目标
kSkillTarget_MembersLowestPercentHP = -19   --己方血%最低
kSkillTarget_MembersHighestPercentHP= -18   --己方血%最高
kSkillTarget_MembersLowestHP 		= -17   --己方血量最低
kSkillTarget_MembersHighestHP 		= -16   --己方血量最高
kSkillTarget_MembersHighestAttack 	= -15   --己方攻最高
kSkillTarget_RandomMembersByTimes 	= -14   --己方随机n次
kSkillTarget_DefaultMembersByTimes 	= -13   --己方默认n次
kSkillTarget_DeadMembers 			= -12   --己方死亡
kSkillTarget_DamagedMembers 		= -11   --己方受伤
kSkillTarget_MembersByState         = -10   --己方状态
kSkillTarget_MembersByGender        = -9    --己方性别
kSkillTarget_MembersByProperty      = -8    --己方属性
kSkillTarget_MembersByRace          = -7    --己方种族
kSkillTarget_MembersByDirection     = -6    --己方连带
kSkillTarget_RandomMembers 			= -5    --己方随机
kSkillTarget_AllMembers 			= -4  	--己方全体
kSkillTarget_BackrowMembers 		= -3 	--己方后排
kSkillTarget_FrontrowMembers 		= -2 	--己方前排
kSkillTarget_Self 					= -1	--自己
kSkillTarget_None 					= 0		--无目标
kSkillTarget_DefaultFoe				= 1		--默认敌人
kSkillTarget_FrontrowFoes 			= 2		--敌方前排
kSkillTarget_BackrowFoes 			= 3		--敌方后排
kSkillTarget_AllFoes 				= 4		--敌方全体
kSkillTarget_RandomFoes 			= 5		--敌方随机
kSkillTarget_FoesByDirection 		= 6    	--敌方连带
kSkillTarget_FoesByRace 			= 7		--敌方种族
kSkillTarget_FoesByProperty 		= 8		--敌方属性
kSkillTarget_FoesByGender 			= 9		--敌方性别
kSkillTarget_FoesByState			= 10	--敌方状态
kSkillTarget_DamagedFoes 			= 11	--敌方受伤
kSkillTarget_DeadFoes 				= 12   	--敌方死亡
kSkillTarget_DefaultFoesByTimes 	= 13	--敌方默认n次
kSkillTarget_RandomFoesByTimes 		= 14	--敌方随机n次
kSkillTarget_FoesHighestAttack 		= 15	--敌方攻最高
kSkillTarget_FoesHighestHP 			= 16	--敌方血量最高
kSkillTarget_FoesLowestHP 			= 17	--敌方血量最低
kSkillTarget_FoesHighestPercentHP 	= 18	--敌方血%最高
kSkillTarget_FoesLowestPercentHP 	= 19	--敌方血%最低


kSkillTarget_Targets					= 20 	-- 最近一次选择的目标列表 --
kSkillTarget_AllUnitsExcludeTargets 	= 21	-- 除最近一次选择的目标列表的其余全部单位(敌/我 视数字正/负 而定!) --
kSkillTarget_RandomUnitsExcludeTargets 	= 22 	-- 除最近一次选择的目标列表的随机单位(敌/我 视数字正/负 而定!)

kSkillTarget_UnitsBelowPercentHp = 23
kSkillTarget_Attackers = 24


-- 属性ID
kPropertyID_HpLimit 		= 1			-- 最大生命值
kPropertyID_HpLimitRate 	= 2			-- 最大生命系数
kPropertyID_Dp 				= 3			-- 防御力值
kPropertyID_DpRate 			= 4			-- 防御力系数
kPropertyID_Ap 				= 5			-- 攻击力值
kPropertyID_ApRate 			= 6			-- 攻击力系数
kPropertyID_CritRate 		= 7			-- 暴击率
kPropertyID_DecritRate 		= 8			-- 抗暴率
kPropertyID_HitRate 		= 9			-- 命中率
kPropertyID_AvoidRate 		= 10		-- 闪避率
kPropertyID_Speed 			= 11		-- 速度
kPropertyID_SkillDamage 	= 12		-- 技能伤害
kPropertyID_AttackDamage 	= 13		-- 普攻伤害
kPropertyID_VamRate 		= 14		-- 吸血率
kPropertyID_CritDamageRate 	= 15		-- 暴击伤害系数

kPropertyID_MaxCount = 15



-- 技能触发条件
kSkillCondition_Uncondition							= 0			-- 无条件触发
kSkillCondition_HpOfSelfIsLessOrEqualToPercent  	= 1			-- 自己生命值小于等于%
kSkillCondition_State								= 2			-- 是否受到状态 (参数是 state id)
kSkillCondition_Equip								= 3			-- 是有拥有装备 (参数是 装备id)
kSkillCondition_GreaterOrEqualToMemberCount 		= 4			-- 己方人数大于等于时
kSkillCondition_LessOrEqualToMemberCount 			= 5			-- 己方人数小于等于时
kSkillCondition_GreaterOrEqualToFoeCount			= 6			-- 敌方人数大于等于时
kSkillCondition_LessOrEqualToFoeCount				= 7			-- 敌方人数小于等于时
kSkillCondition_HpOfMembersLessOrEqualToPercent 	= 8			-- 己方有单位生命值低于%时 (包括自己)

kSkillCondition_RoleOfMembers 						= 9 		-- 己方场上存在指定角色
kSkillCondition_Kill 								= 10		-- 击杀
kSkillCondition_Hit 								= 11		-- 命中
kSkillCondition_Avoid 								= 12		-- 闪避
kSkillCondition_Crit 								= 13		-- 暴击
kSkillCondition_RaceOfTargets 						= 14		-- 刚才的目标的种族
kSkillCondition_MajorAttrOfTargets 					= 15		-- 刚才的目标的属性
kSkillCondition_HpOfTargetsIsLessOrEqualToPercent 	= 16 		-- 刚才的目标的hp低于%
kSkillCondition_AttributeOfFoesExist                = 17        -- 敌方有存在指定主属性的人
kSkillCondition_RaceOfFoeExist                      = 18        -- 敌方有存在指定种族的人

kSkillCondition_Probability 						= 20 		-- 概率触发
kSkillCondition_HpRateLE                            = 21        -- 小于等于指定血量%
kSkillCondition_HpRateBE                            = 22        -- 大于等于指定血量%

kSkillCondition_UsingSkill                          = 30        -- 是否在使用技能
kSkillCondition_UsingAttack                         = 31        -- 是否在使用普攻

kSkillCondition_IsAlive                             = 32        -- 是否活着




-- >>>>>>>>>>> 技能行为 >>>>>>>>>>> --
kSkillAction_None = 0				-- 无行为(默认)
kSkillAction_AddState = 1			-- 增加状态(普通状态和状态免疫)
kSkillAction_CancelState = 2 		-- 取消状态
kSkillAction_AddApRate = 3			-- 增加攻击力系数
kSkillAction_AddApValue = 4			-- 增加攻击力点数
kSkillAction_AddDpRate = 5			-- 增加防御力系数
kSkillAction_AddDpValue = 6			-- 增加防御力点数
kSkillAction_AddHpLimitRate = 7  	-- 增加血量上限系数
kSkillAction_AddHpLimitValue = 8 	-- 增加血量上限点数
kSkillAction_AddSpeedRate = 9		-- 增加速度系数
kSkillAction_AddSpeedValue = 10		-- 增加速度点数
kSkillAction_AddCritRate = 11		-- 增加暴击率
kSkillAction_AddCritDamageRate = 12	-- 增加暴击伤害系数
kSkillAction_AddDecritRate = 13	 	-- 增加抗暴率
kSkillAction_AddAvoidRate = 14		-- 增加闪避率
kSkillAction_AddHitRate = 15		-- 增加命中率
kSkillAction_AddVamRate = 16		-- 增加吸血率
kSkillAction_AddHpValue = 17		-- 增加当前血量点数
kSkillAction_AddHpRate = 18			-- 增加当前血量系数
kSkillAction_AddAttackDamageValue = 19	-- 增加普攻额外伤害点数
kSkillAction_AddSkillDamageValue = 20 -- 增加技攻额外伤害点数
kSkillAction_AddDamageRate = 21 -- 伤害系数
kSkillAction_Relive = 22		-- 满血复活

kSkillAction_RandomRangeDamageRate = 23 -- 伤害系数随机 parama1下限 param2上限

-- 25-28
kSkillAction_SetDamageRateByHp = 25
kSkillAction_SetDamageRateByAp = 26
kSkillAction_SetDamageRateByAvoidRate = 27
kSkillAction_SetDamageRateByDp = 28


-- 25: 附加生命的参数 例如 (1.5+生命）* 攻击力
-- 26: 附加攻击的参数 例如（1.5+攻击）* 攻击力

-- 27: 附加闪避的参数 例如（1.5+闪避）* 攻击力
-- 28: 附加防御的参数 例如（1.5+防御）* 攻击力


kSkillAction_DamageReductionRate = 30 -- 增加减伤系数

kSkillAction_AddRage = 31 -- 增加怒气


kSkillAction_DamageRateOnFrontRow = 32 -- 选择前排时伤害系数
kSkillAction_DamageRateOnBackRow = 33 -- 选择后排时伤害系数

kSkillAction_DoubleDamage = 34 -- 伤害翻倍

--35：决斗(双方由发起方开始互相普攻直到一方死亡，param1为普攻最大次数) (只对剑八)
kSkillAction_FightRepeatly = 35

--36：根据(1-血量%)执行系数操作，param1为行为，2为增加量=param2*(1-血量%)
kSkillAction_AddPropertyByHpPercent = 36

-- 37：根据当前敌人数量决定执行系数操作，param1为行为，2为增加量=param2*(敌人数量)
kSkillAction_AddPropertyByFoeCount = 37

-- 38: 在自己场上唤醒一个盾，盾的等级星级颜色与召唤者相同
kSkillAction_AddShield = 38

-- 39: 额外伤害
kSkillAction_ExtraDamage = 39

-- 40: 扣除百分比伤害
kSkillAction_LoseHpByMaxRate = 40

kSkillAction_MarkAsMustBeCrit = 41      -- 设置为必暴击
kSkillAction_MarkAsMustBeHitMark = 42   -- 设置为必命中

-- 43 按自己指定的伤害系数 来治疗target
kSkillAction_HealByDamageRate = 43

-- 44 按自己的最大血上限*rate 来治疗 target
kSkillAction_HealByMaxHpRateSelf = 44

-- 45 添加状态免疫
kSkillAction_AddStateImmunity = 45

-- 46 移除状态免疫
kSkillAction_RemoveStateImmunity = 46

-- <<<<<<<<<<<< 技能行为 <<<<<<<<<<<<<< --

------ >> 天赋 << ------
kTalentType_Immunity = 0
kTalentType_Property = 1
kTalentType_Skill = 2
kTalentType_CardGroup = 3
kTalentType_Race = 4

-- 状态阶段 --
kUnitState_Phase_None               = 0            -- 不执行
kUnitState_Phase_Any                = 1            -- 任意
kUnitState_Phase_ActionStart        = 2            -- 行动前
kUnitState_Phase_Action             = 3            -- 行动时
kUnitState_Phase_ActionExit         = 4            -- 行动后
kUnitState_Phase_UnderAttack        = 5            -- 受击时
kUnitState_Phase_UnderAttackExit    = 6            -- 受击后
kUnitState_Phase_Dead               = 7            -- 死亡时

-- 状态特征 --
kUnitState_Trait_Flag                   = 1            -- 标志
kUnitState_Trait_StateToReject          = 2            -- 拒绝状态
kUnitState_Trait_StateToCounteract      = 3            -- 抵消状态
kUnitState_Trait_ActivityRateByState    = 4            -- 作用率受状态id存在影响(TODO)
kUnitState_Trait_ApRate                 = 10           -- 攻击力系数
kUnitState_Trait_DpRate                 = 11           -- 防御力系数
kUnitState_Trait_SpeedRate              = 12           -- 速率
kUnitState_Trait_CritRate               = 13           -- 暴击率
kUnitState_Trait_CritDamageRate         = 14           -- 暴击伤害系数
kUnitState_Trait_DecritRate             = 15           -- 抗暴率
kUnitState_Trait_AvoidRate              = 16           -- 闪避率
kUnitState_Trait_HitRate                = 17           -- 命中率
kUnitState_Trait_VamRate                = 18           -- 吸血率
kUnitState_Trait_DamageRate             = 19           -- 伤害系数
kUnitState_Trait_ScaleRate              = 20           -- 缩放系数

-- 状态特征 标志 --
kUnitState_TraitFlag_God        = 1  -- 无敌
kUnitState_TraitFlag_CannotMove = 2  -- 不能行动

-- 状态行为 --
kUnitState_Action_DamageValueByApFactor = 1     -- 根据攻击者的攻击力 * 系数决定的 伤害HP
kUnitState_Action_DamageValueByHpPercent = 2    -- 根据中状态者的血上限扣hp% (参数1是百分比)

-- Flag
kStateFlag_SubRage 	= 19	--减怒行为
kStateFlag_Crit 	= 20	--暴击

---- 阵容类型
kLineup_Attack              = 0         -- 普通战斗攻击
kLineup_ArenaDefence        = 1         -- 竞技场防守
kLineup_ArenaAttack         = 2         -- 竞技场攻击
kLineup_Protect             = 3         -- 保卫公主
kLineup_GuildPointAttack    = 4         -- 公会积分战攻击
kLineup_GuildPointDefence   = 5         -- 公会积分战防守
kLineup_Empty3              = 6         -- XXXXXX
kLineup_Empty4              = 7         -- XXXXXX
kLineup_ElvenTree           = 8         -- 掠夺防守阵容
kLineup_Union               = 9         -- 工会阵容
kLineup_JourneyToExplore1   = 10        -- 探险之旅1 神秘龙穴
kLineup_JourneyToExplore2   = 11        -- 探险之旅2 骷髅海
kLineup_JourneyToExplore3   = 12        -- 探险之旅3 魔力战场
kLineup_JourneyToExplore5   = 13        -- 探险之旅5 绝境求生
kLineup_JourneyToExplore4   = 14        -- 探险之旅4 世界BOSS
kLineup_TowerAttack         = 15        -- 爬塔普通陣容
kLineup_TowerBossAttack     = 16        -- 爬塔boss陣容
kLineup_Max = 17  -- 这里写总个数(最大19)



---- 关卡类型
kLevelType_Normal = 0       -- 普通
kLevelType_Branch = 1       -- 分支
kLevelType_LittleBoss = 2   -- 小boss
kLevelType_BigBoss = 3      -- 大boss
kLevelType_Hidden = 4       -- 隐藏关


---- 箱子领取类型
--0表示无法领取，1表示未领取，2表示已领取
kChapterBoxStatus_Unavailable = 0
kChapterBoxStatus_NotReceiveYet = 1
kChapterBoxStatus_Received = 2

--- id 类型
kStaticTableId_Card                 = 100
kStaticTableId_Equipment            = 101
kStaticTableId_Skill                = 102
kStaticTableId_GeneralItem          = 103
kStaticTableId_Currency             = 104
kStaticTableId_CardCrap             = 105
kStaticTableId_EquipmentCrap        = 106
kStaticTableId_Level                = 107
kStaticTableId_LevelReward          = 108
kStaticTableId_Chapter              = 109
kStaticTableId_ProtectPrincessBox   = 110
kStaticTableId_FactoryBoxToFix      = 111
kStaticTableId_Corps                = 112
kStaticTableId_CorpsMap             = 113
kStaticTableId_ClubProp             = 114

-- 金币ID
kCurrencyId_Diamond     = 10410001
kCurrencyId_Coin        = 10410002
kCurrencyId_Exp         = 10410003
kCurrencyId_Geste       = 10410004
kCurrencyId_Princess    = 10410005
kCurrencyId_Vigor       = 10410006
kCurrencyId_Guild       = 10410007
kCurrencyId_War         = 10410008
kCurrencyId_Food        = 10410009
kCurrencyId_Pit         = 10410010
kCurrencyId_Handbook    = 10410011

kItemId_SweepCard				= 10300001	--扫荡卡
kItemId_NormalEnergyExpBattery  = 10300004  -- 经验电池
kItemId_HighEnergyExpBattery    = 10300005  -- 高能经验电池
kItemId_SuperEnergyExpBattery   = 10300006  -- 超能经验电池

--- 战斗类型
kBattleMode_Auto    = 1
kBattleMode_Manual  = 2

--- 战斗选择类型
kTargetSelection_Attack = 1
kTargetSelection_Skill = 2

--- 战斗技能选择模式
kTargetSelectionMode_All                 = 1     -- 全体(不用选择)
kTargetSelectionMode_Horizontal          = 2     -- 横向 前排/后排(不用选择)
kTargetSelectionMode_Vertical            = 3     -- 纵向(不用选择)
kTargetSelectionMode_Cross               = 4     -- 十字(不用选择)
kTargetSelectionMode_FrontRowOrBackRow   = 5     -- 前排或后排(不用选择)
kTargetSelectionMode_Number              = 6     -- 多个选择(1-n)



---- 卡牌控件模式(HeroCardItem)
kCardItemMode_None      = 0 -- 什么都没有
kCardItemMode_Got       = 1 -- 已获得
kCardItemMode_NotGetYet = 2 -- 未获得
kCardItemMode_Fragment  = 3 -- 碎片

---- 卡牌控件选择模式(HeroCardItem)
kCardItemSelectionMode_None = 0   -- 没有选择效果
kCardItemSelectionMode_Radio = 1  -- 单选
kCardItemSelectionMode_Check = 2  -- 多选

--- 英雄卡牌标签类型
kHeroSceneTableType_Hero = 1        -- 英雄
kHeroSceneTableType_Fragment = 2    -- 碎片



---- 商店类型
KShopType_Normal = 1				-- 普通商店
KShopType_ProtectPrincess = 2  		-- 保护公主商店
KShopType_Arena = 3         		-- 竞技场商店
KShopType_BlackMarket = 4         	-- 黑市商店
KShopType_ArmyGroup = 5         	-- 军团商店
KShopType_CountryWar= 6         	-- 国战商店
KShopType_Gem		 = 7         	-- 宝石商店
KShopType_Tower		 = 8         	-- 爬塔商店
--KShopType_Pray 		 = 9         	-- 祈祷商店
KShopType_RoleDebris = 9         	-- 碎片商店
KShopType_GuildPoint = 11           -- 公会积分战商店
KShopType_IntegralShop = 12         -- 抽卡积分战商店
KShopType_LotteryShop = 13         -- 转转乐积分战商店


--- 卡牌颜色类型
KCardColorType_Gray = 0
KCardColorType_Green = 1
KCardColorType_Blue = 2
KCardColorType_Purple = 3
KCardColorType_Orange = 4
KCardColorType_Red = 5
KCardColorType_Black = 6

KCardStageMax = 5

--- 装备类型

KEquipType_EquipInvalid = -1    --- -1.未开启/无效
KEquipType_EquipAll = 0         ---  0.所有
KEquipType_EquipWeapon = 1		---  1.武器
KEquipType_EquipArmor = 2		---  2.防具
KEquipType_EquipAccessories = 3 ---  3.饰品
KEquipType_EquipShoesr = 4 		---  4.鞋子
KEquipType_EquipWing = 5 		---  5.翅膀
KEquipType_EquipSpar = 6 		---  6.晶石
KEquipType_EquipFashion = 7		---  7.时装
KEquipType_Public = 8			---  8.勋章
KEquipType_EquipPet = 10 		--- 10.宠物
KEquipType_EquipGem = 20		--- 20.宝石
KEquipType_EquipBind = 100      --- 100.绑定

--- 背包Item类型
KKnapsackItemType_EquipNormal = 1	--- 普通装备
KKnapsackItemType_Item = 2			--- 普通物品
KKnapsackItemType_EquipDebris = 3 	--- 装备碎片
KKnapsackItemType_EquipPet = 4 		--- 宠物



--- 装备窗口打开类型
KEquipWinShowType_BaseInfo 	= 1		-- 基础属性
KEquipWinShowType_Combine  	= 2		-- 合成
KEquipWinShowType_Powerup	= 3		-- 升级
KEquipWinShowType_Upgrade	= 4		-- 进阶
-- 套装最大数量
KMaxEquipSuitNodeCount = 6

----------音乐以及音效设置---------------------
KBackgroundMusicSetting="BgSound"
KEffectSoundSetting="EffectSound"
KEffectSetting="EffectSet"
--- 玩家最大等级
kMaxPlayerLevelNum = 80


--- 保卫公主 --
kProtectPrincessHeadMode_None = 0
kProtectPrincessHeadMode_Box = 1
kProtectPrincessHeadMode_Fight = 2

kProtectPrincessGateStatus_None = 0
kProtectPrincessGatetatus_NotReceiveYet = 1
kProtectPrincessGateStatus_Failure = 2
kProtectPrincessGateStatus_Received = 3


--- 战斗 ----
kBattleReceiveDamageParam_ActionOnce = 1
kBattleReceiveDamageParam_ActionLoop = 2
kBattleReceiveDamageParam_NoAction = 3


--- 服务器状态 ---
kServerState_Maintain   = 1   -- 维护
kServerState_Justle     = 2   -- 拥挤
kServerState_Prevail    = 3   -- 火爆
kServerState_Fluency    = 4   -- 流畅


kServerIconState_Invisible = 1   -- NoShow
kServerIconState_New = 2      -- 新
kServerIconState_Hot = 3      -- 热


kServerTabType_Role         = 1 -- 角色
kServerTabType_Recommended  = 2 -- 推荐
kServerTabType_All          = 3 -- 所有


--- 战报 ----
kReportArena = 1                   -- 竞技场
kReportGuildPointFighe = 2         -- 公会积分战
kReportElventTree = 3              -- 精灵树

-- 新手引导事件
kGuideEvnt_MainPanel 					= 0
kGuideEvnt_ClickTavern 					= 1
kGuideEvnt_NormalDrawTips 				= 2
kGuideEvnt_NormalDraw 					= 3
kGuideEvnt_DiamondDrawTips 				= 4
kGuideEvnt_DiamondDraw 					= 5
kGuideEvnt_Draw2MainPanel 				= 6
kGuideEvnt_GetReadyDungeonGideTips 		= 7
kGuideEvnt_MainPanel2Dungeon 			= 8
kGuideEvnt_DungeonTips 					= 9
kGuideEvnt_Select1stDungeon 			= 10
kGuideEvnt_Challenge1stDungeon 			= 11
kGuideEvnt_FormationTips 				= 12
kGuideEvnt_Formation_Set1stHero 		= 13
kGuideEvnt_Formation_Set2ndHero 		= 14
kGuideEvnt_Formation_Set3rdHero 		= 15
kGuideEvnt_Formation_AttrTips 			= 16
kGuideEvnt_Formation_StrTips 			= 17
kGuideEvnt_Formation_AgiTips 			= 18
kGuideEvnt_Formation_IntTips 			= 19
kGuideEvnt_Formation2Fight 				= 20
kGuideEvnt_FightTips 					= 21
kGuideEvnt_Fight2Dungeon 				= 22
kGuideEvnt_Dungeon2MainPanel 			= 23
kGuideEvnt_MainPanel2HeroPanel		 	= 24
kGuideEvnt_GoHeroEquipPanel			 	= 25
kGuideEvnt_HeroEquipPanelTips			= 26
kGuideEvnt_SelectInitialHero		 	= 27
kGuideEvnt_HeroLevelupWindowOn			= 28
kGuideEvnt_HeroLevelupWindowtips		= 29
kGuideEvnt_DoHeroLevelup				= 30
kGuideEvnt_HeroLevelupWindowOff			= 31
kGuideEvnt_GetReadyHeroPanelGideTips 	= 32
kGuideEvnt_GreatWork4HeroLevelup		= 33
kGuideEvnt_GetHeroPanelTips		 		= 34
kGuideEvnt_GetReadyEquipGideTips		= 35
kGuideEvnt_3rdGotoCardDetail			= 36
kGuideEvnt_3rdCardDetailTalk			= 37
kGuideEvnt_ClickWeaponFrame				= 38
kGuideEvnt_SelectFirstWeapon			= 46
kGuideEvnt_Confirm2EquipWeapon			= 48
kGuideEvnt_FirstFightWelcome			= 39
kGuideEvnt_FirstFightSkillTips			= 40
kGuideEvnt_FirstFightSkillClick			= 41
kGuideEvnt_NormalDraw1stConfirm			= 42
kGuideEvnt_NormalDraw2ndConfirm			= 43
kGuideEvnt_DiamondDraw1stConfirm		= 44
kGuideEvnt_DiamondDraw2ndConfirm		= 45
kGuideEvnt_ClickWeaponFrameAgain		= 49
kGuideEvnt_EquipmentWindowInfo			= 47
kGuideEvnt_StartMailGuide				= 50
kGuideEvnt_MailGuideInfo				= 51
kGuideEvnt_StartSigninGuide				= 52
kGuideEvnt_SigninGuideInfo				= 53
kGuideEvnt_StartShopGuide				= 54
kGuideEvnt_ShopGuideInfo				= 55
kGuideEvnt_StartElventreeGuide			= 56
kGuideEvnt_ElventreeGuideInfo			= 57
kGuideEvnt_StartChatGuide				= 58
kGuideEvnt_ChatGuideInfo				= 59
kGuideEvnt_StartTaskGuide				= 60
kGuideEvnt_TaskGuideInfo				= 61
kGuideEvnt_2ndFBMainButton				= 62
kGuideEvnt_2ndFBLevelSelect				= 63
kGuideEvnt_2ndFBLevelInfoFight			= 64
kGuideEvnt_2ndFBLevelFight				= 65
kGuideEvnt_ChooseyourGreen				= 66
kGuideEvnt_2ndGotoCardDetail			= 67
kGuideEvnt_2ndCardDetailTalk			= 68
kGuideEvnt_2ndCardUpgrade				= 69
kGuideEvnt_2ndCardUpgradeDone			= 70
kGuideEvnt_3rdFBMainButton				= 71
kGuideEvnt_3rdFBLevelSelect				= 72
kGuideEvnt_3rdFBLevelInfoFight			= 73
kGuideEvnt_3rdFBLevelFight				= 74
kGuideEvnt_ClickweaponPowerupTag		= 75
kGuideEvnt_ClickweaponPowerupButton		= 76
kGuideEvnt_LevelUpJump1					= 77
kGuideEvnt_LevelUpJump2					= 78

--排行榜
kArenaRank         = 1   --竞技场
kGuildFightRank    = 2   --积分战
kTowerRank         = 3   --爬塔

-- 埋点id
kTrackingId_LoginAction                         = 1    -- 登录行为
kTrackingId_MainView                            = 2    -- 主页面
kTrackingId_ProtectThePrincessView              = 3    -- 保卫公主界面
kTrackingId_KameHouseView                       = 4    -- 龟仙屋界面
kTrackingId_ElvenTreeView                       = 5    -- 精灵树界面
kTrackingId_ShopView                            = 6    -- 商店界面
kTrackingId_GuildView                           = 7    -- 军团界面
kTrackingId_MailView                            = 8    -- 邮件界面
kTrackingId_ChapterView                         = 9    -- 副本界面
kTrackingId_ArenaView                           = 10   -- 竞技场界面
kTrackingId_JourneyView                         = 11   -- 探险之旅界面
kTrackingId_CardView                            = 12   -- 角色界面
kTrackingId_CardPowerUpView                     = 13   -- 角色升级界面
kTrackingId_CardUpgradeView                     = 14   -- 角色进阶界面
kTrackingId_CardTalentView                      = 15   -- 角色天赋界面
kTrackingId_CheckInView                         = 16   -- 签到界面
kTrackingId_ActivityView                        = 17   -- 活动界面
kTrackingId_AchievementView                     = 18   -- 成就界面
kTrackingId_DrawCardView                        = 19   -- 抽卡界面
kTrackingId_DrawCardItemAction                  = 20   -- 道具抽行为
kTrackingId_DrawCardDiamondAction               = 21   -- 钻石抽行为
kTrackingId_DrawCardDiamondTenTimesAction       = 22   -- 钻石十连抽行为
kTrackingId_KnapsackView                        = 23   -- 背包界面
kTrackingId_MissionView                         = 24   -- 任务界面
kTrackingId_FriendView                          = 25   -- 好友界面
kTrackingId_BigLibraryView                      = 26   -- 图鉴界面
kTrackingId_BattleView                          = 27   -- 战斗界面
kTrackingId_GuildPointView                      = 28   -- 军团积分战界面



kLocation_Boss = 5  -- boss位置
--- SystemBasis 类型ID
KSystemBasis_ArenaID = 1		    -- 竞技场
KSystemBasis_DefendPrincess = 2     -- 保卫公主
KSystemBasis_GuildID = 4		    -- 公会
KSystemBasis_ElvenTreeID = 5		-- 精灵树
KSystemBasis_ChatID = 6			    -- 聊天
KSystemBasis_HeroLevelUp = 8        -- 英雄升级
KSystemBasis_HeroEquipment = 9      -- 英雄装备
KSystemBasis_HeroStageUp1 = 13      -- 进阶 + 1
KSystemBasis_HeroStageUp2 = 14      -- 进阶 + 2
KSystemBasis_HeroStageUp3 = 15      -- 进阶 + 3
KSystemBasis_HeroStageUp4 = 16      -- 进阶 + 4
KSystemBasis_HeroStageUp5 = 17      -- 进阶 + 5
KSystemBasis_HeroStageUp6 = 18      -- 进阶 + 6
KSystemBasis_Explore = 41           -- 划船
KSystemBasis_TaskID = 10    	    -- 任务
KSystemBasis_MailID = 11		    -- 邮箱
KSystemBasis_CheckID = 12		    -- 签到
KSystemBasis_BlackMarketID = 19     -- 黑市
KSystemBasis_ShopID = 20		    -- 商店
KSystemBasis_Chanllage = 21		    -- 探险之旅
KSystemBasis_DoubleSpeed = 28       -- 2x速战斗
KSystemBasis_GemCombine = 32        -- 宝石合成
KSystemBasis_CardDrawID = 106       -- 酒馆工厂夺宝
kSystemBasis_GuildPointID = 116     -- 公会积分战
kSystemBasis_TowerID = 114          -- 魔龙矿井
kSystemBasis_Zodiac = 42			-- 星座
kSystemBasis_Star = 43				-- 猎魂
kSystemBasis_Sea = 22             -- 大虚志海
kSystemBasis_Magic = 23             -- 魔力战场
kSystemBasis_Live = 26             -- 绝境求生
kSystemBasis_Boss = 39				-- 世界boss
kSystemBasis_Tarot = 44             -- 塔罗牌




-- 塔罗牌状态
kTarotState_Unactive = 0    -- 未激活
kTarotState_Inverted = 1    -- 倒
kTarotState_Straight = 2    -- 正


--购买次数类型
kBuyType_Explore = 0   		--探险
 
 --服务器活动类型
kActivity_Sale = 100     --限时折扣活动



kSystem_Guide={}
--系统引导的ID
kSystem_Guide[1]={}
kSystem_Guide[1].systemGuideID=1											--精灵树引导ID 
kSystem_Guide[1].modleId=KSystemBasis_ElvenTreeID											    --精灵树引导ID 
kSystem_Guide[1].systemGuideStr="ElvenTreeSystemGuide"						--精灵树引导读取持久化字符串
-- kSystem_Guide[1].systemGuideCls="GUI.SystemGuide.NewPlayerGuide"			--精灵树引导脚本名

kSystem_Guide[2]={}
kSystem_Guide[2].systemGuideID=2											--探险引导ID 
kSystem_Guide[2].modleId=KSystemBasis_Explore								--探险引导ID 
kSystem_Guide[2].systemGuideStr="ExploreSystemGuide"						--探险引导读取持久化字符串
-- kSystem_Guide[2].systemGuideCls="GUI.SystemGuide.ExploreSystemGuide"		--探险引导读取持久化字符串

kSystem_Guide[3]={}
kSystem_Guide[3].systemGuideID=3											--副本引导ID 
kSystem_Guide[3].modleId=nil											    --副本引导ID 
kSystem_Guide[3].systemGuideStr="CheckpointSystemGuide"						--副本引导读取持久化字符串
-- kSystem_Guide[3].systemGuideCls="GUI.SystemGuide.CheckpointSystemGuide"	--副本引导读取持久化字符串

kSystem_Guide[4]={}
kSystem_Guide[4].systemGuideID=4											--神秘龙穴引导ID 
kSystem_Guide[4].modleId=KSystemBasis_Chanllage								--神秘龙穴引导ID 
kSystem_Guide[4].systemGuideStr="DragonChallengeSystemGuide"						--神秘龙穴引导读取持久化字符串

kSystem_Guide[5]={}
kSystem_Guide[5].systemGuideID=5											--星座1引导ID 
kSystem_Guide[5].modleId=kSystemBasis_Zodiac								--星座1引导systemID
kSystem_Guide[5].systemGuideStr="ZodiacFirstSystemGuide"						    --星座1引导读取持久化字符串

kSystem_Guide[6]={}
kSystem_Guide[6].systemGuideID=6											--星座1引导ID 
kSystem_Guide[6].modleId=kSystemBasis_Zodiac								--星座1引导systemID
kSystem_Guide[6].systemGuideStr="ZodiacSecondSystemGuide"						    --星座1引导读取持久化字符串


kSystem_Guide[7]={}
kSystem_Guide[7].systemGuideID=7											--大虚之海引导ID 
kSystem_Guide[7].modleId=kSystemBasis_Sea									--大虚之海功能ID 
kSystem_Guide[7].systemGuideStr="SeaChallengeSystemGuide"					--大虚之海引导读取持久化字符串


kSystem_Guide[8]={}
kSystem_Guide[8].systemGuideID=8											--魔力战场引导ID 
kSystem_Guide[8].modleId=kSystemBasis_Magic									--魔力战场功能ID 
kSystem_Guide[8].systemGuideStr="MagicChallengeSystemGuide"					--魔力战场引导读取持久化字符串


kSystem_Guide[9]={}
kSystem_Guide[9].systemGuideID=9											--绝境求生引导ID 
kSystem_Guide[9].modleId=kSystemBasis_Live								    --绝境求生功能ID 
kSystem_Guide[9].systemGuideStr="LiveChallengeSystemGuide"					--绝境求生引导读取持久化字符串

kSystem_Guide[10]={}
kSystem_Guide[10].systemGuideID=10											--任务引导ID 
kSystem_Guide[10].modleId=KSystemBasis_TaskID								--任务功能ID 
kSystem_Guide[10].systemGuideStr="TaskSystemGuide"							--任务引导读取持久化字符串

kSystem_Guide[11]={}
kSystem_Guide[11].systemGuideID=11											--工会引导ID 
kSystem_Guide[11].modleId=KSystemBasis_GuildID								--工会功能ID 
kSystem_Guide[11].systemGuideStr="GuildSystemGuide"							--神秘龙穴引导读取持久化字符串

kSystem_Guide[12]={}
kSystem_Guide[12].systemGuideID=12											--守护雅典娜引导ID 
kSystem_Guide[12].modleId=KSystemBasis_DefendPrincess								--守护雅典娜功能ID 
kSystem_Guide[12].systemGuideStr="PrincessSystemGuide"							--守护雅典娜引导读取持久化字符串

kSystem_Guide[13]={}
kSystem_Guide[13].systemGuideID=13											--爬塔引导ID 
kSystem_Guide[13].modleId=kSystemBasis_TowerID								--爬塔功能ID 
kSystem_Guide[13].systemGuideStr="TowerSystemGuide"							--爬塔引导读取持久化字符串


kSystem_Guide[14]={}
kSystem_Guide[14].systemGuideID=14											--塔罗牌1引导ID 
kSystem_Guide[14].modleId=kSystemBasis_Tarot								--塔罗牌1功能ID 
kSystem_Guide[14].systemGuideStr="TarotFirstSystemGuide"							--塔罗牌1引导读取持久化字符串

kSystem_Guide[15]={}
kSystem_Guide[15].systemGuideID=15											--塔罗牌2引导ID 
kSystem_Guide[15].modleId=kSystemBasis_Tarot								--塔罗牌2功能ID 
kSystem_Guide[15].systemGuideStr="TarotSecondSystemGuide"							--塔罗牌2引导读取持久化字符串

kSystem_Guide[16]={}
kSystem_Guide[16].systemGuideID=16											--塔罗牌3引导ID 
kSystem_Guide[16].modleId=kSystemBasis_Tarot								--塔罗牌3功能ID 
kSystem_Guide[16].systemGuideStr="TarotThirdSystemGuide"					--塔罗牌3引导读取持久化字符串

