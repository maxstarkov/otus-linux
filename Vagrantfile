# -*- mode: ruby -*-
# vim: set ft=ruby :

if Vagrant::Util::Platform.windows?
        MY_HD_DIR = "D:\\VM\\hd"
else
        MY_HD_DIR = "/mnt/vbvm/hd"
end

hd_dir = if File.directory?(MY_HD_DIR) then MY_HD_DIR else "." end

disk_for_lvm = {
        :sata1 => {
                :dfile => hd_dir + '/sata1_lvm.vdi',
                :size => 10240,
                :port => 1
        },
        :sata2 => {
                :dfile => hd_dir + '/sata2_lvm.vdi',
                :size => 2048, # Megabytes
                :port => 2
        },
        :sata3 => {
                :dfile => hd_dir + '/sata3_lvm.vdi',
                :size => 1024,
                :port => 3
        },
        :sata4 => {
                :dfile => hd_dir + '/sata4_lvm.vdi',
                :size => 1024, # Megabytes
                :port => 4
        }
}

Vagrant.configure("2") do |config|

        config.vbguest.auto_update = false

        config.vm.box_version = "1804.02"

        config.vm.define "otuslinux-lvm" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "centos-7-lvm"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                        
                        needsController = false

                        disk_for_lvm.each do |dname, dconf|
                                unless File.exist?(dconf[:dfile])
                                        vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                        needsController =  true
                                end
                        end

                        if needsController == true
                        
                                vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                        
                                disk_for_lvm.each do |dname, dconf|
                                        vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                                end
                        end
                end

                box.vm.provision "shell", inline: <<-SHELL
                mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
                yum install -y mdadm smartmontools hdparm gdisk xfsdump
                SHELL

                box.vm.provision "copy_root", run: "never", type: "shell", path: "copy_root.sh"
                box.vm.provision "resize_root", run: "never", type: "shell", path: "resize_root.sh"
                box.vm.provision "restore_root", run: "never", type: "shell", path: "restore_root.sh"
                box.vm.provision "move_var_dir", run: "never", type: "shell", path: "move_var_dir.sh"
                box.vm.provision "move_home_dir", run: "never", type: "shell", path: "move_home_dir.sh"
                box.vm.provision "remove_temp_vg", run: "never", type: "shell", path: "remove_temp_vg.sh"
                
                box.vm.synced_folder ".", "/vagrant", disabled: true
                
        end
end

