#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
pip install -r requirements.txt

# Run migrations
# Note: manage.py is inside the 'diplomabf' directory
python diplomabf/manage.py migrate

# Collect static files
python diplomabf/manage.py collectstatic --no-input

# Check blockchain status (will log to build output)
python diplomabf/manage.py check_blockchain
