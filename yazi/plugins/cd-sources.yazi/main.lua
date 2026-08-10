local function get_sources()
	local out, err = Command("nu")
		:arg({
			"--config",
			"C:/Users/aryah.kannan/Projects/.dotfiles/nushell/scripts/path.nu",
			"-c",
			"open (find-in-parent .sources.txt ($env.project_builds)) --raw",
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	if out.status.success then
		local destination = out.stdout:gsub("[\n\r]", "") .. "/"
		return string.format("%s", destination), nil
	else
		return nil, out.stderr
	end
end

local function fail(s, ...)
	ya.notify({ title = "Could not change directory", content = string.format(s, ...), timeout = 5, level = "error" })
end

return {
	entry = function()
		local destination, err = get_sources()
		ya.dbg(destination)
		if destination ~= nil then
			local target = Url(destination)
			local cha, file_err = fs.cha(target)
			if cha and cha.is_dir then
				ya.emit("cd", { target })
			else
				fail("%s", file_err or "")
			end
		else
			fail(err)
		end
	end,
}
