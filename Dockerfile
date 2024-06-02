FROM ubuntu:latest
RUN apt update && apt install  openssh-server sudo -y
RUN useradd -rm -d /home/bwoo -s /bin/bash -g root -G sudo -u 1001 bwoo 
RUN echo 'bwoo:password' | chpasswd
RUN service ssh start
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
