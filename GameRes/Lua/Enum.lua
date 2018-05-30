function Enum(enumTable)
	enumTable = enumTable or {}
	local ret = {}
	local index = 0
	for i, v in ipairs(enumTable) do
		ret[v] = index
		index = index + 1
	end

	return ret
end

Side = {
	"Left", 
	"Right", 
}
Side = Enum(Side)