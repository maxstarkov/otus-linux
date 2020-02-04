# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure("2") do |config|
        
        config.vm.define "nginx" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "nginx"

                box.vm.network "private_network", ip: '192.168.11.102'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.synced_folder ".", "/vagrant", disabled: true

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL
        end

        config.vm.define "ansible" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "ansible"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.provision "file", source: ".vagrant/machines/nginx/virtualbox/private_key", destination: "/home/vagrant/nginx.key"
                box.vm.provision "shell", inline: <<-SHELL
                        mv ~vagrant/nginx.key ~vagrant/.ssh/id_rsa
                        chown vagrant /home/vagrant/.ssh/id_rsa
                        chmod 400 /home/vagrant/.ssh/id_rsa
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                        yum install -y ansible
                SHELL

                box.vm.provision "shell", path: "install_ansible_config.sh"

        end

end