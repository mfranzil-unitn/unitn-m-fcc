#!/bin/bash
read -r -d '' PAYLOAD << EOF
{
    "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "$OS_USERNAME",
          "domain": { "id": "$OS_PROJECT_DOMAIN_ID" },
          "password": "$OS_PASSWORD"
        }
      }
    },
    "scope": {
      "project": {
        "name": "$OS_PROJECT_NAME",
        "domain": { "id": "$OS_PROJECT_DOMAIN_ID" }
      }
    }
  }
}
EOF
echo $PAYLOAD
