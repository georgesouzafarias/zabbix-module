include apt

class zabbix {
  apt::key { 'zabbix_key': key_source => 'http://repo.zabbix.com/zabbix-official-repo.key', 
  }

  apt::source { 'zabbix_repository':
    location    => 'http://repo.zabbix.com/zabbix/2.2/debian',
    repos       => 'main',
    include_src => false,
    require     => Apt::Key['zabbix_key'],
  }

  package { 'zabbix-agent':
    ensure   => installed,
    provider => aptitude,
    require  => Apt::Source['zabbix_repository'],
  }

  # Send the configuration files
  file { "zabbix_agentd.conf":
    path    => "/usr/local/etc/zabbix_agentd.conf",
    ensure  => file,
    owner   => zabbix,
    group   => zabbix,
    source  => "puppet:///zabbix/files/conf/zabbix_agentd/zabbix_agentd.conf",
    require => Package['zabbix-agent'],
  }

  service { 'zabbix-agent':
    ensure  => running,
    require => File['zabbix_agentd.conf'],
    enable  => true,
  }
}
# Send the archives correct for osfamily and architecture.

# if $::osfamily == 'Debian' {
#  $extensao = 'deb'
# } else {
# $extensao = 'rpm'
