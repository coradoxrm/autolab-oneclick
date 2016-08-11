echo "copying config files into project files..."
cp configs/Tango/start.sh Tango/start.sh
cp configs/Tango/config.py Tango/config.py
cp configs/Autolab/autogradeConfig.rb Autolab/config/autogradeConfig.rb
cp configs/Autolab/devise.rb Autolab/config/initializers/devise.rb
cp configs/Autolab/nginx.conf Autolab/docker/nginx.conf
cp configs/Autolab/production.rb Autolab/config/environments/production.rb

echo "make volumes..."
mkdir Autolab/courses
sudo chown -R 9999:9999 Autolab/courses

echo "init docker images and containers..."
docker-compose up -d
