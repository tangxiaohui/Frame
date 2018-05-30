
local BaseNodeClass = require "Framework.Base.Node"
local utility = require "Utils.Utility"
require "System.LuaDelegate"

local InitialCardItemNode = Class(BaseNodeClass)

local function LoadHeroHead(self)
    utility.LoadRoleHeadIcon(self.data:GetRoleId(), self.HeroHeadImage)
end

function InitialCardItemNode:Ctor(id, itemTransform)
    -- 加载卡牌数据
    local InitialCardMgr = require "StaticData.InitialCard"
    self.data = InitialCardMgr:GetData(id)
    self.callback = LuaDelegate.New()
    self.lastToggleState = false
    self:BindComponent(itemTransform.gameObject)
    self:InitControls()
    LoadHeroHead(self)
end

function InitialCardItemNode:SetSelected(isSelect)
    self.HeroButtonToggle.isOn = isSelect
end

function InitialCardItemNode:SetCallback(table, func)
    self.callback:Add(table, func)
end

-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function InitialCardItemNode:OnComponentReady()
    -- 界面加载完毕 初始化函数(只走一次)

end

function InitialCardItemNode:OnResume()
    -- 界面显示时调用
    InitialCardItemNode.base.OnResume(self)
    self:RegisterControlEvents()
end

function InitialCardItemNode:OnPause()
    -- 界面隐藏时调用
    InitialCardItemNode.base.OnPause(self)
    self:UnregisterControlEvents()
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function InitialCardItemNode:InitControls()
    local transform = self:GetUnityTransform()

    self.HeroButtonToggle = transform:GetComponent(typeof(UnityEngine.UI.Toggle))
    self.HeroHeadImage = transform:Find("Head/Base/CardHead"):GetComponent(typeof(UnityEngine.UI.Image))
    self.FrameObject = transform:Find("LightBase").gameObject
	self.FrameObject2 = transform:Find("Frame").gameObject
    self.NameText = transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.NameText.text = self.data:GetName()
end

function InitialCardItemNode:RegisterControlEvents()
    -- 注册 HeroButton 的事件
    self.__event_toggle_onHeroButtonValueChanged__ = UnityEngine.Events.UnityAction_bool(self.OnHeroButtonValueChanged, self)
    self.HeroButtonToggle.onValueChanged:AddListener(self.__event_toggle_onHeroButtonValueChanged__)
end

function InitialCardItemNode:UnregisterControlEvents()
    -- 取消注册 HeroButton 的事件
    if self.__event_toggle_onHeroButtonValueChanged__ then
        self.HeroButtonToggle.onValueChanged:RemoveListener(self.__event_toggle_onHeroButtonValueChanged__)
        self.__event_toggle_onHeroButtonValueChanged__ = nil
    end
end

-----------------------------------------------------------------------
--- 事件处理
-----------------------------------------------------------------------
function InitialCardItemNode:OnHeroButtonValueChanged(isToggle)
    --HeroButton控件的点击事件处理
    if self.lastToggleState ~= isToggle then
        self.lastToggleState = isToggle

        -- 效果
        local transform = self:GetUnityTransform()
        if isToggle then
            transform.localScale = Vector3(1, 1, 1)
            transform:SetAsLastSibling()
        else
            transform.localScale = Vector3(0.8, 0.8, 1)
        end
        self.FrameObject:SetActive(isToggle)
		self.FrameObject2:SetActive(isToggle)

        -- 回调
        if isToggle then
            self.callback:Invoke(
                self.data:GetRoleId(),
                self.data:GetName(),
                self.data:GetDesc(),
                self.data:GetPortraitImage()
            )
        end
    end
end

return InitialCardItemNode