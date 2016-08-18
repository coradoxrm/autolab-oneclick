echo "downloading source file..."
git clone https://github.com/autolab/Tango.git
git clone https://github.com/autolab/Autolab

echo "make volumes..."
mkdir Autolab/courses
sudo chown -R 9999:9999 Autolab/courses
mkdir db-data

echo "init docker images and containers..."
docker-compose up -d

wait

echo "init database..."
docker-compose run --rm -e RAILS_ENV=production web rake db:create
docker-compose run --rm -e RAILS_ENV=production web rake db:migrate
docker-compose run --rm -e RAILS_ENV=production web rake db:seed

echo "now you can use an admin account\n Username: admin@foo.bar\n password : 11111111\n to try Autolab for trail"


