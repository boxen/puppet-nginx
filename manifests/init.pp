class nginx {
  require nginx::config

  package { 'github/brews/nginx':
    ensure => '1.0.14-github1',
    notify => Service['com.github.nginx']
  }

  # Remove Homebrew's nginx config to avoid confusion.

  file { "${github::config::home}/homebrew/etc/nginx":
    ensure  => absent,
    force   => true,
    recurse => true,
    require => Package['github/brews/nginx']
  }


  service { 'com.github.nginx':
    ensure  => running,
    require => Package['github/brews/nginx']
  }

  service { 'com.github.setup-monitor':
    ensure   => running,
  }
}
