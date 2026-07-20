#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

AUTH_JWT_DIR="$PROJECT_ROOT/main-services/auth-service/app/config/jwt"
PRIVATE_KEY="$AUTH_JWT_DIR/private.pem"
PUBLIC_KEY="$AUTH_JWT_DIR/public.pem"

SERVICES=(
    "main-services/api-placemarkers-collection"
    "main-services/api-placemarkers-database"
    "main-services/api-placemarkers-search"
    "main-services/app-frontend"
)

echo "Distributing JWT keys to services..."

if [ ! -f "$PRIVATE_KEY" ] || [ ! -f "$PUBLIC_KEY" ]; then
    echo "Error: JWT keys not found in $AUTH_JWT_DIR"
    exit 1
fi

for SERVICE in "${SERVICES[@]}"; do
    TARGET_DIR="$PROJECT_ROOT/$SERVICE/app/config/jwt"
    mkdir -p "$TARGET_DIR"
    cp "$PRIVATE_KEY" "$TARGET_DIR/private.pem"
    cp "$PUBLIC_KEY" "$TARGET_DIR/public.pem"
    echo " -> Copied to $TARGET_DIR"
done

echo "JWT keys distributed successfully."
