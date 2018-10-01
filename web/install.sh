# Copy the nginx repo
cp nginx.repo /etc/yum.repos.d/

# Install the EPEL repo
yum -y install epel-release

# Install the packages needed
yum -y install net-tools bind-utils bash-completion wget git nginx sudo supervisor telnet

# Update the server and clean YUM
yum -y update && yum clean all && rm -rf /var/cache/yum

# Copy the supervisord configs
cp nginx.ini /etc/supervisord.d/

# Create the certficate directory
mkdir -p /etc/letsencrypt/live/hardeyhorlar.com

# Copy the certiticates
cp fullchain.pem /etc/letsencrypt/live/hardeyhorlar.com/
cp privkey.pem /etc/letsencrypt/live/hardeyhorlar.com/

# Copy the nginx website configuration file
cp foodtasker.conf /etc/nginx/conf.d/
