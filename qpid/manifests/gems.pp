
class qpid::gems {

  package { 'gcc':
    ensure      => installed,
  }
 
  package { 'gcc-c++':
    ensure      => installed,
    require     => Package['gcc'],
  }
 
  package { 'qpid-cpp-client-devel':
    ensure      => installed,
  }
 
  package { 'qpid_messaging':
    ensure      => 'installed',
    provider    => 'gem',
    require     => [ Package['qpid-cpp-client-devel'], Package['gcc'], Package['gcc-c++'] ],
  }

  package { 'qpid_management':
    ensure      => 'installed',
    provider    => 'gem',
    require     => Package['qpid_messaging'],
  }
}

