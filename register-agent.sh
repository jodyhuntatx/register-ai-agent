#!/bin/bash

source demo-vars.sh

set -eou pipefail

# Gen API package from OpenAPI spec
main() {
    if [ ! -d secure_ai_api_client ]; then
        echo "Generating API package from OpenAPI spec..."
        gen_api_package
    else
        echo "API package already exists. Skipping generation."
    fi
    register_agent
}

gen_api_package() {
    pushd gen-api-package
        uv init --no-workspace
        sleep 5
        uv add --frozen openapi-python-client
        uv run openapi-python-client generate --path CyberArk-sai-api.json
        # make uv compatible pyproject file
        pushd secure-ai-api-client/secure_ai_api_client
            uv init --no-workspace
        popd
        # move generated package to parent directory and clean up
        mv secure-ai-api-client/secure_ai_api_client ..
        mv secure-ai-api-client/README.md ../Secure-AI-API-Client-README.md
        rm -rf main.py README.md uv.lock pyproject.toml .venv .python-version secure-ai-api-client
    popd
}

register_agent() {
    uv sync --no-install-workspace
    uv run python3 cybr-sai-client.py
}

main "$@"
