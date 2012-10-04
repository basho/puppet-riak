require 'uri'

Puppet::Type.newtype(:httpfile) do
  include Puppet::Util::MethodHelper

  @doc = 'Download and verify files through HTTP'

  feature :hash, 'The ability to hash the downloaded file', :methods => [:hash]

  ensurable do
    newvalue :present do
      provider.create unless provider.exists?
      nil # autogen event if returning nil
    end

    newvalue :absent do
      provider.destroy
      nil
    end
  end

  newparam :source do

    desc 'Where to download the file from'

    validate do |v|
      begin
        URI.parse(v) # raises InvalidURIError if invalid
      rescue URI::InvalidURIError => e
        fail Puppet::Error, "The value '#{v}' doesn't parse. #{e.to_s}"
      end
    end

    munge { |v| URI.parse(v) }

  end

  newparam :hash, :required_features => %w{hash} do

    attr_writer :is_uri

    desc 'What is the hash of the file or where from to download the hash?'

    validate do |v|
      v || fail(Puppet::Error, 'empty or undefined hash property')
    end

    munge do |v|
      v = v.strip
      if is_uri v then
        URI.parse(v)
      else
        v
      end
    end

    def is_uri v
      return @is_uri unless @is_uri.nil?
      return @is_uri = true if v.is_a? URI

      begin
        URI.parse v
        @is_uri = true
      rescue URI::InvalidURIError => e
        @is_uri = false
        info "#{v} wasn't uri: #{e}"
      end

      @is_uri
    end

    def was_uri ; @is_uri ; end
  end

  newparam :path do

    desc "Where to place the downloaded file"

    isnamevar

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        fail Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end

    munge do |value|
      ::File.expand_path(value)
    end

  end
end
