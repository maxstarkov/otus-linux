# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure("2") do |config|

        config.ssh.insert_key = false

        config.vm.define "pxe_server" do |box|

                box.vm.box = "centos/8"
                box.vm.host_name = "pxeserver"

                box.vm.network "forwarded_port", guest: 22, host: 22220

                box.vm.network "private_network", ip: "192.168.0.254", virtualbox__intnet: "pxe_network"

                box.vm.synced_folder ".", "/vagrant", disabled: true

                box.vm.provider :virtualbox do |vb|

                        vb.memory = 1024
                        vb.cpus = 1

                        vb.customize [
                                'storageattach', :id,
                                '--storagectl', 'IDE',
                                '--port', '1',
                                '--device', '1',
                                '--type', 'dvddrive',
                                '--medium', 'CentOS-8.3.2011-x86_64-boot.iso'
                        ]

                        vb.customize [
                                'modifyvm', :id,
                                '--boot1', 'disk',
                                '--boot2', 'none',
                                '--boot3', 'none',
                                '--boot4', 'none'
                        ]

                end

        end

        config.vm.define "pxe_client", autostart: false do |box|

                box.vm.box = "centos/8"
                box.vm.host_name = "pxeclient"

                box.vm.network "forwarded_port", guest: 22, host: 22221

                box.vm.provider :virtualbox do |vb|

                        vb.memory = 2048
                        vb.cpus = 1
                        vb.gui = true
                

                        vb.customize [
                                'modifyvm', :id,
                                '--nic1', 'intnet',
                                '--intnet1', 'pxe_network',
                                '--boot1', 'net',
                                '--boot2', 'none',
                                '--boot3', 'none',
                                '--boot4', 'none'
                        ]

                end
                
        end

end