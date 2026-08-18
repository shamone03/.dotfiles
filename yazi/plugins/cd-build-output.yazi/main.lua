local function get_build_output()
	local out, err =
		Command("nu"):arg({ "-c", "just output --binary" }):stdout(Command.PIPED):stderr(Command.PIPED):output()

	if out.status.success then
		local destination = out.stdout:gsub("[\n\r]", "") .. "/"
		return string.format("%s/Debug", destination), nil
	else
		return nil, out.stderr
	end
end

local function fail(s, ...)
	ya.notify({ title = "Could not change directory", content = string.format(s, ...), timeout = 5, level = "error" })
end

return {
	entry = function(self, job)
		local destination = nil
		local err = nil
		if job.args.allbuilds then
			-- TODO: use env variable
			destination = "C:/b"
		else
			local build_output, build_err = get_build_output()
			err = build_err
			destination = build_output
		end

		if destination ~= nil then
			local target = Url(destination)
			local cha, file_err = fs.cha(target)
			if cha and cha.is_dir then
				ya.emit("cd", { target })
			else
				fail("%s", file_err or "")
			end
		else
			if err ~= nil then
				fail(err)
            else
                fail("Could not get build directory")
			end
		end
	end,
}
