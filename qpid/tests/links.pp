
# /etc/hosts -->  127.0.0.1   localhost.localdomain   localhost localhost1 localhost2


include qpid::gems

package { 'qpid-cpp-server':
  ensure        => present,
}


$url1 = 'localhost:20001'
$url2 = 'localhost:20002'

qpid::broker { "$url1": 
  service_name  => 'broker_one',
  acls          => [ 'acl allow all all' ],
  qpidd_conf    => [ 'auth=no' ],
}

qpid::broker { "$url2": 
  service_name  => 'broker_two',
  acls          => [ 'acl allow all all' ],
  qpidd_conf    => [ 'auth=no' ],
}

exchange { "exch_one@$url1": 
  type          => 'direct',
  durable       => true,
}

queue { "queue_one@$url1": }

binding { "exch_one:queue_one@$url1": }

exchange { "exch_two@$url2": 
  type          => 'direct',
}

queue { "queue_two@$url2": }

binding { "exch_two:queue_two@$url2": }


# links and bridges
link { "link_one@$url1":
  remote_host   => 'localhost',
  remote_port   => '20000',
}

link { "link_two@$url2":
  remote_host   => 'localhost',
  remote_port   => '5672',
}


queue_route { "route1@$url1":
  link          => 'link_one',
  src_queue     => 'queue_two',
  dst_exch      => 'exch_one',
  sync          => 1,
}


exchange_route { "route2@$url2":
  link          => 'link_two',
  exchange      => 'exch_one',
  key           => 'my_topic',
  sync          => 1,
}

dynamic_route { "route3@$url1":
  link          => 'link_one',
  exchange      => 'exch_one',
  sync          => 1,
}

