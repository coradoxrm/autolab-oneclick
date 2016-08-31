echo "Uninstalling Autolab Project..."

docker rm -f $(docker ps -a)
docker rmi -f $(docker images -a)

rm -rf Autolab
rm -rf Tango
rm -rf db-data
rm -rf ssl

echo "Done."
