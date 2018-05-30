require "Object.LuaObject"
require "Const"
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"

-- # 装备数据 # --
EquipDataCls = Class(LuaObject)

-- # 获取静态装备数据
local function GetStaticEquipData(id)
	return require "StaticData.Equip":GetData(id)
end

-- # 获取静态装备文本数据
local function GetStaticEquipInfoData(id)
	return require "StaticData.EquipInfo":GetData(id)
end

function EquipDataCls:Ctor()
    self.EquipAttributeDict = OrderedDictionary.New()
end

-- 装备UID
function EquipDataCls:GetEquipUID()
    return self.equipUID
end

-- 装备ID
function EquipDataCls:GetEquipID()
    return self.equipID
end

-- 等级
function EquipDataCls:GetLevel()
    return self.level
end

-- 槽位
function EquipDataCls:GetPos()
    return self.pos
end

-- 绑定在哪个人物身上
function EquipDataCls:GetBindCardUID()
    return self.bindCardUID
end

-- 穿在哪个人物身上
function EquipDataCls:GetOnWhichCard()
    return self.onWhichCard
end

-- 翅膀经验值
function EquipDataCls:GetExp()
    return self.exp
end

-- 翅膀颜色
function EquipDataCls:GetColor()
    return self.color
end

-- 宝石列表ID
function EquipDataCls:GetStoneID()
    return self.stoneID
end

-- 宝石UID列表(字符串 逗号分隔)
function EquipDataCls:GetStoneUID()
    return self.stoneUID
end
-- 宝石UID个数
function EquipDataCls:GetStoneCount()
    local uids = self:GetStoneUID()

    if string.find(uids,",",1) == 1 then
        uids = string.format("%s%s"," ",uids)
    end
    
    local StoneUIdTable = utility.Split(uids,",")
    if uids == " ," then
       -- hzj_print("未镶嵌宝石")
        return 0
    else
        return #StoneUIdTable

    end


    return self.stoneUID
end
-- 装备类型
function EquipDataCls:GetEquipType()
	return self.staticData:GetType()
end

-- 装备名称
function EquipDataCls:GetName()
	return self.staticInfoData:GetName()
end

-- 装备描述
function EquipDataCls:GetDesc()
	return self.staticInfoData:GetDesc()
end

-- 装备其他描述
function EquipDataCls:GetFakeDesc()
	return self.staticInfoData:GetFakeDesc()
end

-- 获取星级
function EquipDataCls:GetStar()
	return self.staticData:GetStarID()
end

--ssr
function EquipDataCls:GetRarity()
	return self.staticData:GetRarity()
end

-- 镶嵌数量
function EquipDataCls:GetGemNum()
	return self.staticData:GetGemNum()
end

-- 镶嵌类型
function EquipDataCls:GetPrice()
	return self.staticData:GetBasePrice()
end

-- 宝石类型
function EquipDataCls:GetFillInType()
    return self.staticData:GetFillInType()
end

-- 主属性是否只有种族额外加成
function EquipDataCls:IsMainPropOnlyAddRace()
    return self.staticData:GetMainPropOnlyAddRace() ~= 0
end

-- 获取种族加成的种族ID
function EquipDataCls:GetRaceAdd()
    return self.staticData:GetRaceAdd()
end

function EquipDataCls:GetTaozhuangID()
    return self.staticData:GetTaozhuangID()
end

function EquipDataCls:GetKnapsackItemType()
    return KKnapsackItemType_EquipNormal
end
----------------------------------------------------

local function InitStaticData(self)
    self.staticData = GetStaticEquipData(self.equipID)
    self.staticInfoData = GetStaticEquipInfoData(self.equipID)
end


function EquipDataCls:GetEquipStaticData()
    return self.staticData
end

function EquipDataCls:UpdateData(data)
    -- 更新方法
    self.equipUID = data.equipUID
    self.equipID = data.equipID
    self.level = data.level
    self.pos = data.pos
    self.bindCardUID = data.bindCardUID
    self.onWhichCard = data.onWhichCard
    self.exp = data.exp
    self.color = data.color
    self.stoneID = data.stoneID
    self.stoneUID = data.stoneUID
    
    InitStaticData(self)
end

-------------------------------------------------------
function EquipDataCls:AddAttributeToDict(condition,key,value)
    if not condition then
        self.EquipAttributeDict:Add(key,value)
    end
end

local function CalculateFixedValue(basis, addition, level)
	return basis + (level - 1) * addition
end

local function calculateFixeValue(basis,addition,level)
    return CalculateFixedValue(basis, addition, level)
end

function EquipDataCls:CalculateAddValue(basis,addition,level)
    return CalculateFixedValue(basis,addition,level)
