# CLAUDE.md

Ansible playbooks for installing and managing production TaxonWorks instances on Ubuntu 24.04 servers.

## Project structure

```
hosts.template              # Inventory template — copy to `hosts` and set IP
ansible.cfg                 # Ansible configuration
initialization_data/        # Data files for initializing a fresh TaxonWorks database
playbooks/
  bootstrap.yml             # Playbook: base server setup (users, SSH, hostname, firewall)
  install.yml               # Playbook: full TaxonWorks installation
  upgrade.yml               # Playbook: upgrade existing TaxonWorks to new version
  restart.yml               # Playbook: restart containers without upgrading
  rollback.yml              # Playbook: roll back to a specific version
  status.yml                # Playbook: health check and status report
  backup.yml                # Playbook: on-demand database backup
  restore.yml               # Playbook: restore database from backup
  backup-offsite.yml        # Playbook: copy backups to remote destination
  cleanup.yml               # Playbook: prune old backups, logs, Docker images
  add-user.yml              # Playbook: create a TaxonWorks user
  group_vars/
    all.template            # Global variables template — copy to `all` and fill in values
  roles/
    bootstrap/              # Role: Linux user creation, SSH keys, hostname, firewall
    install/                # Role: Docker, git clone, configs, containers, database init/restore
    upgrade/                # Role: pull latest code/image, re-template configs, restart containers
    restart/                # Role: restart Docker containers
    rollback/               # Role: pin to specific image tag and git ref
    status/                 # Role: container state, disk, backups, migrations, log errors
    backup/                 # Role: run tw:db:dump
    restore/                # Role: restore from .dump file
    backup-offsite/         # Role: rsync or S3 sync of /backups
    cleanup/                # Role: prune old backups and Docker images
    add-user/               # Role: create user via rails runner
```

## Key conventions

- Playbooks target the `tw` host group defined in `./hosts`.
- All playbooks run as root (`become: true`) on the remote server.
- The TaxonWorks app lives at `/app` on the remote, owned by the `tw` user.
- Docker containers are named `app-tw-1` (TaxonWorks) and `app-db-1` (PostgreSQL).
- Config templates (docker-compose.yml, database.yml, application_settings.yml) live in `roles/install/templates/` and are shared by both the install and upgrade roles.
- The upgrade role references install templates via relative path (`../../roles/install/templates/`).
- Variables are defined in `playbooks/group_vars/all` (copied from `all.template`).
- Operational playbooks accept `-e` extra vars for parameters (e.g., `-e restore_file=...`, `-e user_email=...`).

## How TaxonWorks runs in production

- TaxonWorks runs as a Docker container (`sfgrp/taxonworks:latest`) alongside a PostGIS container (`postgis/postgis:12-3.4`).
- Docker volumes mount host directories for logs, public files, downloads, postgres data, backups, and staging.
- On container startup, the TaxonWorks init script (`config/docker/nginx/init.sh` in the TaxonWorks repo) automatically backs up the database and runs migrations. If a migration fails it auto-restores from the backup.
- A cron job runs nightly database backups via `tw:db:dump`.
- Backups are stored as `.dump` files (pg_dump custom format) in `/backups` on the host.

## Running playbooks

```sh
ansible-playbook -i ./hosts playbooks/<playbook>.yml --user tw --ask-pass --ask-become-pass
```
