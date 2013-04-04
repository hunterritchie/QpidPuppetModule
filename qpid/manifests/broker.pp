
define qpid::broker (
  $url = $title, 
  $serviceName = 'qpidd',
) {

  $addr = url_addr($url)
  $port = url_port($url)

  package { 'qpid-cpp-server':
    ensure      => installed,
  }

  $config = "/etc/qpidd/${serviceName}/qpidd.conf"

  file { "/etc/init.d/${serviceName}":
    ensure      => present,
    mode        => 0755,
    content     => template('qpid/init.sh.erb'),
  }

  file { "/etc/qpidd":
    ensure      => directory,
  }

  file { "/etc/qpidd/${serviceName}":
    ensure      => directory,
    require     => File['/etc/qpidd'],
  }

  file { "/etc/qpidd/${serviceName}/qpidd.conf":
    ensure      => present,
    content     => template('qpid/qpidd.conf.erb'),
    require     => File["/etc/qpidd/${serviceName}"],
  }

  service { "${serviceName}":
    ensure      => running,
    require     => [ File["/etc/init.d/${serviceName}"], File["/etc/qpidd/${serviceName}/qpidd.conf"] ],
  }

}

