from secure_ai_api_client import AuthenticatedClient
from secure_ai_api_client.api.agents.list_agents import sync_detailed
from secure_ai_api_client.models import Agent
from secure_ai_api_client.models.agent_status_agent_status_value import AgentStatusAgentStatusValue
from secure_ai_api_client.types import Response

import requests
import json
import base64
import os, sys

# Get environment variables
CYBERARK_IDENTITY_URL = os.environ['CYBERARK_IDENTITY_URL']
CYBERARK_SAI_URL = os.environ['CYBERARK_SAI_URL']
CYBERARK_ADMIN_USER = os.environ['CYBERARK_ADMIN_USER']
CYBERARK_ADMIN_PWD = os.environ['CYBERARK_ADMIN_PWD']

# First request: Get JWT token from CyberArk Identity
response = requests.post(
    f"{CYBERARK_IDENTITY_URL}/oauth2/platformtoken",
    headers={
        "Content-Type": "application/x-www-form-urlencoded"
    },
    data={
        "grant_type": "client_credentials",
        "client_id": CYBERARK_ADMIN_USER,
        "client_secret": CYBERARK_ADMIN_PWD
    }
) # type: ignore
response.raise_for_status() # type: ignore
jw_token = response.json()['access_token']

#print(f"Obtained JWT token from CyberArk Identity:\n{jw}")

# get AuthenticatedClient
client = AuthenticatedClient(base_url=f"{CYBERARK_SAI_URL}", 
                             token=jw_token)
#print("Client:\n", client)
response = sync_detailed(client=client, accept="application/json")

if 'application/json' in response.headers.get('Content-Type', ''):
    try:
        # Parse the JSON response body
        data = response.json()
        # Pretty print the JSON data
        pretty_json = json.dumps(data, indent=4)
        print("Pretty Printed JSON Response Body:")
        print(pretty_json)
    except json.JSONDecodeError:
        print("Response body is not valid JSON.")
        print("Raw Response Body:")
        print(response.content)
else:
    print("Response is not JSON. Raw Response Body:")
    print(response.content)

sys.exit(0)

# Predefined agent types (strings):
#    CHATGPT, CLAUDE, GEMINI, COPILOT, PERPLEXITY, SALESFORCE, SERVICENOW, GROK, CUSTOM
# Agent status values (AgentStatusAgentStatusValue.enums):
#    ACTIVE, PENDING_CONNECTION, SUSPENDED
agent = Agent.from_dict({
    "id": "agent-12345",
    "name": "My Agent",
    "type": "CHATGPT",
    "description": "This is my custom agent",
    "owner": f"{CYBERARK_ADMIN_USER}",
    "tags": {
        "environment": "development",
        "team": "AI"
    },
    "redirectCallbackUrls": [
        "https://myapp.com/callback"
    ],
    "status": {
        "state": AgentStatusAgentStatusValue.ACTIVE,
        "message": "Successfully connected."
    },
    "createdBy": f"{CYBERARK_ADMIN_USER}",
    "createdAt": "2024-06-01T12:00:00Z",
    "updatedBy": f"{CYBERARK_ADMIN_USER}",
    "updatedAt": "2024-06-01T12:00:00Z",
    "additionalProperties": {
        "customProperty1": "value1",
        "customProperty2": "value2"
    }
})  

print("Agent to be created:\n", agent)