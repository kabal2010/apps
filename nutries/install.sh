# Install the EPEL repo
yum -y install epel-release

# Add the repo for postgres
rpm -Uvh https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

# Copy the nginx repo
cp nginx.repo /etc/yum.repos.d/

# Install the packages needed
yum -y install net-tools bind-utils bash-completion wget git nginx python34 python34-pip python34-virtualenv postgresql10 postgresql10-server postgresql10-contrib sudo supervisor nginx telnet

# Update the server and clean YUM
yum -y update && yum clean all && rm -rf /var/cache/yum

# Initialize the postgres database server
sudo -u postgres /usr/pgsql-10/bin/initdb /var/lib/pgsql/10/data/

# Start the postgres database server
sudo -u postgres /usr/pgsql-10/bin/pg_ctl start -D /var/lib/pgsql/10/data/ -w -t 300

# Create the application database
sudo -u postgres /usr/pgsql-10/bin/psql -c "CREATE DATABASE nutries;"

# Create the application user
sudo -u postgres /usr/pgsql-10/bin/psql -c "CREATE USER nutries WITH PASSWORD 'classics6^';"

# Grant all on the application database to the application user
sudo -u postgres /usr/pgsql-10/bin/psql -c "GRANT ALL ON DATABASE nutries TO nutries;"

# Create a project folder
mkdir /apps

# Clone the application GIT repo
git clone https://github.com/slpy/Nutries /apps/nutries

# Clean-up unneeded files and directories
rm -rf /apps/nutries/bin /apps/nutries/env /apps/nutries/include /apps/nutries/testenv /apps/nutries/pip-selfcheck.json /apps/nutries/static && rm -rf /apps/nutries/lib64

# Create the virtual environment
virtualenv-3.4 /apps/nutries/virtenv

# Source into the environment
source /apps/nutries/virtenv/bin/activate

# Upgrade pip
pip3.4 install --upgrade pip

# Install the application requirements into the virtual environment
pip3.4 install -r /apps/nutries/requirements.txt && pip3.4 install djangorestframework==3.5.2

# Perform the application configurations
/apps/nutries/manage.py makemigrations
/apps/nutries/manage.py migrate
/apps/nutries/manage.py collectstatic --noinput
/apps/nutries/manage.py createsuperuser --noinput --username 'admin' --email 'nutries83@gmail.com'

# Stop the postgres database server
sudo -u postgres /usr/pgsql-10/bin/pg_ctl stop -D /var/lib/pgsql/10/data/

# Copy the supervisord configs
cp nginx.ini postgresql.ini nutries.ini /etc/supervisord.d/

# Create the certficate directory
mkdir -p /etc/letsencrypt/live/hardeyhorlar.com

# Copy the certiticates
cp fullchain.pem /etc/letsencrypt/live/hardeyhorlar.com/
cp privkey.pem /etc/letsencrypt/live/hardeyhorlar.com/

# Copy the nginx website configuration file
cp foodtasker.conf /etc/nginx/conf.d/
