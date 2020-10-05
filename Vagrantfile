# -*- mode: ruby -*-
# vim: set ft=ruby :

MY_HD_DIR = "D:\\VM\\hd"

hd_dir = if File.directory?(MY_HD_DIR) then MY_HD_DIR else "." end

disks_for_backup = {
        :sata1 => {
                :dfile => hd_dir + '/backup_volume.vdi',
                :size => 2048,
                :port => 1
        }
}

Vagrant.configure("2") do |config|

        config.vbguest.auto_update = false

        config.vm.define "backup_server" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "backupserver"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                        
                        needsController = false

                        disks_for_backup.each do |dname, dconf|
                                unless File.exist?(dconf[:dfile])
                                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                        needsController =  true
                                end
                        end

                        if needsController == true
                        
                                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                        
                                disks_for_backup.each do |dname, dconf|
                                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                                end
                        end
                end

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                yum install -y epel-release
                yum install -y borgbackup
                mkfs.xfs /dev/sdb
                mkdir /var/backup
                cp /vagrant/var-backup.mount /etc/systemd/system
                systemctl daemon-reload
                systemctl enable var-backup.mount
                systemctl start var-backup.mount
                chown vagrant:vagrant /var/backup
                SHELL
                
        end

        config.vm.define "backup_client" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "backupclient"

                box.vm.network "private_network", ip: '192.168.11.102'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL

                box.vm.provision "file", source: ".vagrant/machines/backup_server/virtualbox/private_key", destination: "/home/vagrant/backup_server.key"

                box.vm.provision "shell", inline: <<-SHELL
                mv ~vagrant/backup_server.key ~root/.ssh/id_rsa
                cp ~root/.ssh/id_rsa ~vagrant/.ssh/id_rsa
                chown vagrant:vagrant ~vagrant/.ssh/id_rsa
                chmod 400 ~vagrant/.ssh/id_rsa
                chown root /root/.ssh/id_rsa
                chmod 400 /root/.ssh/id_rsa
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                yum install -y epel-release
                yum install -y borgbackup
                export BORG_PASSPHRASE='123'
                export BORG_RSH='ssh -o StrictHostKeyChecking=no'
                borg init --encryption=repokey ssh://vagrant@192.168.11.101/var/backup
                cp /vagrant/borg_backup.sh /root/borg_backup.sh
                chmod 0700 /root/borg_backup.sh
                cp /vagrant/borg-backup.service /etc/systemd/system
                cp /vagrant/borg-backup.timer /etc/systemd/system
                systemctl daemon-reload
                systemctl enable borg-backup.timer
                systemctl start borg-backup.timer 
                SHELL

        end

end