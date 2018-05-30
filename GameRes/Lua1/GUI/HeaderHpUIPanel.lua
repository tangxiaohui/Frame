require "GUI.Panel"
require "Collection.OrderedDictionary"
local utility = require "Utils.Utility"


HeaderHpUIPanel = Class(Panel)

function HeaderHpUIPanel:Ctor()
    self.coHpChangeAnim = nil
    self.buffIconInstanceDict = OrderedDictionary.New()
end

function HeaderHpUIPanel:OnResourceLoaded()
    HeaderHpUIPanel.base.OnResourceLoaded(self)

    local localScale = self.transform.localScale
    localScale.x = 0.8
    localScale.y = 0.8
    localScale.z = 0.8
    self.transform.localScale = localScale

    self.hpSliderImage = self.transform:Find("Life/Base/Hp"):GetComponent(typeof(UnityEngine.UI.Image))
    self.hpDamageSliderImage = self.transform:Find("Life/Base/Damage"):GetComponent(typeof(UnityEngine.UI.Image))

    self.energyGroup = {
        self.transform:Find("Energy/Energy1").gameObject,
        self.transform:Find("Energy/Energy2").gameObject,
        self.transform:Find("Energy/Energy3").gameObject,
        self.transform:Find("Energy/Energy4").gameObject,
        self.transform:Find("Energy/Energy5").gameObject,
    }

    self.buffGroupTrans = self.transform:Find("Buff")
end

function HeaderHpUIPanel:SetRage(rage)
    for i = 1, #self.energyGroup do
        self.energyGroup[i]:SetActive(i <= rage)
    end
end

local function ResetCoroutine(self)
    if self.coHpChangeAnim ~= nil then
        coroutine.stop(self.coHpChangeAnim)
        self.coHpChangeAnim = nil
    end
end

local totalTime = 0.1
local function DelayHpChangeAnim(self, ratio)
    self.hpSliderImage.fillAmount = ratio
    local TweenUtility = require "Utils.TweenUtility"


    local passedTime = 0
    local finished = false

    local startRatio = self.hpDamageSliderImage.fillAmount
    local endRatio = ratio

    repeat
        local t = passedTime / totalTime
        if t >= 1 then
            t = 1
            finished = true
        end

        if self.hpDamageSliderImage ~= nil then
            self.hpDamageSliderImage.fillAmount = TweenUtility.Linear(startRatio, endRatio, t)
        end

        passedTime = passedTime + UnityEngine.Time.unscaledDeltaTime
        coroutine.step(1)
    until(finished == true)
end

function HeaderHpUIPanel:AddBuff(stateId, iconPath)
    if self.buffIconInstanceDict:Contains(stateId) then
        error(string.format("重复添加buff图标, id", stateId))
    end
	
	if iconPath:len() == 0 then
		return
	end

    local prefab = utility.LoadResourceSync("UI/Prefabs/BattleBuffInfo", typeof(UnityEngine.GameObject))
    local go = UnityEngine.Object.Instantiate(prefab)
    local transform = go.transform
    transform:SetParent(self.buffGroupTrans, true)
    transform.localScale = Vector3.New(1, 1, 1)
    transform.localPosition = Vector3.New(0, 0, 0)
    transform.localEulerAngles = Quaternion.identity
    
    local buffImage = transform:Find("BuffIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    utility.LoadAtlasesSprite("BUFF", iconPath, buffImage)
    
    self.buffIconInstanceDict:Add(stateId, go)
end

function HeaderHpUIPanel:RemoveBuff(stateId)
    local go = self.buffIconInstanceDict:GetEntryByKey(stateId)
    if go ~= nil then
        UnityEngine.Object.Destroy(go)
        self.buffIconInstanceDict:Remove(stateId)
    end
end

function HeaderHpUIPanel:SetHp(curHp, maxHp)
    ResetCoroutine(self)

    local utility = require "Utils.Utility"
    local ratio = utility.Clamp01(curHp / maxHp)
    coroutine.start(DelayHpChangeAnim, self, ratio)
end

function HeaderHpUIPanel:SetRightMode()
end

function HeaderHpUIPanel:Clear()
    ResetCoroutine(self)

    if self.gameObject ~= nil then
        UnityEngine.Object.Destroy(self.gameObject)
        self.gameObject = nil
    end
end
