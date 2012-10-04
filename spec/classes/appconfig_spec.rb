# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'spec_helper'
require 'shared_contexts'

describe 'riak', :type => :class do

  let(:title) { "riak" }

  include_context 'hieradata'
end
