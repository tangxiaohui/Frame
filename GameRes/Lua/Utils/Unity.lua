require "Class"

UnityUtils = Class()

function UnityUtils:FindGameObject(name)
	if type(name) ~= "string" then
		print("FindGameObject failed, cause name is not a string.")
		return
	end

	local GameObject = UnityEngine.GameObject
	return GameObject.Find(name)
end

function UnityUtils:FindChild(transform, name)
	if transform == nil then
		return nil
	end

	return transform:Find(name)
end

function UnityUtils:GetTransformByObjectName(name)
	local object = self:FindGameObject(name)
	if object == nil then
		print("GetTransformByObjectName failed, cause the object is not exist.")
		return
	end

	return object.transform
end

function UnityUtils:GetCameraByObjectName(name)
	local object = self:FindGameObject(name)
	if object == nil then
		print("GetCameraByObjectName failed, cause the object is not exist.")
		return
	end

	local camera = object:GetComponent(typeof(UnityEngine.Camera))
	if camera == nil then
		print("GetCameraByObjectName failed, cause the camera is not exist.")
		return
	end

	return camera
end

function UnityUtils:AddComponentIfMissing(gameObject, componentType)
	return gameObject:GetComponent(componentType) or gameObject:AddComponent(componentType)
end

function UnityUtils:PrintPosition(vector3)
	print(string.format("Position: x=%s, y=%s, z=%s", vector3.x, vector3.y, vector3.z))
end

local unityUtils = UnityUtils.New()
return unityUtils