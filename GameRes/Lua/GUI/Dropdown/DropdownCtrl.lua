local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"
require "Collection.OrderedDictionary"
require "System.LuaDelegate"
local TweenUtility = require "Utils.TweenUtility"


local OnSelectedRotation = Vector3(0,0,0) 
local OnNormorRotation = Vector3(0,0,90) 
local bottomBorder = 5
--------------------------------------------------------------

local DropdownCtrlCls = Class(BaseNodeClass)

function DropdownCtrlCls:Ctor(point,dataDict,redDot)
	self.point = point
	self.dataDict = dataDict
	-- if redDot ~= nil then
		self.redDot = redDot
	-- end
	self.callback = LuaDelegate.New()
	self.first = false
end


function DropdownCtrlCls:SetCallback(ctable,func)
	 self.callback:Set(ctable,func)
end

function DropdownCtrlCls:OnInit()
	-- 加载界面(只走一次)

	utility.LoadNewGameObjectAsync('UI/Prefabs/DropdownCtrl', function(go)
		self:BindComponent(go)
		go.gameObject:SetActive(false)
	end)
end

function DropdownCtrlCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	--self:LinkComponent(self.parent)
	self:InitControls()
end

function DropdownCtrlCls:OnResume()
	-- 界面显示时调用
	DropdownCtrlCls.base.OnResume(self)
	self:RegisterControlEvents()
end

function DropdownCtrlCls:OnPause()
	-- 界面隐藏时调用
	DropdownCtrlCls.base.OnPause(self)
	self:UnregisterControlEvents()
end

function DropdownCtrlCls:OnEnter()
	-- Node Enter时调用
	DropdownCtrlCls.base.OnEnter(self)
end

function DropdownCtrlCls:OnExit()
	-- Node Exit时调用
	DropdownCtrlCls.base.OnExit(self)
end

function DropdownCtrlCls:InitControls()
	--local transform = self:GetUnityTransform()
	self:Load()
end


function DropdownCtrlCls:RegisterControlEvents()

end

function DropdownCtrlCls:UnregisterControlEvents()
	
end

function DropdownCtrlCls:Load()
	-- 加载
	local nodeCls = require "GUI.Dropdown.DropdownBase"
	self.key = {}
	self.nodeTables = {}
	local redDot
	local keys = self.dataDict:GetKeys()
	local length = #keys
	for i=1,length do
		if self.redDot ~= nil then
			redDot = self.redDot
		end
		local key = keys[i]
		local value = self.dataDict:GetEntryByKey(key)
		self.key[i] = key
		-- debug_print("reddot::::::::::"..self.key[i])
		local node = nodeCls.New(self.point,i,key,value,30,30,redDot)
		node:SetCallback(self,self.ClickedCallBack)
		self.nodeTables[#self.nodeTables + 1] = node
	end

end

--设置红点信息
function DropdownCtrlCls:SetRedDotInfo(redDot)
	-- debug_print("更新红点")
	self.redDot = redDot
	-- debug_print(#self.redDot.."  aaaaaaaaaaaaaaaaaaaaaaaaaaaa  "..#redDot)
	self.first = true
	self:Show()
end

--红点更新
function DropdownCtrlCls:SetRedDot(redDot)
	
	if redDot ~= nil then
		-- for j = 1,#redDot do
			-- debug_print("RedDot:"..redDot[j].sonid)
				-- if self.redDot[j].sonid == key then
					-- redDot = (self.redDot[j].red == 1)
					-- self.redDotImage:SetActive(redDot)
				-- break
			-- end
		-- end
	-- else
		if self.nodeTables ~= nil then
			-- debug_print("RedDot:"..#redDot)
			for i = 1,#self.nodeTables do
				self.nodeTables[i]:SetRedDot(redDot,self.first)
			end
		end
	end
end

function DropdownCtrlCls:Show()
	-- 显示
	if self.nodeTables ~= nil then
		for i = 1 ,#self.nodeTables do
			self:AddChild(self.nodeTables[i])
		end
		-- debug_print("ShowRedDot")
	
		if #self.nodeTables > 0 then 
			if self.currToggle == nil or self.currToggle == 0 then
				self.nodeTables[1]:OnExpandEvent()
				self.currToggle = 1
			else
				self.nodeTables[self.currToggle]:OnExpandEvent()
			end
		end
		
		if self.redDot ~= nil then
			-- debug_print(#self.redDot)
			self:SetRedDot(self.redDot)
		end
	end
end

function DropdownCtrlCls:Hide( )
	-- 隐藏 
	-- debug_print("隐藏")
	if self.nodeTables ~= nil then
		for i = 1 ,#self.nodeTables do
		-- debug_print("隐藏  Hide",i)
			self:RemoveChild(self.nodeTables[i],true)
			self.nodeTables[i]:OnHideEvent()		
		end
	end
	self.currToggle = 0
end


function DropdownCtrlCls:ClickedCallBack(index,node,toggleNode)
	if toggleNode ~= nil then
		self.callback:Invoke(toggleNode)
	else
		
		self:StateCtrl(index,node)
	end
end

function DropdownCtrlCls:StateCtrl( index,node )
	-- 状态管理
	if self.currToggle ~= index then

		if self.currToggle ~= nil then
			self.nodeTables[self.currToggle]:OnHideEvent()
		end

		self.currToggle = index
		
		if node:GetActiveState() then
			return
		end
		node:OnExpandEvent()
		
	else

		local nodeActive = node:GetActiveState()
		
		if not nodeActive then
			node:OnHideEvent()
		else
			return
		end
	end
end


return DropdownCtrlCls