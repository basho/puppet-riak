# Class: riak
#
# This module manages Riak, the dynamo-based NoSQL database.
#
# == Parameters
#
# version:
#   Version of package to fetch.
#
# package:
#   Name of package as known by OS.
#
# package_hash:
#   A URL of a hash-file or sha2-string in hexdigest
#
# source:
#   Sets the content of source parameter for main configuration file
#   If defined, riak's app.config file will have the param: source => $source.
#   Mutually exclusive with $template.
#
# template:
#   Sets the content of the content parameter for the main configuration file
#
# architecture:
#   What architecture to fetch/run on
#
# == Requires
#
# * stdlib (module)
# * hiera-puppet (module)
# * hiera (package in 2.7.x, but included inside Puppet 3.0)
#
# == Usage
#
# === Default usage:
#   This gives you all the defaults:
#
# class { 'riak': }
#
# === Overriding configuration
#
#   In this example, we're adding HTTPS configuration
#   with a certificate file / public key and a private
#   key, both placed in the /etc/riak folder.
#
#   When you add items to the 'cfg' parameter, they will override the
#   already defined defaults with those keys defined. The hash is not
#   hard-coded, so you don't need to change the manifest when new config
#   options are made available.
#
#   You can probably benefit from using hiera's hierarchical features
#   in this case, by defining defaults in a yaml file for all nodes
#   and only then configuring specifics for each node.
#
#  class { 'riak':
#    cfg => {
#      riak_core => {
#        https => {
#          "__string_${$::ipaddress}" => 8443
#        },
#        ssl => {
#          certfile => "${etc_dir}/cert.pem",
#          keyfile  => "${etc_dir}/key.pem"
#        }
#      }
#    }
#  }
#
# == Author
#   Henrik Feldt, github.com/haf/puppet-riak.
#
class riak(
  $version = hiera('version', $riak::params::version),
  $package = hiera('package', $riak::params::package),
  $download = hiera('download', $riak::params::download),
  $download_hash = hiera('download_hash', $riak::params::download_hash),
  $source = hiera('source', ''),
  $template = hiera('template', ''),
  $architecture = hiera('architecture', $riak::params::architecture),
  $log_dir = hiera('log_dir', $riak::params::log_dir),
  $erl_log_dir = hiera('erl_log_dir', $riak::params::erl_log_dir),
  $etc_dir = hiera('etc_dir', $riak::params::etc_dir),
  $data_dir = hiera('data_dir', $riak::params::data_dir),
  $service_autorestart = hiera('service_autorestart',
    $riak::params::service_autorestart
  ),
  $cfg = hiera_hash('cfg', {}),
  $vmargs_cfg = hiera_hash('vmargs_cfg', {}),
  $disable = false,
  $disableboot = false,
  $absent = false
) inherits riak::params {

  include stdlib

  $pkgfile = "/tmp/${$package}-${$version}.${$riak::params::package_type}"

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $manage_package = $absent ? {
    true => 'absent',
    default => 'latest',
  }

  $manage_service_ensure = $disable ? {
    true => 'stopped',
    default => $absent ? {
      true => 'stopped',
      default => 'running',
    },
  }

  $manage_service_enable = $disableboot ? {
    true => false,
    default => $disable ? {
      true => false,
      default => $absent ? {
        true => false,
        default => true,
      },
    },
  }

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present'
  }

  $manage_service_autorestart = $service_autorestart ? {
    /true/ => 'Service[riak]',
    default => undef,
  }

  anchor { 'riak::start': } ->

  httpfile {  $pkgfile:
    ensure => present,
    source => $download,
    hash   => $download_hash
  }

  #notify { 'url':
  #  message => "Downloaded file from ##${download}/${download_hash}##",
  #}

  package { $riak::params::deps:
    ensure  => $manage_package
  }

  package { 'riak':
    ensure   => $manage_package,
    source   => $pkgfile,
    provider => $riak::params::package_provider,
    require  => [
      Httpfile[$pkgfile],
      Package[$riak::params::deps]
    ]
  }

  file { $etc_dir:
    ensure => directory,
    mode   => '0755'
  }

  class { 'riak::appconfig':
    absent   => $absent,
    source   => $source,
    template => $template,
    cfg      => $cfg,
    require  => File[$etc_dir],
    notify   => $manage_service_autorestart
  }

  class { 'riak::vmargs':
    absent  => $absent,
    cfg     => $vmargs_cfg,
    require => File[$etc_dir],
    notify  => $manage_service_autorestart,
  }

  group { 'riak':
    ensure => present
  }

  user { 'riak':
    ensure  => ['present'],
    gid     => 'riak',
    home    => $data_dir,
    require => Group['riak']
  }

  service { 'riak':
    ensure  => $manage_service_ensure,
    enable  => $manage_service_enable,
    status  => 'riak-admin test',
    require => [
      Class['riak::appconfig'],
      Class['riak::vmargs'],
      User['riak'],
      Package['riak']
    ],
  } ->

  anchor { 'riak::end': }
}
