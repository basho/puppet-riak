#ruby=1.9.3
#ruby-gemset=puppet-riak
# this Gemfile is for the development of the module, you don't need all of these to RUN the module with puppet
source 'https://rubygems.org'
gem 'mocha'
gem 'puppet'
gem 'puppet-lint'
gem 'hiera' #, :git => 'git://github.com/puppetlabs/hiera.git' <- not working
gem 'hiera-puppet'
gem 'rspec'
gem 'rspec-puppet'
gem 'rspec-hiera-puppet' # for unit-testing using hiera data
gem 'puppetlabs_spec_helper'

group :testing do
  gem 'guard' # for running specs easily
  gem 'libnotify' #requires: 'sudo apt-get install libnotify-bin'
  # for running 'rake vagrant:provision' when editing
  gem 'guard-rake', :git => 'git://github.com/joergschiller/guard-rake.git'
  gem 'guard-rspec' # for running specs automatically
  gem 'guard-puppet-lint'
end
