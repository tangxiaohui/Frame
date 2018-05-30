require "Object.LuaGameObject"
local utility = require "Utils.Utility"

Panel = Class(LuaGameObject)

function Panel:Ctor(parentName)
	self.initialized = false

	local uiManager = require "Utils.Utility".GetUIManager()
	local battleCanvasTransform = uiManager:GetBattleUICanvas():GetCanvasTransform()


	if parentName == nil then
		self.guiRoot = battleCanvasTransform
	else
		self.guiRoot = battleCanvasTransform:Find(parentName)
	end
end

local function BindPanelObject(self, obj)
	if not obj then
		error('obj is nil, cause failed to bind object')
	end
	self.gameObject = obj
	self.transform = obj.transform
	self.canvasGroup = self.gameObject:GetComponent(typeof(UnityEngine.CanvasGroup))
	self.initialized = true
	self:OnResourceLoaded()
end

local function LoadPrefabInternal(self, prefabName)
	local Object = UnityEngine.Object
	local gameObject = Object.Instantiate(utility.LoadResourceSync(prefabName, typeof(UnityEngine.GameObject)))
	gameObject.transform:SetParent(self.guiRoot.transform)
	gameObject.transform.localScale = Vector3.New(1, 1, 1)
	gameObject.transform.offsetMin = Vector2.New(0, 0)
	gameObject.transform.offsetMax = Vector2.New(0, 0)
	BindPanelObject(self, gameObject)
end

function Panel:OnResourceLoaded()
end


function Panel:InitWithPrefabName(prefabName)
	if self.initialized then
		error('已经初始化了 不能再次初始化!')
	end
	LoadPrefabInternal(self, prefabName)
end

function Panel:InitWithGameObject(obj)
	if self.initialized then
		error('已经初始化了 不能再次初始化!')
	end
	BindPanelObject(self, obj)
end

