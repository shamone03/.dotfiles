local M = {}
local function fail(job, s)
	ya.preview_widget(job, ui.Text.parse(s):area(job.area):wrap(ui.Wrap.YES))
end
function M:peek(job)
	local file_path = tostring(job.file.path)

	local output, err = Command("nu"):arg({ "-c", string.format("just --justfile %s --list", file_path) }):output()

	if err then
		return fail(job, "" .. output.stderr)
	end
	if err then
		fail(job, table.concat(output.stderr, ""))
	else
		ya.preview_widget(job, ui.Text(output.stdout):area(job.area))
	end
end

return M
