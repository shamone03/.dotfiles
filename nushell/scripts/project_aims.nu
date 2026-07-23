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
                | rename --column { PluginType: plugin_type, PluginLabel: plugin_label }
                | sort-by plugin_type)
            }
        }
    | each {
            {
                ...$in,
                ui_plugins: (open ([$in.configuration CN_OptionsConfiguration.xml] | path join)
                | xml xaccess [Configuration UIPluginList UIPlugins * PluginKey]
                | get attributes
                | rename --column { PluginType: plugin_type, PluginLabel: plugin_label }
                | sort-by plugin_type)
            }
        }
    | each {
            {
                ...$in,
                sensor_plugins: (open ([$in.configuration scs_configuration.xml] | path join)
                | xml xaccess [SCSConfig PluginList * PluginKey]
                | get attributes
                | rename --column { PluginType: plugin_type, PluginLabel: plugin_label }
                | sort-by plugin_type)
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
                        | rename --column { pluginType: plugin_type, sensorLabel: plugin_label, label: label }
                        | sort-by plugin_type
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

export def "add ui_plugin" [--project_name: string, --plugin_type: string, --plugin_label: string = "01"] {
    use std xml;
    $'<($plugin_type)_($plugin_label)>
        <PluginKey PluginType="($plugin_type)" PluginLabel="($plugin_label)"/>
    </($plugin_type)_($plugin_label)>' | from xml | let new_plugin;

    let project = info | where project_name == $project_name | first
    let existing = $project.ui_plugins | where plugin_type == $plugin_type and plugin_label == $plugin_label | is-not-empty
    if $existing {
        print $"($project_name) already has ($plugin_type)"
        return
    }
    let cn_options_path = $"($project.configuration)/CN_OptionsConfiguration.xml"
    let cn_options = open $cn_options_path
    $cn_options | xml xinsert [Configuration UIPluginList UIPlugins] $new_plugin | let updated;
    $updated | xml xaccess [Configuration UIPluginList UIPlugins *] | sort-by tag --ignore-case | let sorted_plugins;
    let sorted_str = $"<UIPlugins>($sorted_plugins | each { $in | to xml --indent 4 --self-closed } | str join (char newline))</UIPlugins>" | from xml
    $updated | xml xupdate [Configuration UIPluginList UIPlugins] { $sorted_str } | to xml --indent 4 --self-closed | save $cn_options_path --force

    print $"(ansi green)Added ($plugin_type) to ($project_name)(ansi reset)"
}
