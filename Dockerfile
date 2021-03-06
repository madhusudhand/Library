# Build:
# docker build -t rahul-libtest .
#
# Run:
# docker run -it rahul-libtest
#
# Compose:
# docker-compose up -d

FROM ubuntu:latest
MAINTAINER Rahul Raviprasad

# 80 = HTTP, 443 = HTTPS, 3000 = MEAN.JS server, 35729 = livereload, 8080 = node-inspector
EXPOSE 80 443 3000 35730 8080

# Set development environment as default
ENV NODE_ENV development

# Install Utilities
RUN apt-get update   \
 && apt-get install -y curl \
 wget \
 aptitude \
 htop \
 vim \
 git \
 traceroute \
 dnsutils \
 curl \
 ssh \
 sudo \
 apt-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN sudo apt-get install -y nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Prerequisites
RUN npm install -g gulp bower yo mocha karma-cli pm2 && npm cache clean

RUN mkdir -p /opt/mean.js/public/lib
WORKDIR /opt/mean.js

# Copies the local package.json file to the container
# and utilities docker container cache to not needing to rebuild
# and install node_modules/ everytime we build the docker, but only
# when the local package.json file changes.
# Install npm packages
COPY package.json /opt/mean.js/package.json
RUN npm install --quiet && npm cache clean
RUN npm install -g grunt

# Install bower packages
COPY bower.json /opt/mean.js/bower.json
COPY .bowerrc /opt/mean.js/.bowerrc
RUN bower install --quiet --allow-root --config.interactive=false

COPY . /opt/mean.js

# Run MEAN.JS server
CMD ["npm", "start"]
