FROM ruby:3.3.5-bookworm

ENV DEBIAN_FRONTED=noninteractive

RUN apt-get update && \
  apt-get install -y \
    git \
    vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser --disabled-password --gecos '' devel \
  && usermod -a -G sudo devel \
  && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
  && echo 'devel:devel' | chpasswd

ENV HOME=/home/devel
ENV APP=/var/www/app
ENV BUNDLE_PATH=${APP}/.bundle
ENV GEM_HOME=${BUNDLE_PATH}
ENV PATH=${PATH}:${BUNDLE_PATH}/bin

RUN mkdir -p ${HOME} && \
  chown -R devel:devel ${HOME} && \
  mkdir -p ${APP} && \
  chown -R devel:devel ${APP} && \
  mkdir -p ${BUNDLE_PATH} && \
  chown -R devel:devel ${BUNDLE_PATH}

USER devel:devel

WORKDIR $APP

# Install nodejs
ENV NVM_DIR=/home/devel/.nvm
ENV NVM_VERSION=0.40.1
ENV NODE_VERSION=22.11.0
ENV PNPM_HOME=/home/devel/.pnpm
ENV PNPM_VERSION=9.14.2
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash \
  && . ~/.nvm/nvm.sh \
  && nvm install ${NODE_VERSION} \
  && nvm alias default ${NODE_VERSION} \
  && nvm use default \
  && curl -fsSL https://get.pnpm.io/install.sh | bash -
ENV NODE_PATH=${NVM_DIR}/versions/node/v${NODE_VERSION}/lib/node_modules
ENV PATH=${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PNPM_HOME}:${PATH}
