#!/usr/bin/env bash
set -euo pipefail

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --no-input

# Optional: log blockchain connectivity in build output
python manage.py check_blockchain

