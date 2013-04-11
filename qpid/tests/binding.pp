
include qpid::gems


package { 'qpid-cpp-server':
  ensure        => present,
}

$url = 'localhost:5672'
qpid::broker { "$url": }

exchange { "exch_one@$url": 
  type          => 'direct',
}

exchange { "exch_two@$url": 
  type          => 'topic',
  alt_exch      => 'exch_one',
}


queue { "queue_one@$url": 
}

queue { "queue_two@$url": 
  alt_exch      => 'exch_one',
}

binding { "exch_one:queue_one@$url": }
binding { "exch_two:queue_two:topic.a@$url": }

