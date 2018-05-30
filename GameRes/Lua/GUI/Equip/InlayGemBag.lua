local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local net = require "Network.Net"
local messageManager = require "Network.MessageManager"
require "System.LuaDelegate"

local InlayGemBagCls = Class(BaseNodeClass)


----------------------------------------------------------------------
function InlayGemBagCls:Ctor()
	self.callback = LuaDelegate.New()
end

function InlayGemBagCls:OnWillShow(equipID,ctable,func)
	self.equipID = equipID
	self.callback:Set(ctable,func)
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function InlayGemBagCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/GemAddupselect', function(go)
		self:BindComponent(go)
	end)
end

function InlayGemBagCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:InitControls()
end

function InlayGemBagCls:OnResume()
	-- 界面显示时调用
	InlayGemBagCls.base.OnResume(self)
	self:RegisterControlEvents()

	self:LoadScrollNodeContent()
	self:ResetGemBagContent()

	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function InlayGemBagCls:OnPause()
	-- 界面隐藏时调用
	InlayGemBagCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function InlayGemBagCls:OnEnter()
	-- Node Enter时调用
	InlayGemBagCls.base.OnEnter(self)
end

function InlayGemBagCls:OnExit()
	-- Node Exit时调用
	InlayGemBagCls.base.OnExit(self)
end


function InlayGemBagCls:IsTransition()
    return false
end

function InlayGemBagCls:OnExitTransitionDidStart(immediately)
	InlayGemBagCls.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

function InlayGemBagCls:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end
-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function InlayGemBagCls:InitControls()
	self.myGame = utility:GetGame()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find("Base")

	-- 返回按钮
	self.ReturnButton = transform:Find('Base/GemAddupReturnButton'):GetComponent(typeof(UnityEngine.UI.Button))
	
	--  滑动挂点
	self.scrollTrans = transform:Find('Base/SelectYourGem')
end


function InlayGemBagCls:RegisterControlEvents()	
	-- -- 注册 返回 的事件
	 self.__event_button_onReturnButtonClicked__ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked, self)
	 self.ReturnButton.onClick:AddListener(self.__event_button_onReturnButtonClicked__)
end

function InlayGemBagCls:UnregisterControlEvents()

	-- --取消注册 返回 的事件
	if self.__event_button_onReturnButtonClicked__ then
		self.ReturnButton.onClick:RemoveListener(self.__event_button_onReturnButtonClicked__)
		self.__event_button_onReturnButtonClicked__ = nil
	end

end


-----------------------------------------------------------------------
function InlayGemBagCls:LoadScrollNodeContent()
  -- 加载 批量出售滑动控件
  self.ScrollNode = require "GUI.Equip.InlayGemBagScrollNode".New(self.scrollTrans,self,self.OnItemClicked)
  self:AddChild(self.ScrollNode)
end
function InlayGemBagCls:OnItemClicked(node,index,itemID,data)
	local uid = data:GetEquipUID()
	self.callback:Invoke(uid)
	self:OnReturnButtonClicked()
end


-----------------------------------------------------------------------
function InlayGemBagCls:ResetGemBagContent()

	-- 刷新背包数据
	local UserDataType = require "Framework.UserDataType"
	
	local data,count

	local tempData = self:GetCachedData(UserDataType.EquipBagData)
    data = tempData:RetrievalByResultFunc(function(item)
       local itemType = item:GetEquipType()

       if  itemType == KEquipType_EquipGem then
          local uid = item:GetEquipUID()
          return true,uid
        end

        return nil 
      end)
  	count = data:Count()
  	
  self.ScrollNode:UpdateScrollContent(count,data)
end


-----------------------------------------------------------------------
function InlayGemBagCls:OnReturnButtonClicked()
	-- 返回事件
	self:Close()

end




return InlayGemBagCls