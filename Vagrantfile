# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure("2") do |config|

        config.ssh.insert_key = false

        config.vm.box = "centos/8"

        config.vm.provider "virtualbox" do |vm|
                vm.memory = 1024
                vm.cpus = 1
        end

        config.vm.define "ns01" do |ns01|
                ns01.vm.network "forwarded_port", guest: 22, host: 22220
                ns01.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "dns"
                ns01.vm.hostname = "ns01"
        end

        config.vm.define "ns02" do |ns02|
                ns02.vm.network "forwarded_port", guest: 22, host: 22221
                ns02.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "dns"
                ns02.vm.hostname = "ns02"
        end

        config.vm.define "client1" do |client1|
                client1.vm.network "forwarded_port", guest: 22, host: 22222
                client1.vm.network "private_network", ip: "192.168.50.15", virtualbox__intnet: "dns"
                client1.vm.hostname = "client1"
        end

        config.vm.define "client2" do |client2|
                client2.vm.network "forwarded_port", guest: 22, host: 22223
                client2.vm.network "private_network", ip: "192.168.50.16", virtualbox__intnet: "dns"
                client2.vm.hostname = "client2"
        end

end