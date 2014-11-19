# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Script to install build deps and the WFDB library
$script = <<SCRIPT
#ENVIRONMENT CONFIGURATION
echo Beginning environment config/install
apt-get update
apt-get install -y build-essential  #req'd for compiling c
apt-get install -y libcurl4-openssl-dev libexpat1-dev #req'd by wfdb

apt-get install -y python3 python3-dev python3-pip
pip3 install -r /vagrant/requirements.txt
echo Environment configuration successful

#BUILD THE WFDB LIBRARY
echo Beginning install of wfdb library
wget http://physionet.org/physiotools/wfdb.tar.gz
tar xfvz wfdb.tar.gz
rm wfdb.tar.gz
cd wfdb-10.5.23
./configure
make install
make check
cd ..
rm -rf wfdb-10.5.23
echo WFDB install success

#BUILD THE MODULE
##TODO
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Use Ubuntu 14.04 for box
  config.vm.box = "ubuntu/trusty64"

  # Use this to bring up the Virtualbox GUI (useful for debugging)
  #config.vm.provider "virtualbox" do |vb|
  #  vb.gui = true
  #end

  # Expose guest port 80 as localhost:8080
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Install software deps on the machine
  config.vm.provision :shell, inline: $script
end
