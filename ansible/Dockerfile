
# This is a test ubuntu docker image with systemd and ssh installed to test ansible playbooks. This image is available at kunalvirwal/systemd-ssh. 
#
# Note: This container requires system-level access to manage services via systemd and thus requires the host's cgroup namespace.
#       Before running the tailscale setup ansible make sure to mannually ssh into the container to properly set your ~/.ssh/known_hosts.
#       Also add the container's IP into the tailnet group of ansible hosts file.
#
# docker run -d --name ansible-systemd --privileged --cgroupns=host -v /sys/fs/cgroup:/sys/fs/cgroup:rw --tmpfs /run --tmpfs /tmp -p 2222:22 kunalvirwal/systemd-ssh:latest
#

FROM jrei/systemd-ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd 
    
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN systemctl enable ssh



