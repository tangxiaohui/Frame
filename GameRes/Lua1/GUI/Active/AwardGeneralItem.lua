local GeneralItemClass = require "GUI.Item.GeneralItem"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local AwardGeneralItemCls = Class(GeneralItemClass)

function AwardGeneralItemCls:Ctor(parentTransform, itemID, itemNum, itemColor,itemType)

    self.protect=protect
    self.itemID=itemID
    self.itemColor=itemColor 
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function AwardGeneralItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/MyGeneralItem', function(go)
		self:BindComponent(go)
	end)
end
function AwardGeneralItemCls:OnResume()
    -- 界面显示时调用
    AwardGeneralItemCls.base.OnResume(self)
  --  self:RegisterControlEvents()
--    self:RegisterNetworkEvents()
    self:InitViews()
end
function AwardGeneralItemCls:OnPause()
	-- 界面隐藏时调用
	AwardGeneralItemCls.base.OnPause(self)
  --  self:InitViews()
	--self:UnregisterControlEvents()

--	self:UnregisterNetworkEvents()
end

function AwardGeneralItemCls:OnEnter()
	-- Node Enter时调用
	AwardGeneralItemCls.base.OnEnter(self)
end

function AwardGeneralItemCls:OnExit()
	-- Node Exit时调用
	AwardGeneralItemCls.base.OnExit(self)
end

--初始化显示
function AwardGeneralItemCls:InitViews()
  --   -- body
  -- --  print(self.itemType)
  -- --print(")))))))))))))))))))))))))))))))))))))))))))))))))")
    
  --   local GameTools = require "Utils.GameTools"
  --   local _,staticData,_,iconPath,itemType = GameTools.GetItemDataById(self.itemID)
  --   if self.itemType==0 then
  --     --  self.ItemInfoButton.enabled=true      
  --       self.RedDot.enabled=true
  --       self.effect.gameObject:SetActive(true)
        
  --       iconPath=staticData:GetIconInOpen()
  --       iconPath="UI/Atlases/Icon/FactoryIcon/"..iconPath
  --        print("@@@@@@@@@@@@@@可开启@@@@@@@@@@@@@@",self.itemID,iconPath)
  --        utility.LoadSpriteFromPath(iconPath,self.ItemIconTran)
  --        local defaultColor = GameTools.GetItemColorByType(itemType, staticData)
  --        local image = self.effect.transform.gameObject:GetComponentInChildren(typeof(UnityEngine.UI.Image))
  --        image.color=self.color[defaultColor]
  --   else
  --       iconPath=staticData:GetIconInRepair()
  --        print("@@@@@@@@@@@@@不可开启@@@@@@@@@@@@@@@",self.itemID,iconPath)
  --       utility.LoadSpriteFromPath("UI/Atlases/Icon/FactoryIcon/"..iconPath,self.ItemIconTran)
  --      -- self.ItemInfoButton.enabled=false
  --       self.RedDot.enabled=false
  --       self.effect.gameObject:SetActive(false)
  --   end

  --    if self.protect==1 then
  --    	self.ShieldImage.enabled=true
  --    end

end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function AwardGeneralItemCls:InitControls()
   AwardGeneralItemCls.base.InitControls(self)
	local transform = self:GetUnityTransform()
  self.rectTransform = transform:GetComponent(typeof(UnityEngine.RectTransform))
  self.rectTransform.sizeDelta = Vector2(80,80)
 -- --   print("AwardGeneralItemCls:InitControls()")

 --    self.game=utility.GetGame()
 --    self.ItemIconTran=transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
 --    self.effect=transform:Find('ItemIcon/UI_dan')
 --  	self.ItemInfoButton =  self.ItemIconTran.gameObject:AddComponent(typeof(UnityEngine.UI.Button))
 --  	self.ShieldImage = transform:Find('ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image)) 
 --  	self.ShieldImage.enabled=false
 --    self.RedDot = transform:Find('RedDot'):GetComponent(typeof(UnityEngine.UI.Image)) 
 --    self.RedDot.enabled=false
 
    

  
end


function AwardGeneralItemCls:RegisterControlEvents()
	-- -- 注册 ItemInfoButton 的事件
	-- self.__event_button_onItemInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnItemInfoButtonClicked, self)
	-- self.ItemInfoButton.onClick:AddListener(self.__event_button_onItemInfoButtonClicked__)



end

function AwardGeneralItemCls:UnregisterControlEvents()
	-- -- 取消注册 ItemInfoButton 的事件
	-- if self.__event_button_onItemInfoButtonClicked__ then
	-- 	self.ItemInfoButton.onClick:RemoveListener(self.__event_button_onItemInfoButtonClicked__)
	-- 	self.__event_button_onItemInfoButtonClicked__ = nil
	-- end


end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function AwardGeneralItemCls:OnItemInfoButtonClicked()
	
end



return AwardGeneralItemCls

