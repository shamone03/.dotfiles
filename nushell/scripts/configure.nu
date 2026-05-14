export def service_logging [] {
    use std xml
    (glob *_configuration.xml)
    | append ("./CN_OptionsConfiguration.xml" | path expand)
    | each { |file|
      '<Logging>
        <Sinks>
          <Sink1 type="console" level="Trace"/>
          <Sink2 type="file" level="Trace"/>
        </Sinks>
        <MQTT Enable="true" IP="127.0.0.1"/>
      </Logging>' | from xml | let logging;
      open $file | let configuration
      if ($configuration | xml xaccess [* Logging] | is-empty) {
        $configuration | xml xinsert [*] $logging | to xml --indent 4 --self-closed | save $file --force
      }
    }
}
