# ---- Fedora 43 Dockerfile for GitHub Desktop ----

FROM fedora:43

# ---- Build identity ----
ARG BUILD_USER=builder
ARG BUILD_UID=1000
ARG BUILD_GID=1000

# ---- Node version ----
ARG NODE_MAJOR=20

# ---- Environment variables ----
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    NODE_VERSION=$NODE_MAJOR

# ---- Install essential packages ----
RUN dnf upgrade -y && dnf install -y \
    git curl wget unzip tar gzip bzip2 xz sudo \
    make gcc gcc-c++ python3 python3-pip \
    rpm-build rpmdevtools rpmlint createrepo_c \
    ruby ruby-devel rubygems redhat-rpm-config \
    libsecret-devel pkg-config \
    libxcrypt-compat \
    libnotify libappindicator-gtk3 \
    libXtst nss \
    libffi-devel zlib-devel \
    openssl-devel readline-devel \
    glibc glibc-devel \
    xz bzip2 \
    nodejs npm yarn \
    which file xdg-utils \
    libsecret gnome-keyring libcurl-devel \
    && dnf clean all --enablerepo="*" || true

# ---- Install FPM (as root, before switching users) ----
RUN gem install --no-document fpm

# ---- Create build user ----
RUN groupadd -g $BUILD_GID $BUILD_USER && \
    useradd -m -u $BUILD_UID -g $BUILD_GID -s /bin/bash $BUILD_USER && \
    mkdir -p /home/$BUILD_USER/.cache && \
    chown -R $BUILD_UID:$BUILD_GID /home/$BUILD_USER

USER $BUILD_USER
WORKDIR /workspace

# ---- Setup Node environment ----
RUN mkdir -p /home/$BUILD_USER/.nvm
ENV NVM_DIR=/home/$BUILD_USER/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
ENV PATH=$NVM_DIR/versions/node/v$NODE_MAJOR/bin:$PATH

# ---- Prepare FPM / RPM build directories ----
RUN mkdir -p /tmp/package-rpm-build /tmp/fpm-tmp

# ---- Set default command ----
CMD ["/bin/bash"]