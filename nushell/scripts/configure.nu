export def logging [] {
    use std xml
    [avg_db_configuration.xml
    avs_configuration.xml
    correlation_configuration.xml
    db_configuration.xml
    mcs_configuration.xml
    nes_configuration.xml
    poi_db_configuration.xml
    scs_configuration.xml
    ssas_configuration.xml
    CN_OptionsConfiguration.xml]
    | where { $in | path exists }
    | each { |file|
      '<Logging>
        <Sinks>
          <Sink1 type="console" level="Trace"/>
          <Sink2 type="file" level="Trace"/>
        </Sinks>
        <MQTT Enable="true" IP="127.0.0.1"/>
      </Logging>' | from xml | let logging;
      open $file | let configuration
      if ($configuration | xml xaccess [* Logging Sinks *] | is-empty) {
        $configuration | xml xinsert [*] $logging | to xml --indent 4 --self-closed | save $file --force
        print $"(ansi green)Configured ($file)(ansi reset)"
      } else {
        print $"Already configured ($file)"
      }
    }
    if not ("env.json" | path exists) {
      {} | to json | save env.json
    }
    let env_json = open env.json
    if ($env_json.aims_configuration_parsing?.log_level? == info) {
        print $"Already configured env.json"
    } else {
        open env.json | upsert aims_configuration_parsing.log_level info | to json | save env.json --force
        print $"(ansi green)Configured env.json(ansi reset)"
    }
}

def service_short [] {
    open ([Services.csv] | path join) | get ExeName
}

export def launcher [...include: string@service_short] {
    open ([Services.csv] | path join)
        | get ExeName
        | where { if ( $include | is-not-empty ) { $in in $include } else { true } }
        | each { { $"($in)": { cmd: [$in] } } }
        | append { aims.exe: { cmd: [aims.exe], autostart: false } }
        | reduce { |accum, val| $accum | merge $val }
        | { procs: $in }
        | to yaml
        | save ([mprocs.yaml] | path join) -f
}
