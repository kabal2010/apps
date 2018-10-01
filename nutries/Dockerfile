# Set the base image
FROM centos:latest

# Set the maintainer
LABEL maintainer="Adeola David<ad_eolaa11@yahoo.com>"

# Add the current directory
ADD . /config

# Set the directory to the workdir
WORKDIR /config

# Execute the install script
RUN ./install.sh

# Set the work directory to the app dir
WORKDIR /apps/nutries

# Set the command to run at start
ENTRYPOINT ["sh", "/config/init.sh", "/bin/bash"]
