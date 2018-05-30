require "Event.EventHandler"

CameraPathEventHandler = Class(EventHandler)

function CameraPathEventHandler:ToString()
	return "CameraPathEventHandler"
end

local cameraPathEventHandler = CameraPathEventHandler.New()

local function OnCameraPathFinished(handler, name)
	handler:OnCameraPathFinished(name)
end

function _G.CameraPathOnFinish(name)
	cameraPathEventHandler:Dispatch(OnCameraPathFinished, name)
end

function _G.ClearCameraPathEventHandler()
	cameraPathEventHandler:Clear()
end

return cameraPathEventHandler