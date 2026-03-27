Task name: Standardize WordPress DevContainer to use port 8200

Files modified:
- .devcontainer/devcontainer.json
- .devcontainer/wp-setup.sh
- .devcontainer/start-wp.sh

Summary of changes:
- Kept Dev Container port forwarding on 8200 for WordPress access.
- Added a single `WP_PORT=8200` variable to the setup and startup scripts.
- Replaced hardcoded WordPress and health check URLs with the shared port variable.
- Made Apache port setup idempotent by removing previous custom listen entries and old `wordpress-*.conf` files before creating the new VirtualHost.
- Updated WordPress bootstrap to use `http://localhost:8200` and to enforce `home` and `siteurl` on each run.
