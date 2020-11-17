#!/bin/sh

propagateAWSEnvVarsAllLoginSessions() {
  AWS_ENV_VARS=$(env | grep 'AWS_\|ECS_')
  SET_AWS_ENV_VARS_SCRIPT=/etc/profile.d/set-aws-env-vars.sh
  echo > $SET_AWS_ENV_VARS_SCRIPT
  for VARIABLE in $AWS_ENV_VARS; do
    echo "export $VARIABLE" >> $SET_AWS_ENV_VARS_SCRIPT
  done
}

setUpSSH() {
  if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo 'Need your SSH public key as the SSH_PUBLIC_KEY environment variable.'
    exit 1
  fi
  echo root:$(cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c${1:-16}) | chpasswd 2> /dev/null
  ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ''
  USER_SSH_KEYS_FOLDER=~/.ssh
  [ -d "$USER_SSH_KEYS_FOLDER" ] || mkdir -p $USER_SSH_KEYS_FOLDER
  echo $SSH_PUBLIC_KEY > ${USER_SSH_KEYS_FOLDER}/authorized_keys
  unset SSH_PUBLIC_KEY
  env | grep -E '^(AWS|ECS)_' >> ${USER_SSH_KEYS_FOLDER}/environment
  echo PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> ${USER_SSH_KEYS_FOLDER}/environment
  /usr/sbin/sshd -Def /root/sshd_config
}

propagateAWSEnvVarsAllLoginSessions
setUpSSH