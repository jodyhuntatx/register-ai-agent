#!/bin/bash

source demo-vars.sh

CURL="curl -s"
util_defaults="set -u"


# Predefined agent types (strings):
#    CHATGPT, CLAUDE, GEMINI, COPILOT, PERPLEXITY, SALESFORCE, SERVICENOW, GROK, CUSTOM
# Agent status values (AgentStatusAgentStatusValue.enums):
#    ACTIVE, PENDING_CONNECTION, SUSPENDED

#####################################
function showUsage() {
    echo; echo
    echo "Usage:"
    echo "$0 [ lis | list_agents ]"
    echo "$0 [ add | add_agent ] <agent.json>"
    echo "$0 [ upd | update_agent ] <agent_id> <agent.json>"
    echo "$0 [ del | delete_agent ] <agent_id>"
    echo; echo
    exit 1
}

main() {
    local command=$1
    case $command in
        list_agents | lis*)
            command="list_agents"
            ;;
        add_agent | add*)
            if [[ $# != 2 ]]; then
                showUsage $@
            fi
            agent_file=$2
            if [[ ! -f "$agent_file" ]]; then
                echo "Agent Json file $agent_file not found!"
                exit 1
            fi
            if ! jq -M . "$agent_file" > /dev/null 2>&1; then
            echo "❌ Invalid JSON"
            exit 1
            fi
            command="add_agent"
            ;;
        update_agent | upd*)
            if [[ $# != 3 ]]; then
                showUsage $@
            fi
            agent_id=$2
            agent_file=$3
            if [[ ! -f "$agent_file" ]]; then
                echo "Agent Json file $agent_file not found!"
                exit 1
            fi
            if ! jq -M . "$agent_file" > /dev/null 2>&1; then
                echo "❌ Invalid JSON"
                exit 1
            fi
            command="update_agent"
            ;;
        delete_agent | del*)
            if [[ $# != 2 ]]; then
                showUsage $@
            fi
            command="delete_agent"
            agent_id=$2
            ;;
        *)
            showUsage $@
            ;;
    esac

    oauth2ClientAuthenticate

    $command
}

#####################################
# sets the global authorization header used in api calls for other methods
function oauth2ClientAuthenticate() {
  $util_defaults
#  echo "Authenticating user $CYBERARK_ADMIN_USER..."

  response=$($CURL                                             	\
        -X POST                                                         \
        "${CYBERARK_IDENTITY_URL}/oauth2/platformtoken"     		\
        --write-out '\n%{http_code}'                                \
        -H "Content-Type: application/x-www-form-urlencoded"            \
        --data-urlencode "grant_type"="client_credentials"              \
        --data-urlencode "client_id"="$CYBERARK_ADMIN_USER"             \
        --data-urlencode "client_secret"="$CYBERARK_ADMIN_PWD")
    http_code=$(tail -n1 <<< "$response")  # get http_code on last line
    content=$(sed '$ d' <<< "$response")   # trim http_code from content

    case $http_code in
        200)
            AUTH_TOKEN=$(echo "$content" | jq -r .access_token)
            authHeader="Authorization: Bearer $AUTH_TOKEN"
            ;;
        *)
            echo "{ \"message\": \"Failed to authenticate service account $CYBERARK_ADMIN_USER.\",
            \"http_code\": $http_code,
            \"response\": $content }"
            ;;
    esac

}

#####################################
function list_agents() {
    $util_defaults
    response=$($CURL -X GET "${CYBERARK_AIGW_URL}/agents"          \
        --write-out '\n%{http_code}'                    \
        -H "$authHeader"                                \
        -H "Accept: application/x.agents.beta+json")
    http_code=$(tail -n1 <<< "$response")  # get http_code on last line
    content=$(sed '$ d' <<< "$response")   # trim http_code

    case $http_code in
        200)
            echo "$content" | jq .
            ;;
        *)
            echo "{ \"message\": \"Failed to list agents.\",
            \"http_code\": $http_code,
            \"response\": $content }"
            ;;
    esac
}

#####################################
function delete_agent() {
    $util_defaults
    response=$($CURL -X DELETE "${CYBERARK_AIGW_URL}/agents/${agent_id}"  \
        --write-out '\n%{http_code}'                                      \
        -H "$authHeader"                                                  \
        -H "Accept: application/x.agents.beta+json")
    http_code=$(tail -n1 <<< "$response")  # get http_code on last line
    content=$(sed '$ d' <<< "$response")   # trim http_code

    case $http_code in
        204)
            echo "Agent ID $agent_id deleted."
            ;;
        404)
            echo "Agent ID $agent_id not found."
            ;;
        *)
            echo "{ \"message\": \"Failed to delete agent.\",
            \"id\": \"$agent_id\",
            \"http_code\": $http_code,
            \"response\": $content }"
            ;;
    esac
}

#####################################
function add_agent() {
    $util_defaults
    agent_data=$(cat "$agent_file")
    response=$($CURL -X POST "${CYBERARK_AIGW_URL}/agents"           \
        --write-out '\n%{http_code}'                      \
        -H "$authHeader"                                  \
        -H "Content-Type: application/json"               \
        -H "Accept: application/x.agents.beta+json'"      \
        -d "$agent_data")
    http_code=$(tail -n1 <<< "$response")  # get http_code on last line
    content=$(sed '$ d' <<< "$response")   # trim http_code

    case $http_code in
        201)
            echo "$content" | jq .
            ;;
        *)
            echo "{ \"message\": \"Failed to add agent.\",
            \"http_code\": $http_code,
            \"response\": $content }"
            ;;
    esac
}

#####################################
function update_agent() {
    $util_defaults
    agent_data=$(cat "$agent_file")
    response=$($CURL -X PUT "${CYBERARK_AIGW_URL}/agents/$agent_id"    \
        --write-out '\n%{http_code}'                        \
        -H "$authHeader"                                    \
        -H "Content-Type: application/json"                 \
        -H "Accept: application/x.agents.beta+json'"        \
        -d "$agent_data")
    http_code=$(tail -n1 <<< "$response")  # get http_code on last line
    content=$(sed '$ d' <<< "$response")   # trim http_code

    case $http_code in
        200)
            echo "$content" | jq .
            ;;
        404)
            echo "Agent ID $agent_id not found."
            ;;
        *)
            echo "{ \"message\": \"Failed to update agent.\",
            \"id\": \"$agent_id\",
            \"http_code\": $http_code,
            \"response\": $content }"
            ;;
    esac
}

main "$@"

