function PrintTable(table)
	for k, v in pairs(table) do
		if type(v) == "table" then
			print("table", k, "{")
			PrintTable(v)
			print("}")
		else
			print(string.format("key= %s, value= %s", k, tostring(v)))
		end
	end
end

