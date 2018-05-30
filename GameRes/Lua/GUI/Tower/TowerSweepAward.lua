local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
local gameTool = require "Utils.GameTools"
require "System.LuaDelegate"

local TowerSweepAward = Class(BaseNodeClass)
windowUtility.SetMutex(TowerSweepAward, true)

local width = 633
local hight = 60
local hightAdd = 130

function  TowerSweepAward:Ctor()
	
end
function TowerSweepAward:GetRootHangingPoint()
    return self:GetUIManager():GetDialogLayer()
end
function TowerSweepAward:OnWillShow(item,index,ctable,func)
	self.item = item
	self.index = index
	if ctable ~= nil and func ~= nil then
		self.callback = LuaDelegate.New()
		self.callback:Set(ctable,func)
	end
end

function  TowerSweepAward:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/TowerSweepAward",function(go)
		self:BindComponent(go)
	end)
end

function TowerSweepAward:OnComponentReady()
	self:InitControls()
end

function TowerSweepAward:OnResume()
	TowerSweepAward.base.OnResume(self)
	self:FadeIn(function(self, t)
        local transform = self.transform

        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
    self:LoadPanel()
	self:RegisterControlEvents()
end

function TowerSweepAward:OnPause()
	TowerSweepAward.base.OnPause(self)
	self:UnregisterControlEvents()
end

function TowerSweepAward:OnEnter()
	TowerSweepAward.base.OnEnter(self)
end

function TowerSweepAward:OnExit()
	TowerSweepAward.base.OnExit(self)
end



function  TowerSweepAward:InitControls()
	local transform = self:GetUnityTransform()
	self.transform = transform:Find("Base")
	self.base = transform:Find("Base/Base")
	self.Title = transform:Find("Base/Title"):GetComponent(typeof(UnityEngine.UI.Text))
	self.confirmButton = transform:Find("return"):GetComponent(typeof(UnityEngine.UI.Button))
	self.awardPoint = transform:Find("Base/Scroll View/Viewport/AwardLayout")
	self.scroll = transform:Find("Base/Scroll View")
	self.viewport = transform:Find("Base/Scroll View/Viewport")
end

----------------------------------------------------------------------------
--动画处理--
----------------------------------------------------------------------------
function TowerSweepAward:IsTransition()
    return true
end

-- ## 在这里执行 淡出函数! (immediately 值只针对 WindowNode 及其子类)
function TowerSweepAward:OnExitTransitionDidStart(immediately)
    TowerSweepAward.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.transform

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end

----------------------------------------------------------------------------
--事件处理--
----------------------------------------------------------------------------
function TowerSweepAward:RegisterControlEvents()
	--注册确定事件
	self._event_button_onConfirmButtonClicked_ = UnityEngine.Events.UnityAction(self.OnConfirmButtonClicked,self)
	self.confirmButton.onClick:AddListener(self._event_button_onConfirmButtonClicked_)

end

function TowerSweepAward:UnregisterControlEvents()
	--取消注册确定事件
	if self._event_button_onConfirmButtonClicked_ then
		self.confirmButton.onClick:RemoveListener(self._event_button_onConfirmButtonClicked_)
		self._event_button_onConfirmButtonClicked_ = nil
	end

end

function TowerSweepAward:OnConfirmButtonClicked()
	self:Close(true)
	if self.callback ~= nil then
		self.callback:Invoke()
	end
end

--加载界面
function TowerSweepAward:LoadPanel()
	for i=1,#self.item do
		local _,data,itemName,iconPath,itemType = gameTool.GetItemDataById(self.item[i].itemID)
		local color = gameTool.GetItemColorByType(itemType,data)
		self:LoadItem(self.item[i].itemID,self.item[i].itemNum,color)
	end
	self:SetBaseHight(#self.item)
	if self.index == 1 then
		self.Title.text = "一键三星获得"
	elseif self.index == 2 then
		self.Title.text = "转转乐获得"
	elseif self.index == 3 then
		self.Title.text = "恭喜获得"
	elseif self.index == 4 then
		self.Title.text = "恭喜兑换获得"
	
	end
end

function TowerSweepAward:LoadItem(id,count,color)
	local node = require "GUI.Task.AwardItem".New(self.awardPoint,id,count,color)
	self:AddChild(node)
end

function TowerSweepAward:SetBaseHight(number)
	-- number = math.ceil(number/4)
	-- self.base.sizeDelta =Vector2(width,hight + number * hightAdd)
	-- self.scroll.sizeDelta =Vector2(width,hight + number * hightAdd)
	-- self.viewport.sizeDelta =Vector2(width,hight + number * hightAdd)
end

return TowerSweepAward