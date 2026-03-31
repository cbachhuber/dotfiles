FROM ubuntu:24.04

RUN apt update && apt install -y git sudo

RUN useradd -ms /bin/bash testuser && echo "testuser:a" | chpasswd && adduser testuser sudo
USER testuser
WORKDIR /home/testuser
