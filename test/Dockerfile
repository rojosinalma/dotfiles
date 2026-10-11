# Throwaway host for the dotfiles tests: Ubuntu 26.04, user rojo (uid 1000) with passwordless sudo.
FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends curl git sudo ca-certificates locales gnupg \
 && locale-gen en_US.UTF-8 \
 && (userdel -r ubuntu 2>/dev/null || true) \
 && useradd -m -u 1000 -s /bin/bash rojo \
 && echo 'rojo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/rojo \
 && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
USER rojo
WORKDIR /home/rojo
ENV PATH=/home/rojo/.local/bin:$PATH
RUN mkdir -p /home/rojo/.local/bin \
 && sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b /home/rojo/.local/bin
