#!/bin/bash

set -euxo pipefail

OS_NAME=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
readonly OS_NAME

readonly master_node=$(/usr/share/google/get_metadata_value attributes/dataproc-master)
readonly ROLE="$(/usr/share/google/get_metadata_value attributes/dataproc-role)"
readonly AUTO_DETECTED_ENVIRONMENT="$(/usr/share/google/get_metadata_value attributes/dataproc-cluster-name | egrep -o "dev|fat|prod")"
readonly USER_GROUP="$(/usr/share/google/get_metadata_value attributes/os-group)"
readonly USER_NAME="$(/usr/share/google/get_metadata_value attributes/os-user)"
readonly USER_HOME=/home/${USER_NAME}
readonly AUTHORIZED_KEYS_URL="$(/usr/share/google/get_metadata_value attributes/authorized_keys_url)"
readonly DEPLOY_BUCKET_URL="$(/usr/share/google/get_metadata_value attributes/deploy_bucket_url)"

function create_user_group() {
  echo "create_user_group"
  groupadd "$USER_GROUP"
}

function create_user_account() {
  echo "create_user_account ${USER_NAME}:${USER_GROUP} $USER_HOME "
  useradd -m "$USER_NAME" -g "$USER_GROUP" -d "${USER_HOME}"
  mkdir -p "${USER_HOME}"
  chown -R "${USER_NAME}:${USER_GROUP}" "$USER_HOME"
  chmod 700 "$USER_HOME"
}

function setup_ssh_key() {
  SSH_DIR=${USER_HOME}/.ssh
  echo "setup_ssh_key ${AUTHORIZED_KEYS_URL} to ${SSH_DIR}"
  mkdir -p ${SSH_DIR}
  gsutil cp ${AUTHORIZED_KEYS_URL} ${SSH_DIR}/authorized_keys
  chown -R "${USER_NAME}" "${SSH_DIR}"
  chmod 600 ${SSH_DIR}/authorized_keys
  chmod 700 "${SSH_DIR}"
  ls -al "${USER_HOME}"
  ls -al "${SSH_DIR}"
}

function deploy_trigger_tool() {
  local deploy_dir="/opt/deploy_bucket"
  mkdir -p "$deploy_dir"
  gsutil cp -r "${DEPLOY_BUCKET_URL}" "$deploy_dir/"
  if [ -n "${USER_NAME}" ]; then
    chown "$USER_NAME" "$deploy_dir"
  fi
  chmod 755 "$deploy_dir"
}

function main() {
  # Only run on the master node of the cluster
  if [[ "${ROLE}" == 'Master' ]]; then
    if [ -n "${USER_NAME}" ]; then	  
      create_user_group
      create_user_account
      if [ -n "{AUTHORIZED_KEYS_URL}" ]; then
        setup_ssh_key
      fi
    fi
    if [ -n "${DEPLOY_BUCKET_URL}" ]; then
      deploy_trigger_tool
    fi
  fi
}

main
