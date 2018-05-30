--
-- User: fbmly
-- Date: 4/28/17
-- Time: 11:48 AM
--

local BaseNodeClass = require "Framework.Base.Node"
require "System.LuaDelegate"

local utility = require "Utils.Utility"

local FightingTarget = Class(BaseNodeClass)

function FightingTarget:Ctor(transform)
    self.callback = LuaDelegate.New()

    self:BindComponent(transform, false)
    self:InitControls()
end

function FightingTarget:InitControls()
    local transform = self:GetUnityTransform()

    -- 按钮
    self.Button = transform:GetComponent(typeof(UnityEngine.UI.Button))

    -- 底图(分蓝 红)
    self.Image = transform:Find("Image"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 底图(分蓝 红)
    self.BaseImg = transform:Find("Base"):GetComponent(typeof(UnityEngine.UI.Image))

    -- 立绘图
    self.HeadImg = transform:Find("Image/Icon"):GetComponent(typeof(UnityEngine.UI.Image))

    -- selection
    self.SelectionObject = transform:Find("Selection").gameObject
end

function FightingTarget:IsAlive()
    return self.battleUnit ~= nil and self.battleUnit:IsAlive()
end

function FightingTarget:GetBattleUnit()
    return self.battleUnit
end

function FightingTarget:SetData(battleUnit)
    print("FightingTarget:SetData >>>> ", battleUnit)
    self:Close()
    self.battleUnit = battleUnit
    self:UpdateView()
    self:RegisterEvents()
end

function FightingTarget:IsSelected()
    return self.isSelected
end

function FightingTarget:SetSelected(selected)
    self.isSelected = selected
    if selected then
        self.SelectionObject:SetActive(true)
    else
        self.SelectionObject:SetActive(false)
    end
end

function FightingTarget:Close()
    self:UnregisterEvents()
    self.BaseImg.material = utility.GetGrayMaterial()
    self.HeadImg.material = utility.GetGrayMaterial()
    self.Image.material = utility.GetGrayMaterial()
    self.HeadImg.enabled = false
    self.HeadImg.sprite = nil
    self.battleUnit = nil
    self:SetSelected(false)
end

function FightingTarget:SetCallback(table, func)
    self.callback:Set(table, func)
end

function FightingTarget:UpdateView()
    print("FightingTarget >>>> 1")

    if self.battleUnit == nil then
        return
    end

    print("FightingTarget >>>> 2")
    -- 加载头像 --
    self.HeadImg.enabled = false
    utility.LoadRoleHeadIcon(self.battleUnit:GetId(), self.HeadImg)
	self.HeadImg.enabled = true
    -- TODO 可以按照目标不同状态 显示不同效果
    if not self.battleUnit:IsAlive() then
        print("FightingTarget >>>> 4")
        self.BaseImg.material = utility.GetGrayMaterial()
        self.HeadImg.material = utility.GetGrayMaterial()
        self.Image.material = utility.GetGrayMaterial()
    else
        local AtlasesLoader = require "Utils.AtlasesLoader"

        if self.battleUnit:OnGetSide() == 1 then
			local atlasName = "Fighting"
			utility.LoadAtlasesSprite(atlasName,"BlueBase",self.Image)
			utility.LoadAtlasesSprite(atlasName,"BlueCircle",self.BaseImg)
        else
			local atlasName = "Fighting"
			utility.LoadAtlasesSprite(atlasName,"RedBase",self.Image)
			utility.LoadAtlasesSprite(atlasName,"RedCircle",self.BaseImg)
        end

        print("FightingTarget >>>> 5")
        -- # 活着时的状态 # --
        self.BaseImg.material = utility.GetCommonMaterial()
        self.HeadImg.material = utility.GetCommonMaterial()
        self.Image.material = utility.GetCommonMaterial()
    end
    print("FightingTarget >>>> 6")
end


function FightingTarget:RegisterEvents()
    self.__event_button_ButtonClicked__ = UnityEngine.Events.UnityAction(self.OnButtonClicked, self)
    self.Button.onClick:AddListener(self.__event_button_ButtonClicked__)
end

function FightingTarget:UnregisterEvents()
    if self.__event_button_ButtonClicked__ then
        self.Button.onClick:RemoveListener(self.__event_button_ButtonClicked__)
        self.__event_button_ButtonClicked__ = nil
    end
end

function FightingTarget:OnButtonClicked()
    if self.battleUnit ~= nil and self.battleUnit:IsAlive() and not self.isSelected then
        self.callback:Invoke(self.battleUnit, self)
    end
end

return FightingTarget