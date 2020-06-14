# -*- mode: ruby -*-
# vim: set ft=ruby :

MY_HD_DIR = "D:\\VM\\hd"

hd_dir = if File.directory?(MY_HD_DIR) then MY_HD_DIR else "." end

disks_for_zfs = {
        :sata1 => {
                :dfile => hd_dir + '/sata1_zfs.vdi',
                :size => 1024,
                :port => 1
        },
        :sata2 => {
                :dfile => hd_dir + '/sata2_zfs.vdi',
                :size => 1024, # Megabytes
                :port => 2
        },
        :sata3 => {
                :dfile => hd_dir + '/sata3_zfs.vdi',
                :size => 1024,
                :port => 3
        },
        :sata4 => {
                :dfile => hd_dir + '/sata4_zfs.vdi',
                :size => 1024, # Megabytes
                :port => 4
        }
}

Vagrant.configure("2") do |config|

        config.vm.define "otuslinux" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "centos-7-zfs"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                        
                        needsController = false

                        disks_for_zfs.each do |dname, dconf|
                                unless File.exist?(dconf[:dfile])
                                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                        needsController =  true
                                end
                        end

                        if needsController == true
                        
                                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                        
                                disks_for_zfs.each do |dname, dconf|
                                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                                end
                        end
                end

                box.vm.provision "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
                yum install -y unzip
                yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
                gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
                yum-config-manager --enable zfs-kmod
                yum-config-manager --disable zfs
                yum install -y zfs
                /sbin/modprobe zfs
                SHELL
                
        end

end