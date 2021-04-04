# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :inetRouter => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22220},
        :net => [
                   {adapter: 2, virtualbox__intnet: "bond0"},
                   {adapter: 3, virtualbox__intnet: "bond1"},
                ]
  },
  :centralRouter => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22221},
        :net => [
                   {adapter: 2, virtualbox__intnet: "bond0"},
                   {adapter: 3, virtualbox__intnet: "dir-net"},
                   {adapter: 4, virtualbox__intnet: "hw-net"},
                   {adapter: 5, virtualbox__intnet: "mgt-net"},
                   {adapter: 6, virtualbox__intnet: "of1-net"},
                   {adapter: 7, virtualbox__intnet: "of2-net"},
                   {adapter: 8, virtualbox__intnet: "bond1"},
                ]
  },
  :office1Router => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22222},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of1-net"},
                   {adapter: 3, virtualbox__intnet: "of1-dev-net"},
                   {adapter: 4, virtualbox__intnet: "of1-test-net"},
                   {adapter: 5, virtualbox__intnet: "of1-mng-net"},
                   {adapter: 6, virtualbox__intnet: "of1-hw-net"},
                   {adapter: 7, virtualbox__intnet: "of1-test-lan"},
                ]
  },
  :testServer1 => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22223},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of1-test-lan"},
                ]
  },
  :testClient1 => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22224},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of1-test-lan"},
                ]
  },
  :testServer2 => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22225},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of1-test-lan"},
                ]
  },
  :testClient2 => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22226},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of1-test-lan"},
                ]
  },  
}

Vagrant.configure("2") do |config|

  config.ssh.insert_key = false

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        box.vm.synced_folder ".", "/vagrant", disabled: true

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        if boxconfig.key?(:fwdp)
          box.vm.network "forwarded_port", boxconfig[:fwdp]
        end

        box.vm.provider :virtualbox do |vb|
          vb.memory = 1024
          vb.cpus = 1
        end

      end

  end 
  
end