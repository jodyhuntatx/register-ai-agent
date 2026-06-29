#!/bin/bash
TENANT_SUBDOMAIN_ID=tiger-prod
export IDIRA_IDENTITY_URL="https://${TENANT_SUBDOMAIN_ID}.cyberark.cloud/api/idadmin"
export IDIRA_AIGW_URL="https://${TENANT_SUBDOMAIN_ID}.aigw.cyberark.cloud/api"
export IDIRA_SERVICE_USER="secaibot@tiger.com"
export IDIRA_SERVICE_PASSWORD=$(keyring get cybrid tigerbotpwd)

export AGENT_NAME="test-agent-1"
export AGENT_TYPE="COPILOT"
export SPIFFE_ID="spiffe://tiger.com/test-agent"
uv run register_agent.py $AGENT_NAME $AGENT_TYPE $SPIFFE_ID
