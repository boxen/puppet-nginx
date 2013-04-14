#Config for nginx
#
class nginx::config {
  require boxen::config

  $configdir  = "${boxen::config::configdir}/nginx"
  $configfile = "${configdir}/nginx.conf"
  $datadir    = "${boxen::config::datadir}/nginx"
  $executable = "${boxen::config::homebrewdir}/sbin/nginx"
  $logdir     = "${boxen::config::logdir}/nginx"
  $pidfile    = "${datadir}/nginx.pid"
  $sitesdir   = "${configdir}/sites"
}
