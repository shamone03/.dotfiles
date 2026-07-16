export def info [] {
    use std xml
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
                service_plugins: (open ([$in.configuration CN_OptionsConfiguration.xml] | path join)
                | xml xaccess [Configuration ServiceProviderPluginList ServiceProviderPlugins * PluginKey]
                | get attributes
                | get PluginType
                | sort)
            }
        }
    | each {
            {
                ...$in,
                ui_plugins: (open ([$in.configuration CN_OptionsConfiguration.xml] | path join)
                | xml xaccess [Configuration UIPluginList UIPlugins * PluginKey]
                | get attributes
                | get PluginType
                | sort)
            }
        }
    | each {
            {
                ...$in,
                sensor_plugins: (open ([$in.configuration scs_configuration.xml] | path join)
                | xml xaccess [SCSConfig PluginList * PluginKey]
                | get attributes
                | get PluginType
                | sort)
            }
        }
    | each {
            let nes_configuration_path = [$in.configuration nes_configuration.xml] | path join
            let nes_configuration = if ($nes_configuration_path | path exists) {
                open $nes_configuration_path
            } else {
                null
            }
            {
                ...$in,
                exported_sensor_plugins: (
                    if ($nes_configuration != null) {
                        $nes_configuration
                        | xml xaccess [Configuration SensorList Sensor]
                        | get attributes
                        | get pluginType
                        | sort
                    } else {
                        null
                    }
                )
            }
        }
    | each {
            let services_path = [$in.configuration Services.csv] | path join
            let services = if ($services_path | path exists) {
                open $services_path | get ExeName
            } else {
                null
            }
            {
                ...$in,
                services: $services
            }
    }
}
