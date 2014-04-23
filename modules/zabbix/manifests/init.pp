class zabbix {
  package { 'zabbix-agent': ensure => installed, }

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

  # Send the archives correct for osfamily and architecture.

  # if $::osfamily == 'Debian' {
  #  $extensao = 'deb'
  # } else {
  # $extensao = 'rpm'
  #}

  # $pacote = "zabbix-agent_${::osfamily}_${::architecture}.${extensao}"

  # file { "zabbix-package":
  #  path   => "/tmp/${pacote}",
  #  ensure => file,
  #  source => "puppet:///zabbix/files/${pacote}",
  #}

  # user { 'zabbix':
  # ensure  => present,
  # groups  => 'zabbix',
  # require => Group['zabbix'],
  #}

  # group { 'zabbix': ensure => present, }


  # Check the osfamily and send the script daemon correct
  #  case $::osfamily {
  #    'Debian', 'RedHat' : {
  #      file { "zabbix-agent":
  #        path    => "/etc/init.d/zabbix-agent",
  #        ensure  => file,
  #        owner   => root,
  #        group   => root,
  #        content =>
  #        "puppet:///zabbix/files/init/zabbix-agent-${::osfamily}.conf",
  #  }
  #}
  #  default            : {
  #    fail('OS nao suportado')
  #  }
  #}

  # exec { 'apt-get':
  #   command => "/usr/bin/apt-get -f install -y",
  #   unless  => "/usr/bin/apt-get check",
  #}

  # installing the zabbix-agent package