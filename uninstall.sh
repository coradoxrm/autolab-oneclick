echo "Uninstalling Autolab Project..."

echo "Wait..."
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)

echo "Now you can delete the whole directory of Autolab-project"
