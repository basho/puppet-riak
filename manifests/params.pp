# == Class: riak::params
#
# This class implements the module params pattern, but it's loaded using hiera
# as opposed to the 'default' usage of coding the parameter values in your
# manifest.
#
# == Usage
#
# Don't use this class directly; it's being used where it is needed
#
class riak::params {

  $package = $::operatingsystem ? {
    default => 'riak',
  }

  $deps = $::operatingssytem ? {
    /(?i:centos|redhat)/ => [],
    default              => [],
  }

  $package_type = $::operatingsystem ? {
    /(?i:centos|redhat)/ => 'rpm',
    default              => 'deb',
  }

  $package_provider = $::operatingsystem ? {
    /(?i:centos|redhat)/ => 'rpm',
    default              => 'dpkg',
  }

  $architecture = $::operatingsystem ? {
    /(?i:centos|redhat)/ => 'x86_64',
    default              => 'amd64',
  }

  $version = '1.2.0'
  $use_repos = true
  $get = $::operatingsystem ? {
    /(?i:centos|redhat)/ => "/riak/CURRENT/rhel/6/riak-${version}-1.el6.${architecture}.${package_type}",
    default              => "/riak/CURRENT/ubuntu/precise/riak_${version}-1_${architecture}.${package_type}",
  }

  $download = "http://downloads.basho.com.s3-website-us-east-1.amazonaws.com${get}"

  $download_hash = "${download}.sha"

  $error_log = "${log_dir}/error.log"
  $info_log = "${log_dir}/console.log"
  $crash_log = "${log_dir}/crash.log"

  $log_dir = '/var/log/riak'
  $erl_log_dir = '/var/log/riak'
  $data_dir = '/var/lib/riak'
  $lib_dir = '/usr/lib/riak'
  $bin_dir = '/usr/sbin'
  $etc_dir = '/etc/riak'

  $service_autorestart = true
}
