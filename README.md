# nginx Puppet Module for Boxen
[![Build
Status](https://travis-ci.org/boxen/puppet-nginx.svg?branch=master)](https://travis-ci.org/boxen/puppet-nginx)

## Usage

```puppet
include nginx
```

To specify a different port than 80:
```puppet
class { "nginx":
    port => 8080
}
```

## Required Puppet Modules

* boxen
* homebrew
* stdlib

## Development

Write code. Run `script/cibuild` to test it. Check the `script`
directory for other useful tools.
