FROM ubuntu:latest

# Update and install dependencies
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 \
 && apt install locales ssh wget unzip -y > /dev/null 2>&1 \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Set environment variables
ENV LANG en_US.utf8
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Install ngrok for tunneling and setup SSH service
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1 \
 && unzip ngrok.zip \
 && echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" > /kaal.sh \
 && echo "./ngrok tcp 22 &>/dev/null &" >> /kaal.sh \
 && mkdir /run/sshd \
 && echo '/usr/sbin/sshd -D &' >> /kaal.sh

# Configure SSH
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
 && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
 && echo 'root:kaal' | chpasswd

# Set proper permissions for the script and start SSH service in it
RUN chmod 755 /kaal.sh \
 && service ssh start

# Expose ngrok's web interface port, and other ports which can be used for tunneling
EXPOSE 4040 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Set the default command to run the script
CMD ["/bin/sh", "/kaal.sh"]
