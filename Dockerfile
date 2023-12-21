# Use the official Ubuntu base image
FROM ubuntu:latest

# Update the package lists, install dependencies, and generate locales
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y locales ssh wget unzip -y && \
    locale-gen en_US.UTF-8

# Set the default locale
ENV LANG en_US.UTF-8

# Set NGROK_TOKEN as a build argument and environment variable
ARG NGROK_TOKEN
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Download and install ngrok
RUN wget -O /ngrok.zip https://bin.equinox.io/c/${NGROK_TOKEN}/ngrok-stable-linux-amd64.zip && \
    unzip /ngrok.zip -d /usr/local/bin && \
    rm /ngrok.zip

# Create a startup script
RUN echo "/usr/local/bin/ngrok authtoken ${NGROK_TOKEN}" >> /kaal.sh && \
    echo "/usr/local/bin/ngrok tcp 22 &>/dev/null &" >> /kaal.sh && \
    chmod 755 /kaal.sh

# Configure SSH
RUN mkdir /run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo root:kaal | chpasswd && \
    service ssh start

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Set the default command to run the startup script
CMD ["/bin/bash", "/kaal.sh"]

