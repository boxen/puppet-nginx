class nginx {
  require nginx::config

  package { 'boxen/brews/nginx':
    ensure => '1.0.14-boxen1',
    notify => Service['com.boxen.nginx']
  }

  # Remove Homebrew's nginx config to avoid confusion.

  file { "${boxen::config::home}/homebrew/etc/nginx":
    ensure  => absent,
    force   => true,
    recurse => true,
    require => Package['boxen/brews/nginx']
  }

  service { 'dev.nginx':
    ensure  => running,
    require => Package['boxen/brews/nginx']
  }

  service { 'com.boxen.nginx': # replaced by dev.nginx
    before => Service['dev.nginx'],
    enable => false
  }
}
