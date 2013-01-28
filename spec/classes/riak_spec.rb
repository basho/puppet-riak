# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'spec_helper'
require 'shared_contexts'

describe 'riak', :type => :class do

  let(:title) { "riak" }

  include_context 'hieradata'

  describe 'at baseline with defaults' do
    let(:params) {{}}
    it { should contain_class('riak') }
    # we're defaulting to repos now, not http files
    it { should contain_package('riak').with_ensure('installed') }
    it { should contain_service('riak').with({
        :ensure => 'running',
        :enable => 'true'
      }) }
    it { should contain_file('/etc/riak/app.config').with_ensure('present') }
    it { should contain_file('/etc/riak/vm.args').with_ensure('present') }
    it { should contain_riak__vmargs().with_notify('Service[riak]') }
  end

  describe 'custom package configuration' do
    let(:params) { { :version => '1.2.0', :package => 'custom_riak',
                     :download_hash => 'abcd', :use_repos => false } }
    it 'should be downloading the package to be installed' do
      subject.should contain_httpfile('/tmp/custom_riak-1.2.0.deb').
        with({
          :path => '/tmp/custom_riak-1.2.0.deb',
          :hash => 'abcd' })
    end
    it { should contain_package('riak').
        with({
          :ensure => 'installed',
          :source =>'/tmp/custom_riak-1.2.0.deb'}) }
  end

  def res t, n
    catalogue.resource(t, n).send(:parameters)
  end

  describe 'when changing configuration' do
    #before(:all) { puts catalogue.resources }
    it("will restart Service") {
      res('class', 'Riak::Appconfig')[:notify].
        should eq('Service[riak]') }
  end

  describe 'when changing configuration, the service' do
    let(:params) { { :service_autorestart => false } }
    it('will not restart') {
      res('class', 'Riak::Appconfig')[:notify].nil?.should be_true }
  end

  describe 'when decommissioning (absent):' do
    let(:params) { { :absent => true } }
    it("should remove the riak package") {
      should contain_package('riak').with_ensure('absent') }
    it("should remove configuration file File[/etc/riak/vm.args]") {
      should contain_file('/etc/riak/vm.args').with_ensure('absent') }
    it("remove configuration File[/etc/riak/app.config]") {
      should contain_file('/etc/riak/app.config').with_ensure('absent') }
    it("should stop Service[riak]") {
      should contain_service('riak').with_ensure('stopped') }
    it("should disable boot of Service[riak]") {
      should contain_service('riak').with_enable('false') }
  end

end
