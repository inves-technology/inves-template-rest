FROM node:iron-alpine
# PROJECT arg to be passed in from docker-compose and/or .env file
ARG PROJECT=unnamedProject
ARG HASHICORP_PRODUCT=terraform 
ARG TERRAFORM_VERSION=1.7.2

# Base Development Packages
RUN apk update
RUN apk upgrade
RUN apk add ca-certificates wget && update-ca-certificates
RUN apk add --update --no-cache \
  git \
  curl \
  openssh \
  bash \
  groff \
  less \
  make \
  ncurses \
  vim \
  nano \
  rsync \
  xterm \
  zip \
  gnupg \
  aws-cli 

RUN apk add --update --virtual .deps --no-cache gnupg && \
  cd /tmp && \
  wget https://releases.hashicorp.com/${HASHICORP_PRODUCT}/${TERRAFORM_VERSION}/${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip && \
  wget https://releases.hashicorp.com/${HASHICORP_PRODUCT}/${TERRAFORM_VERSION}/${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS && \
  wget https://releases.hashicorp.com/${HASHICORP_PRODUCT}/${TERRAFORM_VERSION}/${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
  wget -qO- https://www.hashicorp.com/.well-known/pgp-key.txt | gpg --import && \
  gpg --verify ${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS.sig ${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS && \
  grep ${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip ${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c && \
  unzip /tmp/${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip -d /tmp && \
  mv /tmp/${HASHICORP_PRODUCT} /usr/local/bin/${HASHICORP_PRODUCT} && \
  rm -f /tmp/${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_linux_amd64.zip ${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS ${TERRAFORM_VERSION}/${HASHICORP_PRODUCT}_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
  apk del .deps

ENV TERM xterm-256color

# Ceanup
RUN rm /var/cache/apk/*

RUN mkdir -p /${PROJECT}
RUN mkdir -p /${PROJECT}/source
RUN mkdir -p /${PROJECT}/source/node_modules
COPY package.json yarn.lock /${PROJECT}/source/
WORKDIR /${PROJECT}/source

# NPM and Yarn Installs
RUN corepack enable 
RUN yarn 

# Slightly more boring Docker Prompt (doesn't need ncurses anymore, and multi-line seems to be fixed)
RUN printf 'export PS1="\[\e[30;48;5;68m\] [DOCKER] \[\e[0m\] \\t \[\e[40;38;5;28m\][\w]\[\e[0m\] \$ "' >> ~/.bashrc


