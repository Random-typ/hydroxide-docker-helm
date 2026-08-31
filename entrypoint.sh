#!/bin/bash
set -e

# If the first argument is "hydroxide", pass directly
if [ "$1" = "hydroxide" ]; then
    exec "$@"
elif [ "$1" = "auth" ] || [ "$1" = "status" ] || [ "$1" = "export-secret-keys" ]; then
    exec hydroxide "$@"
elif [ -n "$1" ]; then
    exec "$@"
fi

# Default behavior: run hydroxide serve on 0.0.0.0
AUTH_FILE="${HOME}/.config/hydroxide/auth.json"

if [ ! -f "$AUTH_FILE" ]; then
    echo "========================================================================"
    echo "NOTICE: No authenticated ProtonMail user found."
    echo ""
    echo "To log in, execute the auth command interactively:"
    echo "  Docker Compose:  docker compose exec -it hydroxide hydroxide auth <username>"
    echo "  Kubernetes:      kubectl exec -it deployment/hydroxide -- hydroxide auth <username>"
    echo "========================================================================"
fi

echo "Starting Hydroxide serve daemon listening on 0.0.0.0..."
exec hydroxide -imap-host 0.0.0.0 -smtp-host 0.0.0.0 -carddav-host 0.0.0.0 serve