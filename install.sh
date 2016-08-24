echo "downloading source file..."
git clone https://github.com/autolab/Tango.git
git clone https://github.com/autolab/Autolab

echo "copying config files into project files..."
cp configs/Tango/start.sh Tango/start.sh
cp configs/Tango/config.py Tango/config.py
cp configs/Autolab/autogradeConfig.rb Autolab/config/autogradeConfig.rb
cp configs/Autolab/devise.rb Autolab/config/initializers/devise.rb
cp configs/Autolab/nginx.conf Autolab/docker/nginx.conf
cp configs/Autolab/production.rb Autolab/config/environments/production.rb
cp configs/Autolab/Dockerfile Autolab/Dockerfile
cp configs/Autolab/seeds.rb Autolab/db/seeds.rb

echo "make volumes..."
mkdir Autolab/courses
sudo chown -R 9999:9999 Autolab/courses

echo "init docker images and containers..."
docker-compose up -d

sleep 10

echo "init database..."
docker-compose run --rm -e RAILS_ENV=production web rake db:create
docker-compose run --rm -e RAILS_ENV=production web rake db:migrate
docker-compose run --rm -e RAILS_ENV=production web rake db:seed

echo "now you can use an admin account\n Username: admin@foo.bar\n password : 11111111\n to try Autolab for trail"


