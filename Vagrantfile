# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure("2") do |config|

        config.vagrant.plugins = "vagrant-vbguest"

        config.vm.define "maxst-centos-7-5" do |box|

                box.vm.box = "maxst/centos-7-5"
                box.vm.host_name = "maxst-centos-7-5"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end
                
        end

end