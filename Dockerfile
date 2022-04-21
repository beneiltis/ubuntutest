# CREATED WITH THE HELP OF THIS AWSOME EXAMPLE: https://www.golinuxcloud.com/run-sshd-as-non-root-user-without-sudo/
FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y openssh-server

RUN mkdir /opt/ssh
RUN ssh-keygen -q -N "" -t dsa -f /opt/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -b 4096 -f /opt/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t ecdsa -f /opt/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -q -N "" -t ed25519 -f /opt/ssh/ssh_host_ed25519_key

RUN cp /etc/ssh/sshd_config /opt/ssh/

RUN sed -i 's/#UsePAM yes/UsePAM yes/g' /opt/ssh/sshd_config
RUN sed -i 's/#Port 22/Port 1337/g' /opt/ssh/sshd_config
RUN sed -i 's|#HostKey /etc/ssh/ssh_host_rsa_key|HostKey /opt/ssh/ssh_host_rsa_key|g' /opt/ssh/sshd_config
RUN sed -i 's|#HostKey /etc/ssh/ssh_host_ecdsa_key|HostKey /opt/ssh/ssh_host_ecdsa_key|g' /opt/ssh/sshd_config
RUN sed -i 's|#HostKey /etc/ssh/ssh_host_ed25519_key|HostKey /opt/ssh/ssh_host_ed25519_key|g' /opt/ssh/sshd_config
#RUN sed -i 's|#LogLevel INFO|LogLevel DEBUG3|g' /opt/ssh/sshd_config
RUN sed -i 's|#PidFile /var/run/sshd.pid|PidFile /opt/ssh/sshd.pid|g' /opt/ssh/sshd_config

RUN useradd --user-group --create-home --system mogenius
RUN echo "mogenius:test1234"|chpasswd

RUN chmod 600 /opt/ssh/*
RUN chmod 644 /opt/ssh/sshd_config
RUN chown -R 999:999 /opt/ssh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 1337

USER 999

CMD /usr/sbin/sshd -f /opt/ssh/sshd_config -e -D
