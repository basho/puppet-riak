# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'

Vagrant.configure("2") do |config|

  # choices for virtual machines:
  #config.vm.box = 'precise64'
  #config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  #config.vm.box = 'debian-6.0'
  #config.vm.box_url = 'http://puppetlabs.s3.amazonaws.com/pub/Squeeze64.box'
  config.vm.box = 'CentOS-6.3_x86_64-small'
  config.vm.box_url = 'https://1412126a-vagrant.s3.amazonaws.com/CentOS-6.3-x86_64-reallyminimal.box'

  config.vm.synced_folder ".", "/etc/puppet/modules/riak"

  # give all nodes a little bit more memory:
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 1024]
  end

  # specify all Riak VMs:
  nodes = 1
  baseip = 5
  (1..nodes).each do |n|
    ip   = "10.42.0.#{baseip + n.to_i}"
    name = "riak-#{n}.local"
    config.vm.define name do |cfg|
      #cfg.vm.host_name = name
      cfg.vm.network :private_network, ip: "#{ip}"

      #get those gems installed
      #cfg.vm.provision :shell, :path => "shellprovision/bootstrap.sh"
      # specify puppet for provisioning
      cfg.vm.provision :puppet do |puppet|
        puppet.manifests_path = File.join 'spec', 'fixtures', 'manifests'
        puppet.module_path    = File.join 'spec', 'fixtures', 'modules'
        puppet.manifest_file  = 'vagrant-riak.pp'
        # '--trace', '--debug', '--verbose',
        puppet.options        = ['--trace', '--debug', '--verbose','--graph', '--graphdir /vagrant']

      end
    end
  end

  # for serving packages
 #config.vm.define :"coroutine.local" do |cfg|
 #  cfg.vm.host_name = 'coroutine.local'
 #  cfg.vm.network :hostonly, "10.42.0.20"
 #  cfg.vm.customize ["modifyvm", :id, "--memory", 512]
 #  cfg.vm.provision :puppet do |puppet|
 #    puppet.manifests_path = File.join 'spec', 'fixtures', 'manifests'
 #    puppet.module_path    = File.join 'spec', 'fixtures', 'modules'
 #    puppet.manifest_file  = 'vagrant-coroutine.pp'
 #    puppet.options        = []
 #  end
 #end
end
