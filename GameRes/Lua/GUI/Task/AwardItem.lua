--
-- User: fbmly
-- Date: 4/17/17
-- Time: 9:38 PM
--

local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"

local AwardItemCls = Class(BaseNodeClass)

function AwardItemCls:Ctor(parentTransform, itemID, itemNum, itemColor)
  --  print(" AwardItemCls:Cto")
    self.parentTransform = parentTransform

    self.itemID = itemID
    self.itemNum = itemNum
    self.itemColor = itemColor
end

function AwardItemCls:OnInit()
    -- 加载界面(只走一次)
    utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
        self:BindComponent(go, false)
    end)
end

function AwardItemCls:SetScaleFactor(x, y, z)
    if not self:HasUnityGameObject() then
        self.resetScale = true
        self.scaleX = x or 1
        self.scaleY = y or 1
        self.scaleZ = z or 1
        return
    end

    local transform = self:GetUnityTransform()

    if self.resetScale then
        transform.localScale = Vector3(self.scaleX, self.scaleY, self.scaleZ)
        self.resetScale = nil
        self.scaleX = nil
        self.scaleY = nil
        self.scaleZ = nil
    else
        transform.localScale = Vector3(x or 1, y or 1, z or 1)
    end
end

function AwardItemCls:OnComponentReady()
    self:LinkComponent(self.parentTransform)
    self:InitControls()
end

function AwardItemCls:InitControls()
    local transform = self:GetUnityTransform()
    self.NumLabel = transform:Find("GeneralItemNumLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.ItemIcon = transform:Find("ItemIcon"):GetComponent(typeof(UnityEngine.UI.Image))
    self.ColorFrameGroupTrans = transform:Find("Frame")
    
    self.NameLabel = transform:Find("ItemNameLabel"):GetComponent(typeof(UnityEngine.UI.Text))
    self.NumLabel.gameObject:SetActive(self.itemNum ~= 1)
    self.NumLabel.text = self.itemNum

    local debris = transform:Find("DebrisIcon").gameObject
    local debrisCorner = transform:Find("DebrisCorner").gameObject

    local AtlasesLoader = require "Utils.AtlasesLoader"

    local GameTools = require "Utils.GameTools"
    local _,_,name,iconPath = GameTools.GetItemDataById(self.itemID)

    -- 设置名字
    self.NameLabel.gameObject:SetActive(true)
    self.NameLabel.text =name

    -- 设置图标
	utility.LoadSpriteFromPath(iconPath,self.ItemIcon)

    local gametool = require "Utils.GameTools"
    local _,data,_,_,itype = gametool.GetItemDataById(self.itemID)
    if self.itemColor == -1 then
        self.itemColor = gametool.GetItemColorByType(itype,data)
    end

    -- 设置颜色
    local PropUtility = require "Utils.PropUtility"
    PropUtility.AutoSetRGBColor(self.ColorFrameGroupTrans, self.itemColor )

    if (itype == "RoleChip" or itype == "EquipChip") then
        debris:SetActive(true)
        debrisCorner:SetActive(true)
    end

end

function AwardItemCls:OnResume()
    AwardItemCls.base.OnResume(self)
    self:SetScaleFactor(0.91, 0.91, 1)
    self.NumLabel.text = self.itemNum
end

return AwardItemCls

