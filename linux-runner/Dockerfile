# Set the images
FROM registry.access.redhat.com/ubi9:latest

# Set all the needed ENV
ENV Token="" Repository="" Name="" Labels=""

# Copy all the needed scripts
COPY linux.sh /tmp

# Configure the image
RUN cd /tmp && chmod +x linux.sh && ./linux.sh

# Set the user
USER github

# Set the workdir
WORKDIR /home/github

# Copy the entrypoint
COPY --chown=github:github entrypoint.sh /home/github/

# Make it executable
RUN chmod +x /home/github/entrypoint.sh

# Expose nginx port
EXPOSE 8080/tcp

# Set the extrypoint for the docker image
ENTRYPOINT ["/home/github/entrypoint.sh"]
