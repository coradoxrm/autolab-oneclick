echo "Uninstalling Autolab Project..."

echo "Wait..."
sudo rm -rf /var/lib/docker

sudo apt-get purge docker-engine
sudo apt-get autoremove --purge docker-engine
sudo apt-get autoclean

echo "Now you can delete the whole directory of Autolab-project"
