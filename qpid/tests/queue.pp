
include qpid::gems

$url = 'localhost:5672'

package { 'qpid-cpp-server':
  ensure          => present,
}

qpid::broker { "${url}": }


exchange { "my_ex@${url}":
  type            => 'fanout',
}

queue { "my_queue@${url}": 
  auto_delete     => true,
  
  alt_exch        => 'my_ex',
  durable         => true,
  replicate       => 'none',

  cluster_durable => true,
  policy_type     => 'ring',

}

