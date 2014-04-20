class zabbix {
  # Send the archives correct for osfamily and architecture.

  if $::osfamily == 'Debian' {
    $extensao = 'deb'
  } else {
    $extensao = 'rpm'
  }

  $pacote = "zabbix-agent_${::osfamily}_${::architecture}.${extensao}"

  file { "zabbix-package":
    path   => "/tmp/${pacote}",
    ensure => file,
    source => "puppet:///zabbix/files/${pacote}",
  }

  user { 'zabbix':
    ensure  => present,
    groups  => 'zabbix',
    require => Group['zabbix'],
  }

  group { 'zabbix': ensure => present, }

  # Send the configuration files
  file { "zabbix_agentd.conf":
    path    => "/usr/local/etc/zabbix_agentd.conf",
    ensure  => file,
    owner   => zabbix,
    group   => zabbix,
    source  => "puppet:///zabbix/files/conf/zabbix_agentd/zabbix_agentd.conf",
    require => [User['zabbix'], Group['zabbix']],
  }

  # Check the osfamily and send the script daemon correct
  case $::osfamily {
    'Debian', 'RedHat' : {
      file { "zabbix-agent":
        path    => "/etc/init.d/zabbix-agent",
        ensure  => file,
        owner   => root,
        group   => root,
        content => "puppet:///zabbix/files/init/zabbix-agent-${::osfamily}.conf",
      }
    }
    default            : {
      fail('OS nao suportado')
    }
  }

  # exec { 'apt-get':
  #   command => "/usr/bin/apt-get -f install -y",
  #   unless  => "/usr/bin/apt-get check",
  #}

  # installing the zabbix-agent package
  package { '$pacote':
    ensure          => installed,
    source          => "/tmp/${pacote}",
    provider        => 'dpkg',
    require         => File['zabbix-package'],
    install_options => ['--force-depends'],
  # before   => Exec['apt-get'],
  }

  # package { "libcurl3-gnutls":
  #  ensure => installed,
  #  before => Package['$pacote'],
  #}

  # running service
  service { 'zabbix-agent':
    ensure  => running,
    require => Package['$pacote'],
    enable  => true,
  }
}