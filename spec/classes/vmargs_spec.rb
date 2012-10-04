# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'spec_helper'
require 'shared_contexts'

describe 'riak::vmargs', :type => :class do

  include_context 'hieradata'

  let(:title) { "vm.args" }

  describe 'at baseline defaults' do
    let(:params) {{}}
    it { should contain_file('/etc/riak/vm.args').with({
      :ensure  => 'present',
      :source  => nil
    }) }
  end

  describe 'when decommissioning w/ hiera (absent):' do
    let(:hiera_data) do
      { :absent => true }
    end
    it {
      # https://github.com/amfranz/rspec-hiera-puppet/issues/3
      pending 'strange: hiera should look at :hiera_data, before looking at default'
      should contain_file('/etc/riak/vm.args').with_ensure('absent') }
  end

  describe 'when decommissioning w/ params (absent):' do
    let(:params) do
      { :absent => true }
    end
    it { should contain_file('/etc/riak/vm.args').with_ensure('absent') }
  end
end
