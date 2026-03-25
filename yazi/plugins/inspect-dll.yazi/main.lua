local M = {}

function M:peek(job)
	local file_path = tostring(job.file.path)

	local file_version_output = Command("nu")
		:arg({ "-c", string.format("get-dll-version %s", file_path) })
		:stdout(Command.PIPED)
		:output().stdout

	ya.preview_widget(job, {
		ui.Text({
			ui.Line(string.format(file_version_output)),
		}):area(job.area),
	})
end

function M:seek(job)
	-- ...
end

return M
