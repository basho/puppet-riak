require File.join(File.dirname(__FILE__), '/../util/merger')

module Puppet::Parser::Functions
  newfunction(:merge_hashes, :type => :rvalue, :doc => <<-DOC) do |*args|
    Merge two hierarchial hashes together, keeping
    values from the first hash which are not overridden in the second
    hash, while adding values not existent in the first hash from the second
    hash, to produce a final hash. Have a look at the source code
    for further comments and documentation.
  DOC

    if args[0].is_a? Array
      args = args[0]
    end

    raise(Puppet::ParseError, "merge_hashes/2: Wrong number of arguments " +
          "given (#{args.size} instead of 2.)") unless args.size == 2
  
    ::Puppet::Parser::Util::Merger.new(args[0], args[1]).compute
  end
end
