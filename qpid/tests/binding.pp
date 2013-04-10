
include qpid::gems


package { 'qpid-cpp-server':
  ensure        => present,
}

qpid::broker { 'localhost:5672': }

exchange { 'exch_one': 
  type          => 'direct',
}

exchange { 'exch_two': 
  type          => 'topic',
  alt_exch      => 'exch_one',
}


queue { 'queue_one': 
}

queue { 'queue_two': 
  alt_exch      => 'exch_one',
}

binding { 'exch_one:queue_one': }
binding { 'exch_two:queue_two:topic.a': }

