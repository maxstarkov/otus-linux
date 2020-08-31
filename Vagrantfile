# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

        config.vm.define "otuslinux" do |box|
      
                box.vm.box = "centos/7"
      
                box.vm.network "private_network", ip: "192.168.33.11"
      
                box.vm.provider "virtualbox" do |vb|
                        vb.memory = "512"
                        vb.cpus = "1"
                end
        
                box.vm.provision "shell", inline: <<-SHELL
                SHELL

        end
      
end