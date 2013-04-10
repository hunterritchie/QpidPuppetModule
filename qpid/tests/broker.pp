
package { 'qpid-cpp-server': }

qpid::broker { 'localhost:30000':
  service_name  => 'george',
  acls          => [ 'acl allow all all' ],
  qpidd_conf    => [ 'auth=no' ],
}

