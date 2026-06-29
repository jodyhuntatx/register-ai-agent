# register-ai-agent

Registers an AI agent with the Idira Secure AI Gateway.

`register_agent.py` authenticates to Idira Identity as a service user and registers the agent with the Secure AI Gateway.

The service user must have the following Idira Identity roles:
- Secure AI Admins

## Install

This project uses [uv](https://docs.astral.sh/uv/) for dependency management.

```bash
uv sync
```

## Configure

Set the following environment variables before running the script:

| Variable                 | Description                                                              |
|---------------------------|---------------------------------------------------------------------------|
| `IDIRA_IDENTITY_URL`      | Base URL of Idira Identity, e.g. `https://<tenant>.cyberark.cloud/api/idadmin` |
| `IDIRA_AIGW_URL`          | Base URL of the Secure AI Gateway API, e.g. `https://<tenant>.aigw.cyberark.cloud/api` |
| `IDIRA_SERVICE_USER`      | Service user client ID used to authenticate                              |
| `IDIRA_SERVICE_PASSWORD`  | Service user client secret/password                                      |

Example, as in [test.sh](test.sh):

```bash
TENANT_SUBDOMAIN_ID=tiger-prod
export IDIRA_IDENTITY_URL="https://${TENANT_SUBDOMAIN_ID}.cyberark.cloud/api/idadmin"
export IDIRA_AIGW_URL="https://${TENANT_SUBDOMAIN_ID}.aigw.cyberark.cloud/api"
export IDIRA_SERVICE_USER="secaibot@tiger.com"
export IDIRA_SERVICE_PASSWORD=$(keyring get cybrid tigerbotpwd)
```

`keyring` is used here to avoid storing the service user's password in plain
text; any way of populating `IDIRA_SERVICE_PASSWORD` works.

## Usage

```bash
uv run register_agent.py <name> <type> <owner> <spiffe-id>
```

Arguments:

- `name` - agent name
- `type` - one of `CLAUDE`, `COPILOT`, `CUSTOM`
- `spiffe-id` - SPIFFE ID in the form `spiffe://trust-domain/workload-identifier`

Example, as in [test.sh](test.sh):

```bash
export AGENT_NAME="test-agent-1"
export AGENT_TYPE="CLAUDE"
export SPIFFE_ID="spiffe://tiger.com/test-agent"
uv run register_agent.py $AGENT_NAME $AGENT_TYPE $AGENT_OWNER $SPIFFE_ID
```

On success, the script prints the JSON record returned by the Secure AI
Gateway for the newly registered agent. On failure (authentication error,
owner not found, or registration error), it prints a message to stderr and
exits with a non-zero status.

## Run the test script

```bash
./test.sh
```
