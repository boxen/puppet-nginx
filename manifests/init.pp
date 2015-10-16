# Install nginx
#
class nginx(
  $ensure = present,
) {
  include nginx::config
  include homebrew

  case $ensure {
    present: {
      # Install our custom plist for nginx. This is one of the very few
      # pieces of setup that takes over priv. ports (80 in this case).

      file { '/Library/LaunchDaemons/dev.nginx.plist':
        content => template('nginx/dev.nginx.plist.erb'),
        group   => 'wheel',
        notify  => Service['dev.nginx'],
        owner   => 'root'
      }

      # Set up all the files and directories nginx expects. We go
      # nonstandard on this mofo to make things as clearly accessible as
      # possible under $BOXEN_HOME.

      file { [
        $nginx::config::configdir,
        $nginx::config::datadir,
        $nginx::config::logdir,
        $nginx::config::sitesdir
      ]:
        ensure => directory
      }

      file { $nginx::config::configfile:
        content => template('nginx/config/nginx/nginx.conf.erb'),
        notify  => Service['dev.nginx']
      }

      file { "${nginx::config::configdir}/mime.types":
        notify  => Service['dev.nginx'],
        source  => 'puppet:///modules/nginx/config/nginx/mime.types'
      }

      # Set up a very friendly little default one-page site for when
      # people hit http://localhost.

      file { "${nginx::config::configdir}/public":
        ensure  => directory,
        recurse => true,
        source  => 'puppet:///modules/nginx/config/nginx/public'
      }

      homebrew::formula { 'nginx':
        before => Package['boxen/brews/nginx'],
      }

      package { 'boxen/brews/nginx':
        ensure => '1.8.0-boxen2',
        notify => Service['dev.nginx']
      }

      # Remove Homebrew's nginx config to avoid confusion.

      file { "${boxen::config::homebrewdir}/etc/nginx":
        ensure  => absent,
        force   => true,
        recurse => true,
        require => Package['boxen/brews/nginx']
      }

      service { 'dev.nginx':
        ensure  => running,
        require => Package['boxen/brews/nginx']
      }
    }

    absent: {
      service { 'dev.nginx':
        ensure  => stopped,
      }

      file { '/Library/LaunchDaemons/dev.nginx.plist':
        ensure => absent
      }

      file { [
        $nginx::config::configdir,
        $nginx::config::datadir,
        $nginx::config::logdir,
        $nginx::config::sitesdir
      ]:
        ensure => absent
      }

      package { 'boxen/brews/nginx':
        ensure => absent,
      }
    }

    default: {
      fail('Nginx#ensure must be present or absent!')
    }
  }
}
