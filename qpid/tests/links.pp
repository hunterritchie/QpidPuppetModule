
# /etc/hosts -->  127.0.0.1   localhost.localdomain   localhost localhost1 localhost2


include qpid::gems

package { 'qpid-cpp-server':
  ensure        => present,
}


qpid::broker { 'localhost:5672': 
  service_name  => 'broker_one',
  acls          => [ 'acl allow all all' ],
  qpidd_conf    => [ 'auth=no' ],
}

qpid::broker { 'localhost:20000': 
  service_name  => 'broker_two',
  acls          => [ 'acl allow all all' ],
  qpidd_conf    => [ 'auth=no' ],
}

exchange { 'exch_one': 
  type          => 'direct',
  url           => [ 'localhost:5672', 'localhost:20000'],
  durable       => true,
}

queue { 'queue_one': 
  url           => 'localhost:5672',
}

binding { 'exch_one:queue_one': 
  url           => 'localhost:5672',
}

exchange { 'exch_two': 
  type          => 'direct',
  url           => 'localhost:20000',
}

queue { 'queue_two': 
  url           => 'localhost:20000',
}

binding { 'exch_two:queue_two': 
  url           => 'localhost:20000',
}


# links and bridges
link { 'link_one':
  url           => 'localhost:5672',
  remote_host   => 'localhost',
  remote_port   => '20000',
}

link { 'link_two':
  url           => 'localhost:20000',
  remote_host   => 'localhost',
  remote_port   => '5672',
}


queue_route { 'route1':
  link          => 'link_one',
  src_queue     => 'queue_two',
  dst_exch      => 'exch_one',
  sync          => 1,
}


exchange_route { 'route2':
  url           => 'localhost:20000',
  link          => 'link_two',
  exchange      => 'exch_one',
  key           => 'my_topic',
  sync          => 1,
}

dynamic_route { 'route3':
  link          => 'link_one',
  exchange      => 'exch_one',
  sync          => 1,
}

