TENANT_SUBDOMAIN_ID=tiger-prod
export CYBERARK_IDENTITY_URL="https://${TENANT_SUBDOMAIN_ID}.cyberark.cloud/api/idadmin"
export CYBERARK_AIGW_URL="https://${TENANT_SUBDOMAIN_ID}.aigw.cyberark.cloud/api"
export CYBERARK_ADMIN_USER="adminbot@tiger.com"
export CYBERARK_ADMIN_PWD="$(keyring get cybrid tigerbotpwd)"
