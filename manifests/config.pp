class nginx::config {
  require github::config

  $configdir  = "${github::config::configdir}/nginx"
  $configfile = "${configdir}/nginx.conf"
  $datadir    = "${github::config::datadir}/nginx"
  $executable = "${github::config::homebrewdir}/sbin/nginx"
  $logdir     = "${github::config::logdir}/nginx"
  $pidfile    = "${datadir}/nginx.pid"
  $sitesdir   = "${configdir}/sites"

  # Install our custom plist for nginx. This is one of the very few
  # pieces of setup that takes over priv. ports (80 in this case).

  file { '/Library/LaunchDaemons/com.github.nginx.plist':
    content => template('nginx/com.github.nginx.plist.erb'),
    group   => 'wheel',
    notify  => Service['com.github.nginx'],
    owner   => 'root'
  }

  file { '/Library/LaunchDaemons/com.github.setup-monitor.plist':
    content => template('nginx/com.github.setup-monitor.plist.erb'),
    group   => 'wheel',
    notify  => Service['com.github.setup-monitor'],
    owner   => 'root'
  }

  # Set up all the files and directories nginx expects. We go
  # nonstandard on this mofo to make things as clearly accessible as
  # possible under $GH_HOME.

  file { [$configdir, $datadir, $logdir, $sitesdir]:
    ensure => directory
  }

  file { $configfile:
    content => template('nginx/config/nginx/nginx.conf.erb'),
    notify  => Service['com.github.nginx']
  }

  file { "${configdir}/mime.types":
    notify  => Service['com.github.nginx'],
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
