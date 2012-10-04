# https://projects.puppetlabs.com/issues/4248
# require 'puppet/parser/util/erly'
require File.join(File.dirname(__FILE__), '/../util/erly')

module Puppet::Parser::Functions
  newfunction(:write_erl_config, :type => :rvalue, :doc => <<-DOC) do |*args|
    Output an erlang configuration from the given hash.
  DOC

    raise(Puppet::ParseError, "write_erl_config(): Wrong number of arguments " +
          "given (#{args.size} for 1 or 2)") if args.size < 1

    # Functions called from puppet manifests that look like this:
    # lookup("foo", "bar")
    # internally in puppet are invoked: func(["foo", "bar"])
    #
    # where as calling from templates should work like this:
    # scope.function_lookup("foo", "bar")
    #
    # Therefore, declare this function with args '*args' to accept any number
    # of arguments and deal with puppet's special calling mechanism now:
    if args[0].is_a?(Array)
        args = args[0]
    end

    h = args[0] # hash
    s = (args.length == 2 && args[1]) || :pp # symbol

    ::Puppet::Parser::Util::Config.new(h).send(s)
  end
end
