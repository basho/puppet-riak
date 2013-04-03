module Puppet::Parser::Functions
  newfunction(:semver_maj_min, :type => :rvalue, :doc => <<-DOC) do |*args|
    Parse the major and minor numbers, separated by a dot (.)
    from the given string.
  DOC
    if args[0].is_a? Array
        args = args[0]
    end
    # https://github.com/puppetlabs/puppet/blob/master/lib/semver.rb
    s = ::SemVer.new(args[0])
    "#{s.major}.#{s.minor}"
  end
end