local unityUtils = require "Utils.Unity"
require "Enum"

Battlefield = Class(LuaGameObject)
require "Battle.Battlefield_CameraBloom"

-------- ### 私有函数 ### --------

local function FindChildObject(self, name)
	local trans = unityUtils:FindChild(self.__battleSceneRoot__, name)
	if trans == nil then
		error(string.format("未找到子物体: %s", name))
	end
	return trans.gameObject
end

local function SetCurrentCamera(self, cameraObject)
	self.cameras.currentCamera = cameraObject
end

-- Bloom 处理函数 --

-- 当前摄像机非激活时的处理函数 --
local function OnInactiveCamera(self, cameraObject)
	self:DisableBloomEffect(cameraObject)
end

-- 当前激活摄像机时的处理函数
local function OnActiveCamera(self, cameraObject)
	-- 1. 处理Bloom效果 --
	self:EnableBloomEffect(cameraObject)
end

local function GetOrCreateRadiarBlurEffect(cameraObject)
	local blur = cameraObject:GetComponent(typeof(RadialBlur))
	if blur == nil then
		blur = cameraObject:AddComponent(typeof(RadialBlur))
	end
	blur.enabled = false
	return blur
end

function Battlefield:SetupCameras()
	-- 初始化Bloom
	self:SetupBlooms()

	self.__battleSceneRoot__ = unityUtils:FindGameObject("__BattleSceneRoot__").transform

	-- 主要的那些摄像机的Parent对象 --
	self.rootCameraParent = FindChildObject(self, "Root_H/CameraParent")

	-- 场景
	self.sceneEnvironment = unityUtils:FindGameObject("Environment")

	-- 位置的节点
	self.sceneVirtualPositionTrans = unityUtils:FindChild(self.__battleSceneRoot__, "Pos")

	-- BattleUnit放置的父节点
	self.sceneBattleUnitParentTrans = unityUtils:FindChild(self.__battleSceneRoot__, "Role")
	
	-- 主要摄像机
	self.cameras = {}
	self.cameras.showOffAtBeginning = FindChildObject(self, "Root_H/CameraParent/Camera_B_R") -- 默认摄像机
	self.cameras.skillSelection = FindChildObject(self, "Root_H/CameraParent/Camera_R_Skill") -- 手动技能时的摄像机

	-- 路径
	self.cameraPaths = {}
	self.cameraPaths.showOffAtBeginning = FindChildObject(self, "Root_H/Camera_Path_B_R") -- 默认摄像机路径(出场)
	self.cameraPaths.skillSelection = FindChildObject(self, "Root_H/Camera_Path_R_Skill") -- 手动技能时的移动摄像机路径
	
	-- 当前摄像机
	self:ActiveCameraObject(self.cameras.showOffAtBeginning)
end

--获取场景
function Battlefield:GetSceneEnvironment()
	return self.sceneEnvironment
end

function Battlefield:GetSceneRootTransform()
	return self.__battleSceneRoot__
end

local function GetPosName(side)
	if side == Side.Left then
		return "LPos"
	else
		return "RPos"
	end
end

function Battlefield:GetBattleUnitVirtualTransform(side, location)
	return self.sceneVirtualPositionTrans:Find(
		string.format("%s%d", GetPosName(side), location)
	)
end

function Battlefield:GetBattleUnitParentTransform()
	return self.sceneBattleUnitParentTrans
end

function Battlefield:GetRootCameraParent()
	return self.rootCameraParent
end

function Battlefield:GetCameraShowOffAtBeginning()
	return self.cameras.showOffAtBeginning
end

function Battlefield:GetCurrentCamera()
	return self.cameras.currentCamera
end

function Battlefield:GetSkillSelectionCamera()
	return self.cameras.skillSelection
end

function Battlefield:GetDefaultCameraObject()
	return self:GetCameraShowOffAtBeginning()
end

function Battlefield:SetActiveCurrentCameraObject(active)
	self:GetCurrentCamera():SetActive(active)
end

function Battlefield:ActiveCameraObject(cameraObject)
	if cameraObject == nil then
		return nil
	end
	local oldCamera = self:GetCurrentCamera()
	if oldCamera ~= cameraObject then
		if oldCamera ~= nil then
			oldCamera:SetActive(false)
			OnInactiveCamera(self, oldCamera)
		end
		cameraObject:SetActive(true)
		SetCurrentCamera(self, cameraObject)
		OnActiveCamera(self, cameraObject)
		return oldCamera
	end
	return nil
end

function Battlefield:ResetToDefaultCameraObject()
	local defaultCameraObject = self:GetDefaultCameraObject()
	self:ActiveCameraObject(defaultCameraObject)
end

function Battlefield:GetCameraPathShowOffAtBeginning()
	return self.cameraPaths.showOffAtBeginning
end

function Battlefield:GetCameraPathSkillSelection()
	return self.cameraPaths.skillSelection
end

function Battlefield:PlaySkillSelectionCameraPath(unit)
	-- 设置摄像机 --
	local skillSelectionCamera = self:GetSkillSelectionCamera()
	self:ActiveCameraObject(skillSelectionCamera)

	-- 播放摄像机路径 --
	local skillSelectionCameraPath = self:GetCameraPathSkillSelection()
	skillSelectionCameraPath:SendMessage("Stop")
	skillSelectionCameraPath:SendMessage("Play")

	-- 设置位置 --
	local cameraPathTransform = skillSelectionCameraPath.transform
	local unitTransform = unit:GetGameObject().transform
	cameraPathTransform.position = unitTransform.position
	cameraPathTransform.rotation = unitTransform.rotation
end

function Battlefield:ResetSkillSelectionCameraPath()
	local currentCameraObject = self:GetCurrentCamera()
	local skillSelectionCamera = self:GetSkillSelectionCamera()
	if currentCameraObject == skillSelectionCamera then
		-- 停止播放摄像机路径 --
		local skillSelectionCameraPath = self:GetCameraPathSkillSelection()
		skillSelectionCameraPath:SendMessage("Stop")
		self:ResetToDefaultCameraObject()
	end
end

function Battlefield:EnableRadiarBlur()
	local cameraObject = self:GetCurrentCamera()
	local blurEffect = GetOrCreateRadiarBlurEffect(cameraObject)
	if blurEffect ~= nil then
		blurEffect.enabled = true
	end
	return cameraObject
end

function Battlefield:DisableRadiarBlur(cameraObject)
	local blurEffect = GetOrCreateRadiarBlurEffect(cameraObject)
	if blurEffect ~= nil then
		blurEffect.enabled = false
	end
end
