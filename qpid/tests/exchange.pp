
include qpid::gems

qpid::broker { 'localhost:5672': }

exchange { 'my_ex': 
  type          => 'direct',
}
exchange { 'my_ex2': 
  type          => 'fanout',
  alt_exch      => 'my_ex',
  durable       => true,
  replicate     => true,
  msg_sequence  => 1,
  ive           => true,
}

