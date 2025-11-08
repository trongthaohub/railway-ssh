FROM ubuntu:22.04

# Install OpenSSH Server + Ngrok
RUN apt update && apt install -y openssh-server curl wget unzip sudo python3 && \
    mkdir /var/run/sshd

# Create user 'user' with sudo
RUN useradd -m user && echo "user:password" | chpasswd && adduser user sudo

# Configure SSH
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveInterval 60' >> /etc/ssh/sshd_config && \
    echo 'ClientAliveCountMax 3' >> /etc/ssh/sshd_config

# Download Ngrok v3
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && \
    tar -xzf ngrok-v3-stable-linux-amd64.tgz && mv ngrok /usr/local/bin/

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports
EXPOSE 8080   # Web server dummy (Railway keep-alive)
EXPOSE 22     # SSH
EXPOSE 14489 888 80 443 20 21  # Optional for aaPanel or FTP if needed

CMD ["/start.sh"]
