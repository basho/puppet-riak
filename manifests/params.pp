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
    /(?i:centos|redhat|Amazon)/ => [],
    default                     => [],
  }

  $package_type = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => 'rpm',
    default                     => 'deb',
  }

  $package_provider = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => 'rpm',
    default                     => 'dpkg',
  }

  $architecture = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => 'x86_64',
    default                     => 'amd64',
  }

  $version = '1.3.0'
  $version_maj_min = semver_maj_min($version)
  $use_repos = true
  $get = $::operatingsystem ? {
    /(?i:centos|redhat|Amazon)/ => "/riak/${version_maj_min}/${version}/rhel/6/riak-${version}-1.el6.${architecture}.${package_type}",
    default                     => "/riak/${version_maj_min}/${version}/ubuntu/precise/riak_${version}-1_${architecture}.${package_type}",
  }

  $download = "http://downloads.basho.com.s3-website-us-east-1.amazonaws.com${get}"

  $download_hash = "${download}.sha"

  $log_dir = '/var/log/riak'
  $error_log = "${log_dir}/error.log"
  $info_log = "${log_dir}/console.log"
  $crash_log = "${log_dir}/crash.log"

  $erl_log_dir = '/var/log/riak'
  $data_dir = '/var/lib/riak'
  $lib_dir = '/usr/lib/riak'
  $bin_dir = '/usr/sbin'
  $etc_dir = '/etc/riak'

  $service_autorestart = true
}
