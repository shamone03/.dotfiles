local function get_build_output()
	local command = "just output"
	local handle = io.popen(command)
	if handle ~= nil then
		local result = handle:read("*a")
		local status_table = { handle:close() }
		local status_code = status_table[3]

		if status_code == 0 then
			local destination = result:gsub("[\n\r]", "") .. "/"
			return destination
		end
	else
		return nil
	end
end

return {
	entry = function()
		local destination = get_build_output()
		ya.dbg(destination)
		if destination then
			local target = Url(destination)
			ya.emit("cd", { target })
		else
			ya.notify({
				title = "Could not change directory",
				content = "No justfile in directory?",
				timeout = 3,
				level = "error",
			})
		end
	end,
}
