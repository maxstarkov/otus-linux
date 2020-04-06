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
                yum install -y yum-utils device-mapper-persistent-data lvm2
                yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io
                systemctl start docker
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                groupadd admin
                useradd johndoe -G admin
                echo "Otus2020" | passwd --stdin johndoe
                useradd janedoe
                echo "Otus2020" | passwd --stdin janedoe
                sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
                systemctl restart sshd.service
                cp /vagrant/admin_group_login.sh /usr/local/bin
                chmod +x /usr/local/bin/admin_group_login.sh
                sed -i 's/pam_nologin.so/pam_nologin.so\\nADD_CONFIG/' /etc/pam.d/sshd
                sed -i 's|ADD_CONFIG|account    required     pam_exec.so /usr/local/bin/admin_group_login.sh|' /etc/pam.d/sshd
                usermod -aG docker vagrant
                echo "johndoe ALL= NOPASSWD: /bin/systemctl restart docker" > /etc/sudoers.d/johndoe
                SHELL
        
        end
      
end