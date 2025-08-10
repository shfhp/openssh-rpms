#!/bin/bash
script_dir=$(cd "$(dirname "$0")" && pwd)
cd "${script_dir}" || exit 1
LOG_FILE=${script_dir}/install.log

echo "1. Install openssh package ..." | tee -a "${LOG_FILE}"
yum localinstall openssh-*.rpm -y | tee -a "${LOG_FILE}"

echo "2. Modify ssh host key permissions ..." | tee -a "${LOG_FILE}"
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub
chown root:root /etc/ssh/ssh_host_*_key
chown root:root /etc/ssh/ssh_host_*_key.pub

echo "3. Restart sshd service ..." | tee -a "${LOG_FILE}"
service sshd restart | tee -a "${LOG_FILE}"
service sshd status | tee -a "${LOG_FILE}"