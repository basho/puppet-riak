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
  
    extend args[0], args[1]
  end
  
  private
  def extend kvs1, kvs2
    raise ArgumentError unless is_hashish? kvs1
    raise ArgumentError unless is_hashish? kvs2
    # if kvs2 didn't have value, return kvs1
    return kvs1 if kvs2.nil?
    merged = kvs1.map { |k, v| 
      # recurse on those keys that have hashish values
      is_hashish?(v) && is_hashish?(kvs2.fetch(k)) ?
        # recurse
        [k, extend(v, kvs2.fetch(k))] :
        # get the value from kvs2, defaulting to value from kvs1
        [k, kvs2.fetch(k, v)]
    # union merge all items of kvs2
    } | kvs2.reject { |k, v| kvs1.has_key? k }.to_a
    Hash[ merged ]
  end
  
  # the police is coming
  def is_hashish? thing
    [:each, :fetch, :"has_key?", :reject].all? { |m| thing.respond_to? m }
  end
end
