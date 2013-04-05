
# /etc/hosts -->  127.0.0.1   localhost.localdomain   localhost localhost1 localhost2


include qpid::gems

package { 'qpid-cpp-server':
  ensure        => present,
}

qpid::broker { 'localhost:5672': 
  service_name  => 'broker_one',
}

exchange { 'exch_one': 
  type          => 'direct',
}

queue { 'queue_one': }

binding { 'exch_one:queue_one': }

link { 'link_one':
  url           => 'localhost:5672',
  remote_host   => 'localhost',
  remote_port   => '20000',
}


qpid::broker { 'localhost:20000': 
  service_name  => 'broker_two',
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



