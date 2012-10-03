class nginx::config {
  require boxen::config

  $configdir  = "${boxen::config::configdir}/nginx"
  $configfile = "${configdir}/nginx.conf"
  $datadir    = "${boxen::config::datadir}/nginx"
  $executable = "${boxen::config::homebrewdir}/sbin/nginx"
  $logdir     = "${boxen::config::logdir}/nginx"
  $pidfile    = "${datadir}/nginx.pid"
  $sitesdir   = "${configdir}/sites"

  # Install our custom plist for nginx. This is one of the very few
  # pieces of setup that takes over priv. ports (80 in this case).

  file { '/Library/LaunchDaemons/com.boxen.nginx.plist':
    content => template('nginx/com.boxen.nginx.plist.erb'),
    group   => 'wheel',
    notify  => Service['com.boxen.nginx'],
    owner   => 'root'
  }

  # Set up all the files and directories nginx expects. We go
  # nonstandard on this mofo to make things as clearly accessible as
  # possible under $BOXEN_HOME.

  file { [$configdir, $datadir, $logdir, $sitesdir]:
    ensure => directory
  }

  file { $configfile:
    content => template('nginx/config/nginx/nginx.conf.erb'),
    notify  => Service['com.boxen.nginx']
  }

  file { "${configdir}/mime.types":
    notify  => Service['com.boxen.nginx'],
    source  => 'puppet:///modules/nginx/config/nginx/mime.types'
  }

  # Set up a very friendly little default one-page site for when
  # people hit http://localhost.

  file { "${configdir}/public":
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/nginx/config/nginx/public'
  }
}
