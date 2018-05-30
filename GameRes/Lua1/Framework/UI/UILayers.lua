--
-- User: fbmly
-- Date: 3/22/17
-- Time: 12:32 AM
--

require "Object.LuaObject"

UILayers = Class(LuaObject)

local function InitThingsAboutLayers(self)
    self.layerRootTransform = self.canvasTransform:Find("UILayers")

    -- Background
    self.layerBackground = self.layerRootTransform:Find('Background')

    -- Foreground
    self.layerForeground = self.layerRootTransform:Find('Foreground')

    -- Module
    self.layerModule = self.layerRootTransform:Find('Module')

    -- Dialog
    self.layerDialog = self.layerRootTransform:Find('Dialog')

    -- Overlay
    self.layerOverlay = self.layerRootTransform:Find('Overlay')
end

function UILayers:Ctor(uiManager, canvasTransform)
    self.uiManager = uiManager
    self.canvasTransform = canvasTransform
    InitThingsAboutLayers(self)
end


function UILayers:GetBackgroundLayer()
    return self.layerBackground
end

function UILayers:GetForegroundLayer()
    return self.layerForeground
end

function UILayers:GetModuleLayer()
    return self.layerModule
end

function UILayers:GetDialogLayer()
    return self.layerDialog
end

function UILayers:GetOverlayLayer()
    return self.layerOverlay
end