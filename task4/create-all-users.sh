#!/usr/bin/env bash
set -euo pipefail

./create-user.sh viewer-user prop-viewers
./create-user.sh editor-user prop-editors
./create-user.sh security-admin prop-security-admins

echo "All users created successfully."