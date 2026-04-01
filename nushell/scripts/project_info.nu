export def get [] {
    glob $"($env.projects)/project-aims/projects/**/project-components.json"
        | each {
            {
                project_path: ($in | path dirname | path split | skip until { $in == project-aims } | skip 2 | path join)
                project_name: ($in | path dirname | path basename),
                packages: (open $in).packages,
                network: (open $"($in | path dirname)/config/AIMS_CONFIGURATION/network.json"),
                configuration: $"($in | path dirname)/config"
            }
        }
        | each {
            {
                ...$in,
                service_plugins: (open ([$in.configuration CN_OptionsConfiguration.xml] | path join) | $in.content
                | where tag == ServiceProviderPluginList | $in.0.content
                | where tag == ServiceProviderPlugins | $in.0.content
                | each { $in.content | where tag == PluginKey | $in.0.attributes | $in.PluginType })
            }
        }
        | each {
            {
                ...$in,
                ui_plugins: (open ([$in.configuration CN_OptionsConfiguration.xml] | path join) | $in.content
                | where tag == UIPluginList | $in.0.content
                | where tag == UIPlugins | $in.0.content
                | each { $in.content | where tag == PluginKey | $in.0.attributes | $in.PluginType })
            }
        }
        | each {
            {
                ...$in,
                sensor_plugins: (open ([$in.configuration scs_configuration.xml] | path join) | $in.content
                    | where tag == PluginList | $in.0.content
                    | each { $in.content | where tag == PluginKey | $in.0.attributes | $in.PluginType })
            }
        }
}

def main [] {
    get
}