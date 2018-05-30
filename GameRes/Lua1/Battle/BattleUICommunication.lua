local NodeClass = require "Framework.Base.UINode"

local BattleUICommunication = Class(NodeClass)

local MagicTexts = {"与服务器通信中",".",".",".",".",".","."}

local MaxPos = 7

local function InitControls(self)
    local transform = self:GetUnityTransform()
    self.tipLabel = transform:Find("Text"):GetComponent(typeof(UnityEngine.UI.Text))
    self.coUpdate = nil
end

local function SetTip(self, text)
    self.tipLabel.text = text
end

local function UpdateTip(self, pos)
    SetTip(
        self,
        table.concat(MagicTexts, nil, 1, pos)
    )
end

local function OnUpdate(self)
    repeat
        coroutine.wait(0.3)
        self.currentPos = self.currentPos + 1
        if self.currentPos > MaxPos then
            self.currentPos = 1
        end
        UpdateTip(self, self.currentPos)
    until(false)
end

local function StopUpdateCoroutine(self)
    if self.coUpdate ~= nil  then
        self:StopCoroutine(self.coUpdate)
        self.coUpdate = nil
    end
end

local function StartUpdateCoroutine(self)
    StopUpdateCoroutine(self)
    self.coUpdate = self:StartCoroutine(OnUpdate)
end

function BattleUICommunication:Ctor(transform)
    self:BindComponent(transform.gameObject, false)
    InitControls(self)
end

function BattleUICommunication:Show()
    self.currentPos = 1
    UpdateTip(self, self.currentPos)
    self:ActiveComponent()
    StartUpdateCoroutine(self)
end

function BattleUICommunication:Hide()
    StopUpdateCoroutine(self)
    self.currentPos = 1
    self:InactiveComponent()
end

function BattleUICommunication:OnResume()
end

function BattleUICommunication:OnPause()
end

return BattleUICommunication
