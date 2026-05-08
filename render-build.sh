#!/usr/bin/env bash
set -euo pipefail

# Install dependencies
pip install -r requirements.txt

# Run migrations
python diplomabf/manage.py migrate

# Collect static files
python diplomabf/manage.py collectstatic --no-input

# Optional: log blockchain connectivity in build output
python diplomabf/manage.py check_blockchain
