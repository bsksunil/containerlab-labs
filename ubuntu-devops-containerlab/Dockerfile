FROM ubuntu:22.04

# Avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python, Ansible, and Terraform in one layer
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        software-properties-common \
        wget \
        unzip && \
    # Install Ansible from PPA
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible && \
    # Install Terraform (detect architecture)
    ARCH=$(dpkg --print-architecture) && \
    wget -q https://releases.hashicorp.com/terraform/1.13.5/terraform_1.13.5_linux_${ARCH}.zip -O /tmp/terraform.zip && \
    unzip -q /tmp/terraform.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    rm /tmp/terraform.zip && \
    # Install Python libraries
    pip3 install --no-cache-dir numpy pandas netmiko && \
    # Clean up to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Keep container running
CMD ["bash", "-c", "sleep infinity"]
