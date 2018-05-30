require "StaticData.Manager"
require "Const"
require "Collection.OrderedDictionary"

local EquipData = Class(LuaObject)

local function AddPropertyValue(properties, id, value)
	properties:AddValue(id, value)
end

local function InitBasicProperties(self)
	local PropertySetClass = require "Game.Property.PropertySet"
	self.basicProperties = PropertySetClass.New()
	
	local properties = self.basicProperties

	-- @ 1. 最大生命值
	AddPropertyValue(properties, kPropertyID_HpLimit, self.data.hpLimit)

	-- @ 2. 最大生命系数
	AddPropertyValue(properties, kPropertyID_HpLimitRate, self.data.hpLimit_prop)

	-- @ 3. 防御力值
	AddPropertyValue(properties, kPropertyID_Dp, self.data.fangyu)

	-- @ 4. 防御力系数
	AddPropertyValue(properties, kPropertyID_DpRate, self.data.fangyu_prop)

	-- @ 5. 攻击力值
	AddPropertyValue(properties, kPropertyID_Ap, self.data.gongjili)

	-- @ 6. 攻击力系数
	AddPropertyValue(properties, kPropertyID_ApRate, self.data.gongjili_prop)

	-- @ 7. 暴击率
	AddPropertyValue(properties, kPropertyID_CritRate, self.data.baojilv)

	-- @ 8. 抗暴率
	AddPropertyValue(properties, kPropertyID_DecritRate, self.data.kangbaoProp)

	-- @ 9. 命中率
	AddPropertyValue(properties, kPropertyID_HitRate, self.data.mingzhongProp)

	-- @ 10. 闪避率
	AddPropertyValue(properties, kPropertyID_AvoidRate, self.data.shanbiProp)

	-- @ 11. 速度
	AddPropertyValue(properties, kPropertyID_Speed, self.data.speed)

	-- @ 12. 技能伤害
	AddPropertyValue(properties, kPropertyID_SkillDamage, self.data.addJigongHurt)

	-- @ 13. 普攻伤害
	AddPropertyValue(properties, kPropertyID_AttackDamage, self.data.addPugongHurt)

	-- @ 14. 吸血率
	AddPropertyValue(properties, kPropertyID_VamRate, self.data.xixueProp)

	-- @ 15. 暴击伤害系数
	AddPropertyValue(properties, kPropertyID_CritDamageRate, self.data.baojiHurt)
end

function EquipData:Ctor(id)
    local EquipMgr = Data.Equip.Manager.Instance()
    self.data = EquipMgr:GetObject(id)
    if self.data == nil then
        error(string.format("装备信息不存在，ID: %s 不存在", id))
        return
    end

	--InitBasicProperties(self)
end

function EquipData:GetId()
    return self.data.id
end

function EquipData:GetInfo()
    return self.data.info
end

function EquipData:GetIcon()
    return self.data.icon
end

function EquipData:GetBasePrice()
    return self.data.basePrice
end

function EquipData:GetType()
    return self.data.type
end

function EquipData:IsShow()
	return self.data.show
end

function EquipData:GetFillInType()
    return self.data.fillInType
end

function EquipData:GetGemType()
    return self.data.gemType
end

function EquipData:GetGemNum()
    return self.data.gemNum
end

function EquipData:GetColorID()
    return self.data.colorID
end

function EquipData:GetStarID()
    return self.data.starID
end

function EquipData:GetRarity()
    local rarityData = require "StaticData.StartoSSR":GetData(self.data.starID)
    return rarityData:GetSSR()
end

function EquipData:GetNeedJiebangNum()
    return self.data.needJiebangNum
end

function EquipData:GetTaozhuangID()
    return self.data.taozhuangID
end

function EquipData:GetZhuanyou()
    return self.data.zhuanyou
end

function EquipData:GetRaceAdd()
    return self.data.raceAdd
end

function EquipData:GetStopJigong()
    return self.data.stopJigong
end

function EquipData:GetChangeAnger()
    return self.data.changeAnger
end

function EquipData:GetMainPropOnlyAddRace()
    return self.data.mainPropOnlyAddRace
end

function EquipData:GetMainPropID()
    return self.data.mainPropID
end

function EquipData:GetPromoteValue()
    return self.data.promoteValue
end

function EquipData:GetGongjili()
    return self.data.gongjili
end

function EquipData:GetGongjili_prop()
    return self.data.gongjili_prop
end

function EquipData:GetHpLimit()
    return self.data.hpLimit
end

function EquipData:GetHpLimit_prop()
    return self.data.hpLimit_prop
end

function EquipData:GetFangyu_prop()
    return self.data.fangyu_prop
end

function EquipData:GetFangyu()
    return self.data.fangyu
end

function EquipData:GetSpeed()
    return self.data.speed
end

function EquipData:GetBaojilv()
    return self.data.baojilv
end

function EquipData:GetBaojiHurt()
    return self.data.baojiHurt
end

function EquipData:GetKangbaoProp()
    return self.data.kangbaoProp
end

function EquipData:GetMingzhongProp()
    return self.data.mingzhongProp
end

function EquipData:GetShanbiProp()
    return self.data.shanbiProp
end

function EquipData:GetXixueProp()
    return self.data.xixueProp
end

function EquipData:GetAddPugongHurt()
    return self.data.addPugongHurt
end

function EquipData:GetAddJigongHurt()
    return self.data.addJigongHurt
end






function EquipData:GetEquipAttribute()
    -- 获取属性
    local dict = OrderedDictionary.New()

    local mainPropID = self.data.mainPropID
    local basis
    local condition
    -- 添加到属性字典中
    for key = 1,kPropertyID_MaxCount do
        condition,basis =  self:GetBasisValue(key)
        if not condition then
            dict:Add(key,basis)
        end
    end

    return dict,mainPropID
end

function EquipData:GetBasisValue(equipType)
    --获取属性基础属性
    
    -- 基础属性
    local basis
    -- 是否为空
    local condition

    if equipType == kPropertyID_HpLimit then
        -- 生命
        basis = self.data.hpLimit
        condition = (basis == 0)
        return condition, basis

    elseif equipType == kPropertyID_HpLimitRate then
        -- 生命强化
        basis = self.data.hpLimit_prop
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_Dp then
        -- 防御
        basis = self.data.fangyu
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_DpRate then
        -- 防御强化
        basis = self.data.fangyu_prop
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_Ap then
        -- 攻击
        basis = self.data.gongjili
        condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_ApRate then
        -- 攻击强化
        basis = self.data.gongjili_prop
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_CritRate then
        -- 暴击
        basis = self.data.baojilv
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_DecritRate then
        -- 抗暴
        basis = self.data.kangbaoProp
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_HitRate then
        -- 命中
        basis = self.data.mingzhongProp
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_AvoidRate then
        -- 闪避
        basis = self.data.shanbiProp
        condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_Speed then
        -- 速度
        basis = self.data.speed
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_SkillDamage then
        -- 技能强化
        basis = self.data.addJigongHurt
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_AttackDamage then
        -- 普攻强化
        basis = self.data.addPugongHurt
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_VamRate then
        -- 吸血
        basis = self.data.xixueProp
         condition = (basis == 0)
        return condition, basis

     elseif equipType == kPropertyID_CritDamageRate then
        -- 暴击伤害系数
        basis = self.data.baojiHurt
         condition = (basis == 0)
        return condition, basis
    end

    error("装备属性 类型错误")
    return nil

end

local EquipManager = Class(DataManager)
local EquipDataMgr = EquipManager.New(EquipData)
return EquipDataMgr