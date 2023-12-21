FROM ubuntu:latest

RUN apt-get update -y > /dev/null 2>&1 && apt-get upgrade -y > /dev/null 2>&1 && apt-get install -y locales ssh wget unzip -y > /dev/null 2>&1 && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

RUN wget -O /ngrok.zip https://bin.equinox.io/c/your-ngrok-token/ngrok-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip /ngrok.zip -d /usr/local/bin > /dev/null 2>&1

RUN echo "/usr/local/bin/ngrok authtoken ${NGROK_TOKEN}" >> /kaal.sh
RUN echo "/usr/local/bin/ngrok tcp 22 &>/dev/null &" >> /kaal.sh

RUN mkdir /run/sshd
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:kaal | chpasswd
RUN service ssh start

RUN chmod 755 /kaal.sh

EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

CMD ["/bin/bash", "/kaal.sh"]
