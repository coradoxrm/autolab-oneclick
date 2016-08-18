echo "[1/4] Downloading source file..."
git clone https://github.com/autolab/Tango.git
git clone https://github.com/autolab/Autolab

echo "[2/4] Mounting volumes..."
mkdir Autolab/courses
sudo chown -R 9999:9999 Autolab/courses
mkdir db-data

echo "[3/4] Init docker images and containers..."
docker-compose up -d

sleep 10

echo "[4/4] Init database..."
docker-compose run --rm -e RAILS_ENV=production web rake db:create
docker-compose run --rm -e RAILS_ENV=production web rake db:migrate
docker-compose run --rm -e RAILS_ENV=production web rake db:seed

echo "[Autolab installation finished]\n Now you can use an admin account\n Username: admin@foo.bar\n password : 11111111\n to try Autolab for trail"


