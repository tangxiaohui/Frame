--
-- User: fenghao
-- Date: 20/06/2017
-- Time: 5:53 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local HeroEquipmentSlot = Class(BaseNodeClass)
local utility = require "Utils.Utility"
local calculateRed = require"Utils.CalculateRed"
local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.mainButton = transform:GetComponent(typeof(UnityEngine.UI.Button))
    self.parentTransform = transform:Find("parent")
    self.fgImg = transform:Find("Fg"):GetComponent(typeof(UnityEngine.UI.Image))
    self.fg2ImgObject = transform:Find("Fg2").gameObject
	
	-- # 获取十字 # --
	local crossTransform = transform:Find("UI_huxi_shizi")
	if crossTransform ~= nil then
		self.crossAnimator = crossTransform:GetComponent(typeof(UnityEngine.Animator))
		self.crossImage = crossTransform:Find("shizi"):GetComponent(typeof(UnityEngine.UI.Image))
	end
end

function HeroEquipmentSlot:Ctor(pos, transform)
    self.equipType = nil
    self.pos = pos
    self.ItemView = nil
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

local function OnMainButtonClicked(self)
    local messageGuids = require "Framework.Business.MessageGuids"
    self:DispatchEvent(messageGuids.HeroEquipmentSlotClicked, nil, self)
end

function HeroEquipmentSlot:OnResume()
    HeroEquipmentSlot.base.OnResume(self)

    -- 注册 主按钮事件 --
    self.__event_mainButtonClicked__ = UnityEngine.Events.UnityAction(OnMainButtonClicked, self)
    self.mainButton.onClick:AddListener(self.__event_mainButtonClicked__)
end

function HeroEquipmentSlot:OnPause()
    HeroEquipmentSlot.base.OnPause(self)

    -- 取消注册 主按钮事件 --
    if self.__event_mainButtonClicked__ then
        self.mainButton.onClick:RemoveListener(self.__event_mainButtonClicked__)
        self.__event_mainButtonClicked__ = nil
    end
end

function HeroEquipmentSlot:GetType()
    return self.equipType
end

function HeroEquipmentSlot:SetType(type)
    debug_print(type,"self.fgImg");
    if self.equipType ~= type then
        self.equipType = type
        utility.LoadEquipmentSlotTypeIcon(type,self.fgImg)
    end
end

function HeroEquipmentSlot:SetOwner(owner)
	self.owner = owner  -- Game.Role
end

function HeroEquipmentSlot:GetPos()
    return self.pos
end

function HeroEquipmentSlot:GetItemData()
    return self.itemData
end
function HeroEquipmentSlot:SetRedDot()
    if self.ItemView ~= nil then
        self.ItemView:SetRedDot(calculateRed.GetRoleEquipRedDataByIDAndPos(self.owner:GetId(),self:GetPos()))
    end
end

local function GetAvailableEquipmentCount(self, equipType, roleUid)
	local UserDataType = require "Framework.UserDataType"
    local equipBagData = self:GetCachedData(UserDataType.EquipBagData)

    debug_print(">>>>>>")
	local dict = equipBagData:RetrievalByResultFunc(function(item)
        
      --  hzj_print("@@@@ 装备ID", item:GetEquipID(), "装备类型", item:GetEquipType(), "装备槽类型", self.equipType, "装备槽位置", self.pos, "绑定UID", item:GetBindCardUID(), "穿戴在", item:GetOnWhichCard(), "当前卡牌", roleUid)
		
		-- @ 非当前装备类型
		if item:GetEquipType() ~= self.equipType then
			return false
		end
        
        -- @ 有绑定 and 绑定的不是自己
        local bindCardUID = item:GetBindCardUID()
        if type(bindCardUID) == "string" and bindCardUID ~= "" and bindCardUID ~= roleUid then
            return false
        end

        -- @ 有装备到身上的!
        local whichCardUID = item:GetOnWhichCard()
        if type(whichCardUID) == "string" and whichCardUID ~= "" then
            return false
        end

        -- @ 当前装备ID已经存在了!
        if equipBagData:ExistsOnCardEquipDict(item:GetEquipID(), roleUid) then
            return false
        end
		
		return true, item:GetEquipUID()
		
    end)
    --debug_print("<<<<<<", dict:Count())
	return dict:Count()
