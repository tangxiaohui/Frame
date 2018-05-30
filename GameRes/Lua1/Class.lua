local setmetatable = setmetatable

local errorMessage = "this is not your business"

local classTable = {}

local function CallCtor(Class, instance, ...)
	if Class.base then
		CallCtor(Class.base, instance, ...)
	end

	if Class.Ctor then
		Class.Ctor(instance, ...)
	end
end

local function Create(thisClass, ...)
	local instance = {}
	setmetatable(instance, {__index = classTable[thisClass], __metatable = errorMessage})  -- 类的实例化 要继承 其类的模版的功能

	-- 先调用父的构造 再调用子的构造
	CallCtor(thisClass, instance, ...)

	-- 返回实例
	return instance
end

function Class(baseClass)
	local thisClass = {}

	thisClass.Ctor = false
	thisClass.base = baseClass
	thisClass.New = function(...)
		-- 构建当前类的实例化
		return Create(thisClass, ...)
	end

	-- 当前类的虚表
	local vtbl = {}
	classTable[thisClass] = vtbl

	-- 当前类模版, 可以定义和读取
	setmetatable(thisClass, {__newindex =
	function(_, k, v)
		-- body
		vtbl[k] = v
	end
		, __index = vtbl
		, __metatable = errorMessage})

	-- 继承基类的功能
	local vtbl_metatable = {}
	vtbl_metatable.__metatable = errorMessage

	-- 有基类?
	if baseClass then
		vtbl_metatable.__index =
		function(_, k)
			-- body
			local ret = classTable[baseClass][k]
			vtbl[k] = ret
			return ret
		end
	end

	setmetatable(vtbl, vtbl_metatable)

	return thisClass
end