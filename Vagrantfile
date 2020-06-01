# -*- mode: ruby -*-
# vim: set ft=ruby :

MY_HD_DIR = "D:\\VM\\hd"

hd_dir = if File.directory?(MY_HD_DIR) then MY_HD_DIR else "." end

disks_for_raid = {
        :sata1 => {
                :dfile => hd_dir + '/sata1.vdi',
                :size => 250,
                :port => 1
        },
        :sata2 => {
                :dfile => hd_dir + '/sata2.vdi',
                :size => 250, # Megabytes
                :port => 2
        },
        :sata3 => {
                :dfile => hd_dir + '/sata3.vdi',
                :size => 250,
                :port => 3
        },
        :sata4 => {
                :dfile => hd_dir + '/sata4.vdi',
                :size => 250, # Megabytes
                :port => 4
        },
                :sata5 => {
                :dfile => hd_dir + '/sata5.vdi',
                :size => 250, # Megabytes
                :port => 5
        }
}

disks_for_raid_migrate = {
        :sata1 => {
                :dfile => hd_dir + '/sata1_migrate.vdi',
                :size => 10000,
                :port => 1
        },
        :sata2 => {
                :dfile => hd_dir + '/sata2_migrate.vdi',
                :size => 10000, # Megabytes
                :port => 2
        }
}

Vagrant.configure("2") do |config|

        config.vm.define "otuslinux" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "centos-7-raid"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                        
                        needsController = false

                        disks_for_raid.each do |dname, dconf|
                                unless File.exist?(dconf[:dfile])
                                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                        needsController =  true
                                end
                        end

                        if needsController == true
                        
                                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                        
                                disks_for_raid.each do |dname, dconf|
                                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                                end
                        end
                end

                box.vm.provision "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
                yum install -y mdadm smartmontools hdparm gdisk
                SHELL

                box.vm.provision "shell", path: "create_raid5.sh"

        end

        config.vm.define "otuslinux-migrate-to-raid" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "centos-7-migrate-to-raid"

                box.vm.network "private_network", ip: '192.168.11.102'

                box.vm.provider :virtualbox do |vb|
                        
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                        
                        needsController = false

                        disks_for_raid_migrate.each do |dname, dconf|
                                unless File.exist?(dconf[:dfile])
                                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                        needsController =  true
                                end
                        end

                        if needsController == true
                        
                                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                        
                                disks_for_raid_migrate.each do |dname, dconf|
                                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                                end
                        end
                end

                box.vm.provision "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
                yum install -y mdadm smartmontools hdparm gdisk xfsdump
                SHELL

                box.vm.provision "shell", path: "create_raid1.sh"
                
        end
end

