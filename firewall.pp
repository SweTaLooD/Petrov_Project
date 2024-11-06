class { 'firewall': }

firewall { '100 allow http and https access':
  proto  => 'tcp',
  dport  => [80, 443],
  ensure => 'present',
}

firewall { '100 allow MySQL access from web server':
  proto  => 'tcp',
  dport  => 3306,
  source => '212.233.96.72',
  ensure => 'present',
}

firewall { '200 block all other traffic':
  proto  => 'all',
  ensure => 'absent',
}
