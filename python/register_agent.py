#!/usr/bin/env python3
"""Register an AI agent with the Idira Secure AI Gateway.

Usage:
    register_agent.py <name> <type> <spiffe-id>

Required environment variables:
    IDIRA_IDENTITY_URL   - base URL of Idira Identity (e.g. https://<tenant>.cyberark.cloud/api/idadmin)
    IDIRA_AIGW_URL        - base URL of the Secure AI Gateway API (e.g. https://<tenant>.aigw.cyberark.cloud/api)
    IDIRA_SERVICE_USER     - service user client id
    IDIRA_SERVICE_PASSWORD - service user client secret
"""
import argparse
import json
import os
import sys

import requests

AGENT_TYPES = ("CLAUDE", "COPILOT", "CUSTOM")


def parse_args():
    parser = argparse.ArgumentParser(description="Register an AI agent with Idira Secure AI Gateway.")
    parser.add_argument("name", help="Agent name")
    parser.add_argument("type", choices=AGENT_TYPES, help="Agent type")
    parser.add_argument("spiffe_id", help="SPIFFE ID, e.g. spiffe://trust-domain/workload-identifier")
    return parser.parse_args()


def require_env(name):
    value = os.environ.get(name)
    if not value:
        sys.exit(f"Missing required environment variable: {name}")
    return value


def authenticate(identity_url, service_user, service_password):
    resp = requests.post(
        f"{identity_url}/oauth2/platformtoken",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        data={
            "grant_type": "client_credentials",
            "client_id": service_user,
            "client_secret": service_password,
        },
    )
    if resp.status_code != 200:
        sys.exit(f"Failed to authenticate service user {service_user}: {resp.status_code} {resp.text}")
    return resp.json()["access_token"]


def register_agent(aigw_url, auth_token, name, agent_type, spiffe_id):
    payload = {
        "name": name,
        "type": agent_type,
        "description": "Agent registered through API.",
        "tags": {
            "spiffeId": spiffe_id,
            "autoOnboarded": "true",
        },
    }
    resp = requests.post(
        f"{aigw_url}/agents",
        headers={
            "Authorization": f"Bearer {auth_token}",
            "Content-Type": "application/json",
            "Accept": "application/x.agents.beta+json",
        },
        json=payload,
    )
    if resp.status_code != 201:
        sys.exit(f"Failed to register agent: {resp.status_code} {resp.text}")
    return resp.json()


def main():
    args = parse_args()

    identity_url = require_env("IDIRA_IDENTITY_URL").rstrip("/")
    aigw_url = require_env("IDIRA_AIGW_URL").rstrip("/")
    service_user = require_env("IDIRA_SERVICE_USER")
    service_password = require_env("IDIRA_SERVICE_PASSWORD")

    auth_token = authenticate(identity_url, service_user, service_password)
    agent = register_agent(aigw_url, auth_token, args.name, args.type, args.spiffe_id)
    print(json.dumps(agent, indent=2))


if __name__ == "__main__":
    main()