end


function EquipDataCls:GetEquipAttribute()
    -- 主属性Id
    local mainPropID = self.staticData:GetMainPropID()

    self.EquipAttributeDict:Clear()
   
    local basis
    local condition

    -- 添加到属性字典中
    for key = 1,kPropertyID_MaxCount do
        condition,basis =  self:GetBasisValue(key)

        if key == mainPropID then
            -- 计算升级后的主属性
            local addition = self.staticData:GetPromoteValue()
            temp = calculateFixeValue(basis,addition,self.level)

            basis = temp
        end

        self:AddAttributeToDict(condition,key,basis)
    end

    return self.EquipAttributeDict, mainPropID
end


function EquipDataCls:GetBasisValue(equipType)
    -- 获取属性基础属性

    -- 基础属性
    local basis
    -- 是否为空
    local condition

    if equipType == kPropertyID_HpLimit then
        -- 生命
        basis = self.staticData:GetHpLimit()
        condition = (basis == 0)
        return condition, basis

    elseif equipType == kPropertyID_HpLimitRate then
        -- 生命强化
        basis = self.staticData:GetHpLimit_prop()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_Dp then
        -- 防御
        basis = self.staticData:GetFangyu()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_DpRate then
        -- 防御强化
        basis = self.staticData:GetFangyu_prop()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_Ap then
        -- 攻击
        basis = self.staticData:GetGongjili()
        condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_ApRate then
        -- 攻击强化
        basis = self.staticData:GetGongjili_prop()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_CritRate then
        -- 暴击
        basis = self.staticData:GetBaojilv()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_DecritRate then
        -- 抗暴
        basis = self.staticData:GetKangbaoProp()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_HitRate then
        -- 命中
        basis = self.staticData:GetMingzhongProp()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_AvoidRate then
        -- 闪避
        basis = self.staticData:GetShanbiProp()
        condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_Speed then
        -- 速度
        basis = self.staticData:GetSpeed()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_SkillDamage then
        -- 技能强化
        basis = self.staticData:GetAddJigongHurt()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_AttackDamage then
        -- 普攻强化
        basis = self.staticData:GetAddPugongHurt()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_VamRate then
        -- 吸血
        basis = self.staticData:GetXixueProp()
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_CritDamageRate then
        -- 暴击伤害系数
        basis = self.staticData:GetBaojiHurt()
         condition = (basis == 0)
        return condition, basis
    end

    error("装备属性 类型错误")
    return nil

end



-- // >>>>>> 卡牌装备 <<<<<<
-- message EquipOnCardStruct
-- {
-- 	optional string uid 		= 1;	// UID
-- 	optional int32 id 			= 2;	// ID
-- 	optional int32 level 		= 3;	// 等级
-- 	optional int32 pos 			= 4;	// 位置
-- 	optional string bindCardUID = 5;	// 绑定的卡牌UID
-- 	optional string onWhichCard = 6;	// 穿在哪个卡牌身上(卡牌UID)
-- 	optional int32 wingExp 		= 7 [default = 0];	// 翅膀经验(仅当装备类型为翅膀时 才有效)
-- 	optional int32 wingColor 	= 8 [default = 0];	// 翅膀颜色(仅当装备类型为翅膀时 才有效)
-- 	repeated int32 gemIds 		= 9;	// 宝石ID列表
-- 	optional string gemUids 	= 10;	// 宝石UID字符串序列(以逗号分隔)
-- }


-- msg = EquipOnCardStruct
function EquipDataCls:CopyToProtobuf(msg)
    msg.uid = self:GetEquipUID()
    msg.id = self:GetEquipID()
    msg.level = self:GetLevel()
    msg.pos = self:GetPos()
    msg.bindCardUID = self:GetBindCardUID()
    msg.onWhichCard = self:GetOnWhichCard()
    msg.wingExp = self:GetExp()
    msg.wingColor = self:GetColor()
    
    local stoneID = self:GetStoneID()
    for i = 1, #stoneID do
        msg.gemIds:append(stoneID[i])
    end

    msg.gemUids = self:GetStoneUID()
end

-- msg = EquipOnCardStruct
function EquipDataCls:InitByProtobuf(msg)
    self.equipUID = msg.uid
    self.equipID = msg.id
    self.level = msg.level
    self.pos = msg.pos
    self.bindCardUID = msg.bindCardUID
    self.onWhichCard = msg.onWhichCard
    self.exp = msg.wingExp
    self.color = msg.wingColor

    -- gemIds
    self.stoneID = msg.gemIds
    self.stoneUID = msg.gemUids
end

return EquipDataCls