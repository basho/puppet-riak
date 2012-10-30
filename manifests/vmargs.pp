# == Misc
#   A full file is available for browsing at
#   https://raw.github.com/basho/riak/master/rel/files/vm.args
#
# == Parameters
# source:
#   Sets the source parameter for the configuration file.
#   Mutually exclusive with 'template'.
#
# template:
#   File to use for templating vm.args. Mutually exclusive
#   with source.
#
class riak::vmargs (
  $cfg         = {},
  $erl_log_dir = hiera('erl_log_dir', $riak::params::erl_log_dir),
  $template    = hiera('vm_args_template', ''),
  $source      = hiera('vm_args_source', ''),
  $absent      = false,
) inherits riak::params {

  $vmargs_cfg = merge({
    '-name'      => "riak@${::ipaddress}",
    '-setcookie' => 'riak',
    '-ip'        => $::ipaddress,
    '+K'         => true,
    '+A'         => 64,
    '-smp'       => 'enable',
    '-env'       => {
      'ERL_MAX_PORTS'  => 4096,
      'ERL_CRASH_DUMP' => "${$erl_log_dir}/erl_crash.dmp",
    }
  }, $cfg)

  $manage_file = $absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_template = $template ? {
    ''      => write_erl_args($vmargs_cfg),
    default => template($template),
  }

  $manage_source = $source ? {
    ''      => undef,
    default => $source,
  }

  anchor { 'riak::vmargs::start': }

  file { '/etc/riak/vm.args':
    ensure  => $manage_file,
    content => $manage_template,
    source  => $manage_source,
    require => Anchor['riak::vmargs::start'],
    before  => Anchor['riak::vmargs::end'],
  }

  anchor { 'riak::vmargs::end': }
}
