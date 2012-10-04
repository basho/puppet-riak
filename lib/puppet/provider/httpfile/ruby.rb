require 'fileutils'
# http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html
require 'net/http'
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/digest/rdoc/Digest.html
require 'digest'

Puppet::Type.type(:httpfile).provide(:ruby) do

  desc "Download the file with Ruby"

  has_feature :hash

  def hash
    return @hash if @hash
    if resource.parameter(:hash).was_uri then
      h = resource[:hash]
      # REVISIT: make extendable for other file formats
      @hash = Net::HTTP.get(h).split(' ').first
    else
      @hash = resource[:hash]
    end
    @hash
  end

  # create the file by downloading it
  #
  # pre-condition:
  #   exists? has been called and returned false
  def create

    # clean badly hashing files
    if File.exists? resource[:path] then
      FileUtils.rm resource[:path]
      info 'cleaned out existing file, since it hashed badly or was outdated'
    end

    digester = Digest::SHA2.new
    uri = resource[:source]

    info "Starting to download Httpfile[#{resource[:name]}) from URI[#{uri.to_s}]/#{hash}"

    Net::HTTP.start uri.host, uri.port do |http|
      http.request_get uri.request_uri do |resp|
        open resource[:path], "w+" do |io|
          resp.read_body do |segment|
            io.write segment
            digester.update segment
          end
        end
      end
    end

    info 'download complete, verifying file integrity'

    unless hash == digester.hexdigest
      raise Puppet::Error, "Data at URI[#{uri.to_s}]/#{digester.hexdigest}]\
 didn\'t match expected Httpfile[#{hash}], please retry or correct the hash."
    end

  end

  # remove the file if it exists, no matter its hash
  def destroy
    FileUtils.rm resource[:path] if File.exists? resource[:path]
  end

  # it exists if it exists and it hashes properly
  def exists?

    return false unless File.exists? resource[:path]

    digester = Digest::SHA2.new

    File.open resource[:path] do |file|
      buffer = ''
      while not file.eof
        file.read 512, buffer
        digester.update buffer
      end
    end

    digester.hexdigest == hash
  end

end
