#!/bin/bash

SERVICES=(
    "api-placemarkers-collection:https://github.com/Vlad812/placemarkers-demo-api-collection.git"
    "api-placemarkers-database:https://github.com/Vlad812/placemarkers-demo-api-database.git"
    "api-placemarkers-search:https://github.com/Vlad812/placemarkers-demo-api-search.git"
    "app-frontend:https://github.com/Vlad812/placemarkers-demo-app-frontend.git"
    "auth-service:https://github.com/Vlad812/placemarkers-demo-auth-service.git"
    "notification-provider:https://github.com/Vlad812/placemarkers-demo-notification-provider.git"
)

MAIN_SERVICES_DIR="main-services"

mkdir -p "$MAIN_SERVICES_DIR"

for SERVICE in "${SERVICES[@]}"; do
    DIR_NAME="${SERVICE%%:*}"
    REPO_URL="${SERVICE#*:}"
    
    TARGET_DIR="$MAIN_SERVICES_DIR/$DIR_NAME"
    
    if [ ! -d "$TARGET_DIR" ]; then
        echo "Directory $TARGET_DIR does not exist. Cloning from $REPO_URL..."
        git clone "$REPO_URL" "$TARGET_DIR"
    else
        echo "Directory $TARGET_DIR already exists. Skipping."
    fi
done
