
define qpid::broker (
  $url = $title, 
  $service_name = 'qpidd',
) {

  $addr = url_addr($url)
  $port = url_port($url)

  $config = "/etc/qpidd/${service_name}/qpidd.conf"

  broker { "$url": service_name => $service_name }

  file { "/etc/init.d/${service_name}":
    ensure      => present,
    mode        => 0755,
    content     => template('qpid/init.sh.erb'),
    require     => Package['qpid-cpp-server']
  }

  file { "/etc/qpidd/${service_name}":
    ensure      => directory,
    recurse     => true,
  }

  file { "/etc/qpidd/${service_name}/qpidd.conf":
    ensure      => present,
    content     => template('qpid/qpidd.conf.erb'),
    require     => File["/etc/qpidd/${service_name}"],
  }

  service { "${service_name}":
    ensure      => running,
    require     => [ File["/etc/init.d/${service_name}"], File["/etc/qpidd/${service_name}/qpidd.conf"] ],
  }

}

