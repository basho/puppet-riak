module Puppet::Parser::Util
  class Merger
    
    attr_reader :h1, :h2

    def initialize h1, h2
      @h1, @h2 = h1, h2
      raise ArgumentError unless is_hashish?(h1)
      raise ArgumentError unless is_hashish?(h2)
    end
    def compute
      compute_inner h1, h2
    end
    def compute_inner kvs1, kvs2
      # if kvs2 didn't have value, return kvs1
      return kvs1 if kvs2.nil?

      merged = kvs1.map { |k, v| 
        # recurse on those keys that have hashish values
        is_hashish?(v) && is_hashish?(kvs2.fetch(k, nil)) ?
          # recurse
          [k, compute_inner(v, kvs2.fetch(k, nil))] :
          # get the value from kvs2, defaulting to value from kvs1
          [k, kvs2.fetch(k, v)]
      # union merge all items of kvs2
      } | kvs2.reject { |k, v| kvs1.has_key? k }.to_a

      ::Hash[ merged ]
    end
    def is_hashish? thing
      return false if thing.nil?
      [:each, :fetch, :"has_key?", :reject].all? { |m| thing.respond_to? m }
    end
  end
end
