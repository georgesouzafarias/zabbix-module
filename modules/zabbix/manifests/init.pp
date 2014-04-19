class zabbix {


  # Cria o diretorio que ficarao os arquivos do zabbix
  file { '/tmp/zabbix': ensure => directory; }

  # checa a arquitetura do sistema e manda o TAR correto
  #Sugestao Miguel

if $::architecture == 'i386' {
   $zabbix_tar = 'zabbix_32bit.tar.gz'
} else {
   $zabbix_tar = 'zabbix_64bit.tar.gz'
}

file { 'zabbix.tar.gz':
  path    => "/tmp/zabbix/zabbix.tar.gz",
  ensure  => file,
  require => File["/tmp/zabbix"],
  source  => "puppet:///zabbix/files/${zabbix_tar}",
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
#Sugestao Miguel
case $::osfamily {
 'Debian', 'RedHat': {
   file { "zabbix-agent":
     path    => "/etc/init.d/zabbix-agent",
     ensure  => file,
     owner   => root,
     group   => root,
     content => "puppet:///zabbix/files/init/zabbix-agent-${::osfamily}.conf",
     notify  => Service['zabbix-agent'],
   }
 }
 default: { fail('OS nao suportado') }
}


#Mantem o servico
service { 'zabbix-agent':
  ensure => running,
  enable => true,
}

}