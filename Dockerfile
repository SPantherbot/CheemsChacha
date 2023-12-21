
FROM alpine:latest

# Update and install dependencies
RUN apk --no-cache add openssh wget unzip python3

# Set environment variables
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Install ngrok for tunneling and setup SSH service
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip \
 && unzip ngrok.zip \
 && echo "./ngrok config add-authtoken ${NGROK_TOKEN} && ./ngrok tcp 22 &>/dev/null &" > /kaal.sh \
 && mkdir /run/sshd \
 && echo '/usr/sbin/sshd -D &' >> /kaal.sh \
 && chmod 755 /kaal.sh

# Configure SSH
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
 && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
 && echo 'root:kaal' | chpasswd

# Set proper permissions for the script and start SSH service in it
RUN service ssh start

# Set up a basic HTTP server (for health check)
CMD ["/bin/sh", "-c", "/kaal.sh && python3 -m http.server 80"]
