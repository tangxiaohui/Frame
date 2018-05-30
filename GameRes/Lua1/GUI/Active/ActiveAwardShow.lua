local BaseNodeClass = require "Framework.Base.WindowNode"
local utility = require "Utils.Utility"
local net = require "Network.Net"
local windowUtility = require "Framework.Window.WindowUtility"

local ActiveAwardShow = Class(BaseNodeClass)
windowUtility.SetMutex(ActiveAwardShow, true)

function ActiveAwardShow:Ctor()
end

function ActiveAwardShow:OnWillShow(data,id)
	self.data = data
	self.id = id
end

function  ActiveAwardShow:OnInit()
	utility.LoadNewGameObjectAsync("UI/Prefabs/ActiveAwardShow",function(go)
		self:BindComponent(go)
	end)
end

function ActiveAwardShow:OnComponentReady()
	self:InitControls()
end

function ActiveAwardShow:OnResume()
	ActiveAwardShow.base.OnResume(self)
	self:RegisterControlEvents()
	self:LoadItem(self.data,self.id)
	self:FadeIn(function(self, t)
        local transform = self.tweenObjectTrans
        local TweenUtility = require "Utils.TweenUtility"
        local s = TweenUtility.EaseOutBack(0, 1, t)

        transform.localScale = Vector3(s, s, s)
    end)
end

function ActiveAwardShow:OnPause()
	ActiveAwardShow.base.OnPause(self)
	self:UnregisterControlEvents()
end

function ActiveAwardShow:OnEnter()
	ActiveAwardShow.base.OnEnter(self)
end

function ActiveAwardShow:OnExit()
	ActiveAwardShow.base.OnExit(self)
end

function ActiveAwardShow:IsTransition()
    return true
end

function ActiveAwardShow:OnExitTransitionDidStart(immediately)
	ActiveAwardShow.base.OnExitTransitionDidStart(self, immediately)

    if not immediately then
        self:FadeOut(function(self, t)
            local transform = self.tweenObjectTrans

            local TweenUtility = require "Utils.TweenUtility"

            local s = TweenUtility.EaseInBack(1, 0, t)
            transform.localScale = Vector3(s, s, s)
        end)
    end
end


function ActiveAwardShow:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function ActiveAwardShow:InitControls()
	local transform = self:GetUnityTransform()
	self.tweenObjectTrans = transform:Find("SmallWindowBase")
	self.returnButton = self.tweenObjectTrans:Find("ButtonLayout/NovicePacksReceiveButton"):GetComponent(typeof(UnityEngine.UI.Button))
	self.childPoint = self.tweenObjectTrans:Find("ItemListLayout")

	self.myGame = utility:GetGame()
end

function ActiveAwardShow:RegisterControlEvents()
	--注册退出事件
	self._event_button_onReturnButtonClicked_ = UnityEngine.Events.UnityAction(self.OnReturnButtonClicked,self)
	self.returnButton.onClick:AddListener(self._event_button_onReturnButtonClicked_)

end

function ActiveAwardShow:UnregisterControlEvents()
	--取消注册退出事件
	if self._event_button_onReturnButtonClicked_ then
		self.returnButton.onClick:RemoveListener(self._event_button_onReturnButtonClicked_)
		self._event_button_onReturnButtonClicked_ = nil
	end

end

function ActiveAwardShow:OnReturnButtonClicked()
	self:Close(true)
end

function ActiveAwardShow:LoadItem(data,id)
	local data = require (data):GetData(id)
	local nodeCls = require "GUI.Active.ActiveAwardItem"
	local count = data:GetItemID().Count - 1
	local gametool = require "Utils.GameTools"
	for i=0,count do
		local id = data:GetItemID()[i]
		local num = data:GetItemNum()[i]
		debug_print(num)
		local _,data,_,_,itype = gametool.GetItemDataById(id)
        local color = gametool.GetItemColorByType(itype,data)
		local node = nodeCls.New(self.childPoint,id,num,color)
		self:AddChild(node)
	end
end

return ActiveAwardShow