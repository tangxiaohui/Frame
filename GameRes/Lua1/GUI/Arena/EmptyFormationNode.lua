local BaseNodeClass = require "Framework.Base.UINode"
local utility = require "Utils.Utility"

local EmptyNodeCls = Class(BaseNodeClass)

function EmptyNodeCls:Ctor(parent)
	self.parent = parent
end
-----------------------------------------------------------------------
--- 场景状态
-----------------------------------------------------------------------
function EmptyNodeCls:OnInit()
	-- 加载界面(只走一次)
	utility.LoadNewGameObjectAsync('UI/Prefabs/ArenaRivalFormationItem', function(go)
		self:BindComponent(go,false)
	end)
end

function EmptyNodeCls:OnComponentReady()
	-- 界面加载完毕 初始化函数(只走一次)
	self:LinkComponent(self.parent)
	self:InitControls()
end

function EmptyNodeCls:OnResume()
	-- 界面显示时调用
	EmptyNodeCls.base.OnResume(self)
end

function EmptyNodeCls:OnPause()
	-- 界面隐藏时调用
	EmptyNodeCls.base.OnPause(self)
end

function EmptyNodeCls:OnEnter()
	-- Node Enter时调用
	EmptyNodeCls.base.OnEnter(self)
end

function EmptyNodeCls:OnExit()
	-- Node Exit时调用
	EmptyNodeCls.base.OnExit(self)
end

-----------------------------------------------------------------------
--- 控件相关
-----------------------------------------------------------------------
-- # 控件绑定
function EmptyNodeCls:InitControls()

end


return EmptyNodeCls