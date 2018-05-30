require "Object.LuaObject"

EventHandler = Class(LuaObject)

function EventHandler:Ctor()
	self.eventHandlerTable = {}
end

function EventHandler:RegisterEventHandler(handler)
	local table = self.eventHandlerTable
	for i = 1, #table do
		if table[i] == handler then
			print("EventHandler:RegisterMsgHandler detect duplicated handler, name: "..handler:ToString())
			return
		end
	end
	table[#table+1] = handler
end

function EventHandler:UnRegisterEventHandler(handler)
	local table = self.eventHandlerTable
	for i = #table, 1, -1 do
		if table[i] == handler then
			table[i] = table[#table]
			table[#table] = nil
			return
		end
	end
end

function EventHandler:Dispatch(routine, ...)
	local table = self.eventHandlerTable
	for i = #table, 1, -1 do
		if table[i] ~= nil then
			routine(table[i], ...)
		end
	end
end

function EventHandler:Clear()
	local utility = require "Utils.Utility"
	utility.ClearArrayTableContent(self.eventHandlerTable)
end

function EventHandler:ToString()
	return "EventHandler"
end