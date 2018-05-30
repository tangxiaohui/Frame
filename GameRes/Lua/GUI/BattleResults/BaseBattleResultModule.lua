--
-- User: fenghao
-- Date: 5/18/17
-- Time: 3:36 PM
--

local BaseNodeClass =  require "Framework.Base.WindowNode"
--local utility = require "Utils.Utility"
local windowUtility = require "Framework.Window.WindowUtility"
require "System.LuaDelegate"

local BaseBattleResultDialog = Class(BaseNodeClass)

-- ### 表示这个窗口只能同时弹出1个
windowUtility.SetMutex(BaseBattleResultDialog, true)

function BaseBattleResultDialog:Ctor()
    self.closeCallback = LuaDelegate.New()
end

-----------------------------------------------------------------------
--- 设置函数(必须调用)
-----------------------------------------------------------------------

function BaseBattleResultDialog:SetWin(isWin)
    self.isWin = isWin
end

function BaseBattleResultDialog:SetCloseCallback(table, func)
    self.closeCallback:Set(table, func)
end

function BaseBattleResultDialog:SetBattleResultMsg(msg)
    self.battleResultMsg = msg
end

function BaseBattleResultDialog:SetOwner(owner)
    self.battleOwner = owner
end

function BaseBattleResultDialog:GetBattleResultMsg()
    return self.battleResultMsg
end

function BaseBattleResultDialog:SetParams(...)

end

-- 指定为Module层!
function BaseBattleResultDialog:GetRootHangingPoint()
    return self:GetUIManager():GetModuleLayer()
end

function BaseBattleResultDialog:DispatchCloseEvent(...)
    self.closeCallback:Invoke(...)
end

return BaseBattleResultDialog