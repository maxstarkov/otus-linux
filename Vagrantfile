# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure("2") do |config|
        
        config.vm.define "nfs_server" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "nfsserver"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.synced_folder ".", "/vagrant", disabled: true

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                yum -y install nfs-utils rpcbind
                systemctl enable firewalld --now
                systemctl enable nfs-server --now
                systemctl enable rpcbind
                firewall-cmd --permanent --add-service nfs
                firewall-cmd --permanent --add-service mountd
                firewall-cmd --permanent --add-service rpc-bind
                firewall-cmd --permanent --add-port=2049/udp
                firewall-cmd --reload
                mkdir -p /var/nfs/nfs_share
                mkdir -p /var/nfs/upload
                echo "/var/nfs/nfs_share 192.168.11.102(ro,no_root_squash)" >> /etc/exports
                echo "/var/nfs/upload 192.168.11.102(rw,no_root_squash)" >> /etc/exports
                exportfs -r
                SHELL

        end

        config.vm.define "nfs_client" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "nfsclient"

                box.vm.network "private_network", ip: '192.168.11.102'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.synced_folder ".", "/vagrant", disabled: true

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                mkdir -p /nfs/nfs_share
                mkdir -p /nfs/upload
                echo "192.168.11.101:/var/nfs/nfs_share /nfs/nfs_share nfs defaults,soft,nfsvers=3,udp 0 0" >> /etc/fstab
                echo "192.168.11.101:/var/nfs/upload /nfs/upload nfs defaults,soft,nfsvers=3,udp 0 0" >> /etc/fstab
                mount -a
                SHELL

        end

end