# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
	}
}

Vagrant.configure("2") do |config|

	config.vbguest.auto_update = false

	MACHINES.each do |boxname, boxconfig|

      		config.vm.define boxname do |box|

          	box.vm.box = boxconfig[:box_name]
          	box.vm.host_name = boxname.to_s

          	box.vm.network "private_network", ip: boxconfig[:ip_addr]

          	box.vm.provider :virtualbox do |vb|
          		vb.customize ["modifyvm", :id, "--memory", "1024"]
          	end

 	  	box.vm.provision "shell", inline: <<-SHELL
	      		mkdir -p ~root/.ssh
              		cp ~vagrant/.ssh/auth* ~root/.ssh
	      		yum install -y git rpmdevtools rpm-build createrepo
  	  		SHELL
			
		box.vm.provision "shell", path: "create_rpm_package.sh"
		box.vm.provision "shell", path: "create_rpm_repo.sh"

		box.vm.synced_folder ".", "/vagrant", disabled: true

		end
	end
end
