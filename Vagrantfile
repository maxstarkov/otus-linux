# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

        config.vagrant.plugins = "vagrant-reload"

        config.vm.define "zabbix" do |box|
      
                box.vm.box = "centos/7"
      
                box.vm.network "private_network", ip: "192.168.33.10"
      
                box.vm.provider "virtualbox" do |vb|
                        vb.memory = "4096"
                end
        
                box.vm.provision "shell", inline: <<-SHELL
                        yum install -y git
                        yum install -y yum-utils device-mapper-persistent-data lvm2
                        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                        yum install -y docker-ce docker-ce-cli containerd.io
                        usermod -aG docker vagrant
                        systemctl start docker
                        curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                        chmod +x /usr/local/bin/docker-compose
                SHELL

                box.vm.provision :reload

                box.vm.provision "shell", privileged: false, inline: <<-SHELL
                        git clone https://github.com/zabbix/zabbix-docker.git
                        cp /vagrant/docker-compose_centos_zabbix_mysql.yaml zabbix-docker/
                        sudo systemctl start docker
                        while [[ $(systemctl is-active docker) == "inactive" ]]; do sleep 10 ;done
                        docker-compose -f ./zabbix-docker/docker-compose_centos_zabbix_mysql.yaml up -d
                SHELL
      
        end
      
        config.vm.define "simple-host" do |box|
      
                box.vm.box = "centos/7"
      
                box.vm.network "private_network", ip: "192.168.33.11"
      
                box.vm.provider "virtualbox" do |vb|
                        vb.memory = "512"
                        vb.cpus = "1"
                end
        
                box.vm.provision "shell", inline: <<-SHELL
                        yum install -y epel-release
                        yum install -y python-pip
                        pip install py-zabbix
                        rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm
                        yum install -y zabbix-agent
                        sed -i 's/Server=127.0.0.1/Server=192.168.33.10/' /etc/zabbix/zabbix_agentd.conf
                        sed -i 's/ServerActive=127.0.0.1/ServerActive=192.168.33.10/' /etc/zabbix/zabbix_agentd.conf
                        systemctl start zabbix-agent
                SHELL
        
                box.vm.provision "shell", privileged: false, inline: <<-SHELL
                        cp /vagrant/add_host_to_zabbix.py .
                        python add_host_to_zabbix.py
                        cp /vagrant/cpu_load.sh .
                        chmod +x cpu_load.sh
                        (crontab -l 2>/dev/null; echo "*/1 * * * * /home/vagrant/cpu_load.sh") | crontab -
                SHELL
      
        end
      
      end
      