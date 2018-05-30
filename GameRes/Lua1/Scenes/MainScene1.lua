local SceneCls = require "Framework.Base.Scene"

local MainScene = Class(SceneCls)

function MainScene:Ctor()
    local MainUINode = require "GUI.Main.MainUINode"
    self:AddChild(MainUINode.New())


end

function MainScene:OnInit()
    
end

function MainScene:OnEnter()
    MainScene.base.OnEnter(self)

    local audioManager = self:GetAudioManager()
    audioManager:FadeInBGM(14)

    -- 设置当前阶段为大厅
    local GamePhase = require "Game.GamePhase"
    self:GetGame():SetGamePhase(GamePhase.Lobby)
end

return MainScene