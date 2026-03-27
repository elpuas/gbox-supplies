Task name: Debug DevContainer not starting after port change to 8200
Date: 2026-03-27

Root cause:
- The startup script linked `/var/www/html/wp-content` to a hardcoded path (`/workspaces/wp-content`).
- In this repository, the actual workspace path is `/workspaces/gbox-supplies`, so the symlink target could be wrong and setup behavior became inconsistent during post-start.
- Apache port setup also left default vhost/listener configuration active, so startup did not enforce a single `8200` VirtualHost.

Files updated:
- `.devcontainer/devcontainer.json`
- `.devcontainer/wp-setup.sh`

Changes made:
- Updated `workspaceFolder` to `/workspaces/${localWorkspaceFolderBasename}` so startup runs in the actual repo path.
- Updated `postStartCommand` to call `bash .devcontainer/wp-setup.sh` explicitly.
- In `wp-setup.sh`:
  - Compute repo root dynamically from script location and link `wp-content` to that path.
  - Re-link `wp-content` on subsequent runs if it points elsewhere.
  - Enforce port `8200` as the only Apache listener (`/etc/apache2/ports.conf`).
  - Clear enabled site symlinks and enable only `wordpress-8200.conf`.
  - Keep script idempotent.

Verification:
- `apache2ctl configtest` => `Syntax OK`
- `sudo apache2ctl -S` => only `*:8200 localhost (/etc/apache2/sites-enabled/wordpress-8200.conf:1)`
- `ss -tulpn | rg '(:80|:8200)'` => only `:8200` listener
- `curl -I http://localhost:8200` => `HTTP/1.1 200 OK`
- Startup sequence (`postStartCommand`) completes successfully in ~8s without hanging.
