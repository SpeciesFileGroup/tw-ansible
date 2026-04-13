# Installing and managing TaxonWorks with Ansible

This repository provides Ansible playbooks for installing and maintaining a production TaxonWorks instance on a dedicated Linux server. The playbooks install Docker and run TaxonWorks and its service dependencies in Docker containers.

To fully automate the installation, we use [Ansible](https://docs.ansible.com/ansible/latest/getting_started/introduction.html) which is a powerful automation platform that will complete the installation and system administration tasks using [YAML](https://en.wikipedia.org/wiki/YAML) configuration files defined in Ansible playbooks. You may need to customize the playbooks to fit your needs.

## Requirements

Installing TaxonWorks into production depends on having a dedicated 
[Ubuntu 24.04 Server](https://ubuntu.com/download/server) with a minimum of 8 GB of RAM 
that is accessible with an IP address via SSH. You also need a user with sudo permissions 
on the server.

### ***Warning!*** 

We only recommend running these playbooks on a fresh installation of Ubuntu 24.04 Server 
with no other applications already installed because the playbooks will change the server configuration in a way that could be incompatible with other applications. Prior to running the playbooks please spend some time studying them to 
ensure you understand what they do.

## Playbooks

### Setup

| Playbook | Description |
|---|---|
| `bootstrap.yml` | Configures the base Linux system (users, SSH keys, hostname, firewall) |
| `install.yml` | Full initial installation of TaxonWorks (Docker, database, configs, containers) |

### Operations

| Playbook | Description |
|---|---|
| `upgrade.yml` | Upgrade TaxonWorks to the latest version |
| `restart.yml` | Restart containers without upgrading |
| `rollback.yml` | Roll back to a specific version |
| `status.yml` | Health check (containers, disk, backups, migrations, errors) |

### Backup & Recovery

| Playbook | Description |
|---|---|
| `backup.yml` | On-demand database backup |
| `restore.yml` | Restore database from a backup file |
| `backup-offsite.yml` | Copy backups to a remote server or S3 |
| `cleanup.yml` | Prune old backups, logs, and Docker images |

### User Management

| Playbook | Description |
|---|---|
| `add-user.yml` | Create a TaxonWorks user account |

## Installing

### 1) Install Ansible
Follow the [instructions to install Ansible on your computer](https://docs.ansible.com/ansible/latest/installation_guide/index.html).

### 2) Clone this git repository

SSH
```sh
git clone git@github.com:SpeciesFileGroup/tw-ansible.git
```

HTTPS
```sh
git clone https://github.com/SpeciesFileGroup/tw-ansible.git
```

### 3) Change directories into the repository
```sh
cd tw-ansible
```

### 4) Edit the hosts file

Copy the hosts.template file to hosts:

```sh
cp hosts.template hosts
```

In order to target the server with a playbook you must define the IP address
in the ./hosts file. Replace X.X.X.X with your server's public IP address:

```conf
tw ansible_host=X.X.X.X

[local]
127.0.0.1 ansible_connection=local

```
`tw` will be the name for the server.

### 5) Edit the global variables file

Copy the global variables file:

```sh
cp playbooks/group_vars/all.template playbooks/group_vars/all
```

Edit the `playbooks/group_vars/all` file to define the global variables for your server.

### 6) Install TaxonWorks

```sh
ansible-playbook -i ./hosts playbooks/install.yml --user tw --ask-pass --ask-become-pass
```

## Operations

All operational playbooks follow the same pattern:

```sh
ansible-playbook -i ./hosts playbooks/<playbook>.yml --user tw --ask-pass --ask-become-pass
```

### Upgrading

```sh
ansible-playbook -i ./hosts playbooks/upgrade.yml --user tw --ask-pass --ask-become-pass
```

Skip asset precompilation for a faster deploy:

```sh
ansible-playbook -i ./hosts playbooks/upgrade.yml --user tw --ask-pass --ask-become-pass -e skip_precompile=true
```

### Restarting

```sh
# Restart all containers
ansible-playbook -i ./hosts playbooks/restart.yml --user tw --ask-pass --ask-become-pass

# Restart only the TaxonWorks container
ansible-playbook -i ./hosts playbooks/restart.yml --user tw --ask-pass --ask-become-pass -e service=tw
```

### Rolling back

```sh
ansible-playbook -i ./hosts playbooks/rollback.yml --user tw --ask-pass --ask-become-pass \
  -e tw_image_tag=v0.55.0 -e tw_git_ref=v0.55.0

# Optionally restore a database backup as part of the rollback
ansible-playbook -i ./hosts playbooks/rollback.yml --user tw --ask-pass --ask-become-pass \
  -e tw_image_tag=v0.55.0 -e tw_git_ref=v0.55.0 -e restore_backup=/backups/some_backup.dump
```

### Checking status

```sh
ansible-playbook -i ./hosts playbooks/status.yml --user tw --ask-pass --ask-become-pass
```

### Backup and restore

```sh
# On-demand backup
ansible-playbook -i ./hosts playbooks/backup.yml --user tw --ask-pass --ask-become-pass

# Restore from a local file (uploads to server)
ansible-playbook -i ./hosts playbooks/restore.yml --user tw --ask-pass --ask-become-pass \
  -e restore_file=/path/to/local/backup.dump

# Restore from a file already on the server
ansible-playbook -i ./hosts playbooks/restore.yml --user tw --ask-pass --ask-become-pass \
  -e restore_from_remote=/backups/some_backup.dump

# Copy backups offsite via rsync
ansible-playbook -i ./hosts playbooks/backup-offsite.yml --user tw --ask-pass --ask-become-pass \
  -e offsite_rsync_dest=user@backup-server:/backups

# Copy backups offsite to S3
ansible-playbook -i ./hosts playbooks/backup-offsite.yml --user tw --ask-pass --ask-become-pass \
  -e offsite_method=s3 -e offsite_s3_bucket=s3://my-bucket/taxonworks-backups

# Clean up old backups, logs, and Docker images
ansible-playbook -i ./hosts playbooks/cleanup.yml --user tw --ask-pass --ask-become-pass
```

### Adding users

```sh
ansible-playbook -i ./hosts playbooks/add-user.yml --user tw --ask-pass --ask-become-pass \
  -e user_name="Jane Doe" -e user_email="jane@example.com" -e user_password="secret"

# Create an admin user
ansible-playbook -i ./hosts playbooks/add-user.yml --user tw --ask-pass --ask-become-pass \
  -e user_name="Jane Doe" -e user_email="jane@example.com" -e user_password="secret" -e user_admin=true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at: https://github.com/SpeciesFileGroup/tw-ansible. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/SpeciesFileGroup/tw-ansible?tab=coc-ov-file).

## License

These playbooks are available as open source under the terms of the [MIT](https://opensource.org/licenses/MIT) license.