end

local function GetEquipParameters(self)
    local level = nil
    if self.equipType==KEquipType_EquipAccessories or self.pos == KEquipType_EquipShoesr then
        self.level=nil
    else
        level= self.itemData:GetLevel()

    end

    return  self.parentTransform,
            self.itemData:GetEquipID(), 
            1, 
            self.itemData:GetColor(), 
           level,
            _G.unpack(self.itemData:GetStoneID() or {})
end

function HeroEquipmentSlot:SetEquipment(itemUID)
    if itemUID == nil then
        self:Reset()
        return
    end

    local UserDataType = require "Framework.UserDataType"
    local equipBagData = self:GetCachedData(UserDataType.EquipBagData)
    local itemData = equipBagData:GetItem(itemUID)
    debug_print(itemUID,"itemUID")
    if self.ItemView ~= nil then
        self:Reset()
        self.itemData = itemData
        self.ItemView:Set(GetEquipParameters(self))
        self:AddChild(self.ItemView)
        self.ItemView:SetRedDot(calculateRed.GetRoleEquipRedDataByIDAndPos(self.owner:GetId(),self:GetPos()))
    else
        self.itemData = itemData
        local GeneralItemClass = require "GUI.Item.GeneralItem"
        self.ItemView = GeneralItemClass.New(GetEquipParameters(self))
        self:AddChild(self.ItemView)
        self.ItemView:SetRedDot(calculateRed.GetRoleEquipRedDataByIDAndPos(self.owner:GetId(),self:GetPos()))

    end
    self.fg2ImgObject:SetActive(false)
end


function HeroEquipmentSlot:UpdateStatus()
	if self.crossAnimator == nil then
		return
	end

	if self.itemData ~= nil then
		self.crossAnimator.enabled = false
		self.crossImage.enabled = false
	else

        local count = 0
        local isOpen = false

        if self.equipType == KEquipType_EquipWing then
            count = 1

            local staticWingData = require "StaticData.EquiWing":GetData(self.owner:GetbeishiID())
            local needCount = staticWingData:GetNeedBuildNum()

            local UserDataType = require "Framework.UserDataType"
            local itemUserData = self:GetCachedData(UserDataType.ItemBagData)
            if itemUserData ~= nil then
                local hasBuildNum = itemUserData:GetItemCountById(staticWingData:GetNeedSuipianID())
                local coinNeeded = staticWingData:GetNeedCoin()
                local ownedCoin = self:GetCachedData(UserDataType.PlayerData):GetCoin()
                debug_print(ownedCoin, coinNeeded, type(ownedCoin), type(coinNeeded))
                isOpen = ownedCoin >= coinNeeded and hasBuildNum >= needCount
            end
        else
            count = GetAvailableEquipmentCount(self, self.equipType, self.owner:GetUid())
            isOpen = utility.IsCanOpenModule(KSystemBasis_HeroEquipment, true)
        end

		-- count 大于 0 时则代表可以穿戴
		if isOpen and count > 0 then
			self.crossAnimator.enabled = true
			self.crossAnimator:Play("UI_huxi_shizi", -1, 0)
			self.crossAnimator:Update(0)
			self.crossImage.enabled = true
		else
			self.crossAnimator.enabled = false
			self.crossImage.enabled = false
		end
	end
end

function HeroEquipmentSlot:Reset()
    if self.ItemView ~= nil then
        self:RemoveChild(self.ItemView)
    end
    self.fg2ImgObject:SetActive(true)
    self.itemData = nil
end

return HeroEquipmentSlot
