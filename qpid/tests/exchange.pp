
include qpid::gems

$url = 'localhost:5672'

package { 'qpid-cpp-server':
  ensure        => present,
}

qpid::broker { "${url}": }

exchange { "my_ex@${url}": 
  type          => 'direct',
}
exchange { 'my_ex2': 
  type          => 'fanout',
  url           => "${url}",
  alt_exch      => 'my_ex',
  durable       => true,
  replicate     => 'none',
  msg_sequence  => false,
  ive           => true,
}

