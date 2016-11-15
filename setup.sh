#!/bin/sh
# Installation script of Sickrage and CouchPotato
echo "Updating package list"
sudo apt-get --yes --force-yes update
echo "Installing osmc apps:"
echo "-cron"
echo "-mediainfo"
echo "-smb"
echo "-transmission"
sudo apt-get install --yes --force-yes armv7-transmission-app-osmc cron-app-osmc mediainfo-app-osmc smb-app-osmc
echo "osmc apps installed"
echo " "
echo "Installing git"
sudo apt-get install --yes --force-yes git
echo "git installed"
echo " "
echo "Installing p7ip"
sudo apt-get install --yes --force-yes p7zip-full
echo "p7zip installed"
echo " "
echo "Installing Unrar"
sudo wget http://sourceforge.net/projects/bananapi/files/unrar_5.2.6-1_armhf.deb
sudo dpkg -i unrar_5.2.6-1_armhf.deb
sudo rm  unrar_5.2.6-1_armhf.deb
echo "Unrar installed"
echo " "
echo "Installing rsync"
sudo apt-get install rsync --yes --force-yes rsync
echo "rsync installed"
echo " "
echo "Cloning CouchPotato to /opt/CouchPotatoServer"
sudo git clone http://github.com/RuudBurger/CouchPotatoServer /opt/CouchPotatoServer
echo "Successfully cloned"
echo "Changing owner on /opt/CouchPotatoServer to osmc:osmc"
sudo chown -R osmc:osmc /opt/CouchPotatoServer
echo "Copying the systemd file, inserting process timeout and modifying it to run as osmc user"
sudo cp /opt/CouchPotatoServer/init/couchpotato.service /etc/systemd/system/couchpotato.service
sudo sed -i '12i TimeoutStopSec=5s' /etc/systemd/system/couchpotato.service
sudo sed -i 's@/var/lib/CouchPotatoServer/CouchPotato.py@/opt/CouchPotatoServer/CouchPotato.py@g' /etc/systemd/system/couchpotato.service
sudo sed -i.bak 's/=couchpotato/=osmc/g' /etc/systemd/system/couchpotato.service
echo "Enabling couchpotato service to run at startup"
sudo systemctl enable couchpotato.service
echo "CouchPotato now setup!!"
echo " "
echo "Cloning sickrage to /opt/sickrage"
sudo git clone https://github.com/SiCKRAGE/SickRage.git /opt/sickrage
echo "Changing owner on /opt/sickrage to osmc:osmc"
sudo chown -R osmc:osmc /opt/sickrage
echo "Copying the systemd file, making it executable, inserting process timeout and modifying it to run as osmc user"
sudo cp /opt/sickrage/runscripts/init.systemd /etc/systemd/system/sickrage.service
sudo chmod +x /opt/sickrage
sudo chmod a-x /etc/systemd/system/sickrage.service
sudo sed -i 's/=sickrage/=osmc/g' /etc/systemd/system/sickrage.service
sudo sed -i '55i TimeoutStopSec=5s' /etc/systemd/system/sickrage.service
sudo sed -i 's@/usr/bin/python2.7 /opt/sickrage/SickBeard.py -q --daemon --nolaunch --datadir=/opt/sickrage@/opt/sickrage/SickBeard.py -q --daemon --nolaunch --datadir=/opt/sickrage@g' /etc/systemd/system/sickrage.service
echo "Running sickrage momentarily to create the config file"
sudo systemctl enable sickrage.service
sudo systemctl start sickrage.service
sudo service sickrage stop
echo "Config file now created, adding in user / password to prevent possible crash"
sudo sed -i 's@web_username = ""@web_username = "osmc"@g' /opt/sickrage/config.ini
sudo sed -i 's@web_password = ""@web_password = "osmc"@g' /opt/sickrage/config.ini
sudo service couchpotato stop
sudo service transmission stop
sudo reboot
