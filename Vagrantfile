# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :inetRouter => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22220},
        :net => [
                   {adapter: 2, virtualbox__intnet: "router-net"},
                ]
  },
  :centralRouter => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22221},
        :net => [
                   {adapter: 2, virtualbox__intnet: "router-net"},
                   {adapter: 3, virtualbox__intnet: "dir-net"},
                   {adapter: 4, virtualbox__intnet: "hw-net"},
                   {adapter: 5, virtualbox__intnet: "mgt-net"},
                   {adapter: 6, virtualbox__intnet: "of1-net"},
                   {adapter: 7, virtualbox__intnet: "of2-net"},
                ]
  },
  :centralServer => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22224},
        :net => [
                   {adapter: 2, virtualbox__intnet: "dir-net"},
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
                ]
  },
  :office2Router => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22223},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of2-net"},
                   {adapter: 3, virtualbox__intnet: "of2-dev-net"},
                   {adapter: 4, virtualbox__intnet: "of2-test-net"},
                   {adapter: 5, virtualbox__intnet: "of2-hw-net"},
                ]
  },
  :office1Server => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22225},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of1-dev-net"},
                ]
  },
  :office2Server => {
        :box_name => "centos/8",
        :fwdp => {:guest => 22, :host => 22226},
        :net => [
                   {adapter: 2, virtualbox__intnet: "of2-dev-net"},
                ]
  },  
}

Vagrant.configure("2") do |config|

  config.ssh.insert_key = false

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

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
          vb.customize ["modifyvm", :id, "--memory", "1024"]
        end

      end

  end 
  
end