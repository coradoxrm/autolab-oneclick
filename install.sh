echo "[1/5]Installing docker and docker-compose"
sudo apt-get update && sudo apt-get install -y vim git curl
curl -sSL https://get.docker.com/ | sh

curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

echo "[2/5] Downloading source file..."
git clone https://github.com/autolab/Tango.git
git clone https://github.com/autolab/Autolab

echo "[3/5] Mounting volumes..."
mkdir Autolab/courses
sudo chown -R 9999:9999 Autolab/courses
mkdir db-data

echo "[4/5] Init docker images and containers..."
docker-compose up -d

sleep 10

echo "[5/5] Init database..."
docker-compose run --rm -e RAILS_ENV=production web rake db:create
docker-compose run --rm -e RAILS_ENV=production web rake db:migrate
docker-compose run --rm -e RAILS_ENV=production web rake db:seed

echo "[Autolab installation finished]\n Now you can use an admin account\n Username: admin@foo.bar\n password : 11111111\n to try Autolab for trail"


