
define qpid::broker (
  $url = $title, 
  $service_name = 'qpidd',
  $acls = [ 'acl deny all create link', 'acl allow all all' ],
  $qpidd_conf = [ 'cluster-mechanism=DIGEST-MD5 ANONYMOUS', 'auth=yes' ]

) {

  $addr = url_addr($url)
  $port = url_port($url)

  $init = "/etc/init.d/${service_name}"
  $root_dir = "/etc/qpidd/${service_name}"
  $config = "/etc/qpidd/${service_name}/qpidd.conf"
  $acl_file = "/etc/qpidd/${service_name}/qpidd.acl"

  broker { "$url": service_name => $service_name }

  file { "${init}":
    ensure      => present,
    mode        => 0755,
    content     => template('qpid/init.sh.erb'),
    require     => Package['qpid-cpp-server']
  }

  file { "${root_dir}":
    ensure      => directory,
    mode        => 0755,
    recurse     => true,
  }

  file { "${config}":
    ensure      => present,
    mode        => 0644,
    content     => template('qpid/qpidd.conf.erb'),
    require     => File["${root_dir}"],
  }

  file { "${acl_file}":
    ensure      => present,
    mode        => 0644,
    content     => template('qpid/qpidd.acl.erb'),
    require     => File["${root_dir}"],
  }

  service { "${service_name}":
    ensure      => running,
    require     => [ File["${init}"], File["${config}"] ],
  }

}

