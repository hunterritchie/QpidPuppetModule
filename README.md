QpidPuppetModule
================

puppet module for deploying qpidd brokers, and configuring broker artifacts (exchanges, queues, bindings)

```
Example Manifest:

# qpid::gems installs qpid_messaging and qpid_management gems
include qpid::gems

# deploy qpidd broker
qpid::broker { 'localhost:5672': }

# creates exchanges
exchange { 'exch_one':
  type          => 'direct',
}
exchange { 'exch_two':
  type          => 'topic',
  alt_exch      => 'exch_one',
}

# creates queues
queue { 'queue_one':
}
queue { 'queue_two':
  alt_exch      => 'exch_one',
}

# creates bindings
binding { 'exch_one:queue_one': }
binding { 'exch_two:queue_two:topic.a': }
```
