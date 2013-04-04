
include qpid::gems

qpid::broker { 'localhost:5672': }


exchange { 'my_ex':
  type            => 'fanout',
}

queue { 'my_queue': 
  auto_delete     => true,
  
  alt_exch        => 'my_ex',
  durable         => true,
  replicate       => true,

  cluster_durable => true,
  policy_type     => 'ring',

}

