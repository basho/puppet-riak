# https://projects.puppetlabs.com/issues/4248
# require 'puppet/parser/util/erly'
require File.join(File.dirname(__FILE__), '/../util/erly')

module Puppet::Parser::Functions
  newfunction(:write_erl_args, :type => :rvalue, :doc => <<-DOC) do |*args|
    Output an erlang virtual machine args from the given hash.
  DOC

    raise(Puppet::ParseError, "write_erl_args(): Wrong number of arguments " +
          "given (#{args.size} for 1 or 2)") if args.size < 1

    if args[0].is_a? Array
        args = args[0]
    end

    h = args[0] # hash
    s = (args.length == 2 && args[1]) || :pp # symbol

    ::Puppet::Parser::Util::Args.new(h).send(s)
  end
end
