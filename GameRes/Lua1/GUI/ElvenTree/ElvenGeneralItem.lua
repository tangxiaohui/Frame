local GeneralItemClass = require "GUI.Item.GeneralItem"
local utility = require "Utils.Utility"
local net = require "Network.Net"
-- local messageManager = require "Network.MessageManager"
local ElvenGeneralItemCls = Class(GeneralItemClass)

function ElvenGeneralItemCls:Ctor(parentTransform, itemID, itemNum, itemColor,itemType,itemUID,protect)
 --   print(" ElvenGeneralItemCls:Cto")
    self.itemType = itemType
    self.itemUID=itemUID
    self.protect=protect
    self.itemID=itemID
    self.itemColor=itemColor
     self.color={}
  self.color[1]=UnityEngine.Color(217/255,1,165/255,0)
  self.color[2]=UnityEngine.Color(159/255,211/255,1,0)
  self.color[3]=UnityEngine.Color(226/255,159/255,1,0)
--    print(self.itemType ,self.itemID,self.itemUID)
 
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function ElvenGeneralItemCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ElvenGeneralItem', function(go)
		self:BindComponent(go)
	end)
end
function ElvenGeneralItemCls:OnResume()
    -- 界面显示时调用
    ElvenGeneralItemCls.base.OnResume(self)
  --  self:RegisterControlEvents()
--    self:RegisterNetworkEvents()
self:InitViews()
end
function ElvenGeneralItemCls:OnPause()
	-- 界面隐藏时调用
	ElvenGeneralItemCls.base.OnPause(self)
  --  self:InitViews()
	--self:UnregisterControlEvents()

--	self:UnregisterNetworkEvents()
end

function ElvenGeneralItemCls:OnEnter()
	-- Node Enter时调用
	ElvenGeneralItemCls.base.OnEnter(self)
end

function ElvenGeneralItemCls:OnExit()
	-- Node Exit时调用
	ElvenGeneralItemCls.base.OnExit(self)
end

-- function ElvenGeneralItemCls:OnComponentReady()
--    ElvenGeneralItemCls.base.OnComponentReady(self)
--   -- 界面加载完毕 初始化函数(只走一次)
--     if self.itemType==0 then
--      --   self.ItemInfoButton.enabled=true
--         local resPathMgr = require "StaticData.ResPath"
--         local data = resPathMgr:GetData(1039)
--         local path=data:GetPath()  
--         local go = utility.LoadResourceSync(path, typeof(UnityEngine.GameObject))
--         go.gameObject.transform:SetParent(self.ItemIconTran)
--         print(go,"@@@@@@@@@@@@@@@@@@@@@@@@@@")
--          local GameTools = require "Utils.GameTools"
--          local _,staticData,_,iconPath,itemType = GameTools.GetItemDataById(self.itemID)
--          local defaultColor = GameTools.GetItemColorByType(itemType, staticData)
--          local image = go.gameObject:GetComponentInChildren(typeof(UnityEngine.UI.Image))
--          image.color=self.color[self.itemColor or defaultColor]
--       --  self.RedDot.enabled=true
--     end
-- end

--初始化显示
function ElvenGeneralItemCls:InitViews()
    -- body
  --  print(self.itemType)
  --print(")))))))))))))))))))))))))))))))))))))))))))))))))")
    
    local GameTools = require "Utils.GameTools"
    local _,staticData,_,iconPath,itemType = GameTools.GetItemDataById(self.itemID)
    if self.itemType==0 then
      --  self.ItemInfoButton.enabled=true      
        self.RedDot.enabled=true
        self.effect.gameObject:SetActive(true)
        
        iconPath=staticData:GetIconInOpen()
        iconPath="UI/Atlases/Icon/FactoryIcon/"..iconPath
         print("@@@@@@@@@@@@@@可开启@@@@@@@@@@@@@@",self.itemID,iconPath)
         utility.LoadSpriteFromPath(iconPath,self.ItemIconTran)
         local defaultColor = GameTools.GetItemColorByType(itemType, staticData)
         local image = self.effect.transform.gameObject:GetComponentInChildren(typeof(UnityEngine.UI.Image))
         image.color=self.color[defaultColor]
    else
        iconPath=staticData:GetIconInRepair()
         print("@@@@@@@@@@@@@不可开启@@@@@@@@@@@@@@@",self.itemID,iconPath)
        utility.LoadSpriteFromPath("UI/Atlases/Icon/FactoryIcon/"..iconPath,self.ItemIconTran)
       -- self.ItemInfoButton.enabled=false
        self.RedDot.enabled=false
        self.effect.gameObject:SetActive(false)
    end

     if self.protect==1 then
     	self.ShieldImage.enabled=true
     end

end


-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function ElvenGeneralItemCls:InitControls()
   ElvenGeneralItemCls.base.InitControls(self)
	local transform = self:GetUnityTransform()
 --   print("ElvenGeneralItemCls:InitControls()")

    self.game=utility.GetGame()
    self.ItemIconTran=transform:Find('ItemIcon'):GetComponent(typeof(UnityEngine.UI.Image))
    self.effect=transform:Find('ItemIcon/UI_dan')
  	self.ItemInfoButton =  self.ItemIconTran.gameObject:AddComponent(typeof(UnityEngine.UI.Button))
  	self.ShieldImage = transform:Find('ShieldImage'):GetComponent(typeof(UnityEngine.UI.Image)) 
  	self.ShieldImage.enabled=false
    self.RedDot = transform:Find('RedDot'):GetComponent(typeof(UnityEngine.UI.Image)) 
    self.RedDot.enabled=false
 
    

  
end


function ElvenGeneralItemCls:RegisterControlEvents()
	-- 注册 ItemInfoButton 的事件
	self.__event_button_onItemInfoButtonClicked__ = UnityEngine.Events.UnityAction(self.OnItemInfoButtonClicked, self)
	self.ItemInfoButton.onClick:AddListener(self.__event_button_onItemInfoButtonClicked__)



end

function ElvenGeneralItemCls:UnregisterControlEvents()
	-- 取消注册 ItemInfoButton 的事件
	if self.__event_button_onItemInfoButtonClicked__ then
		self.ItemInfoButton.onClick:RemoveListener(self.__event_button_onItemInfoButtonClicked__)
		self.__event_button_onItemInfoButtonClicked__ = nil
	end


end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function ElvenGeneralItemCls:OnItemInfoButtonClicked()
	--ItemInfoButton控件的点击事件处理
  --  print(self.itemUID)
  if self.itemType==0 then
    self.game:SendNetworkMessage(require "Network.ServerService".RobOpenBoxRequest(self.itemUID))
    print(self.itemUID,"请求打开",debug.traceback())
  else
    local windowManager = self.game:GetWindowManager()
    windowManager:Show(require "GUI.ElvenTree.ElvenTreeEggDoneNow",self.itemUID,self.itemID)
  end
end



return ElvenGeneralItemCls

