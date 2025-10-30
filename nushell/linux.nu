export-env {
    if $nu.os-info.name == "linux" {
        $env.projects = "~/Projects"
		$env.PATH ++= [ $"($env.projects)/.dotfiles/nushell/nupm/plugins/bin"]
    }
}
