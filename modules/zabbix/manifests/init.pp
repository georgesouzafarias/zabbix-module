class zabbix {


  # Cria o diretorio que ficarao os arquivos do zabbix
  file { '/tmp/zabbix': ensure => directory; }

  # checa a arquitetura do sistema e manda o TAR correto
  if $::architecture == 'i386' {
    file { 'zabbix.tar.gz':
      path    => "/tmp/zabbix/zabbix.tar.gz",
      ensure  => file,
      require => File["/tmp/zabbix"],
      source  => "puppet:///zabbix/files/zabbix_32bit.tar.gz",
    }

  } else {
    file { 'zabbix.tar.gz':
      path    => "/tmp/zabbix/zabbix.tar.gz",
      ensure  => file,
      require => File["/tmp/zabbix"],
      source  => "puppet:///zabbix/files/zabbix_64bit.tar.gz",
    }

  }

  # Descompacta o Tar enviando anteriormente e cria o diretorio /tmp/zabbix/zabbix-tar
  exec { 'untar-zabbix.tar.gz':
    command => "tar xzf /tmp/zabbix/zabbix.tar.gz",
    cwd     => "/tmp/zabbix/",
    creates => "/tmp/zabbix/zabbix-tar",
    require => File["zabbix.tar.gz"],
     path => ["/bin/"],
  }

  file { "zabbix_agentd.conf":
    path    => "/usr/local/etc/zabbix_agentd.conf",
    ensure  => file,
    owner   => zabbix,
    group   => zabbix,
    source  => "puppet:///zabbix/files/conf/zabbix_agentd/zabbix_agentd.conf",
    require => File['/tmp/zabbix'],
  }

#Checa a Familia do SO e manda o script do Daemon correto

if $osfamily == 'Debian' {
  file { "zabbix-agent":
    path    => "/etc/init.d/zabbix-agent",
    ensure  => file,
    owner   => root,
    group   => root,
    content => "puppet:///zabbix/files/init/zabbix-agent-Debian.conf",
    notify  => Service['zabbix-agent'],
  }

} else {
file { "zabbix-agent":
  path    => "/etc/init.d/zabbix-agent",
  ensure  => file,
  owner   => root,
  group   => root,
  content => "puppet:///zabbix/files/init/zabbix-agent-RedHat.conf",
  notify  => Service['zabbix-agent'],
}
}

#Mantem o servico
service { 'zabbix-agent':
  ensure => running,
  enable => true,
}

}