--
-- User: fenghao
-- Date: 11/07/2017
-- Time: 4:25 PM
--

require "Object.LuaObject"
local utility = require "Utils.Utility"

local UIScreenWarning = Class(LuaObject)

function UIScreenWarning:Ctor(canvas)
   
    self.canvas = canvas

    -- 加载对象 --
    utility.LoadNewPureGameObjectAsync("Effect/Effects/UI/Warning", function(gameObject)
        self.particleSystemObject = gameObject
        self.particleSystemTransform = gameObject.transform
        self.particleSystemTransform:SetParent(self.canvas:GetCanvasTransform(), true)
        self.particleSystemTransform.localScale = Vector3(1, 1, 1)
        self.particleSystemTransform.localPosition = Vector3(0, 0, 0)
        self.particleSystemTransform.localRotation = Quaternion.identity
    end)
end


function UIScreenWarning:Start()
   
end

function UIScreenWarning:Reset()
   
end

return UIScreenWarning
