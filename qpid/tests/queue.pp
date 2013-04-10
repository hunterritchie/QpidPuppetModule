
include qpid::gems

$url = 'localhost:5672'

package { 'qpid-cpp-server':
  ensure          => present,
}

qpid::broker { "${url}": }


exchange { 'my_ex':
  type            => 'fanout',
  url             => "${url}",
}

queue { 'my_queue': 
  auto_delete     => true,
  url             => "${url}",
  
  alt_exch        => 'my_ex',
  durable         => true,
  replicate       => 'none',

  cluster_durable => true,
  policy_type     => 'ring',

}

