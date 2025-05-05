# Installing TaxonWorks into production with Ansible

This repository provides a template for developing playbooks that can be used to fully automate
the configuration of a production Linux server in order to operate a production TaxonWorks instance.
To fully automate the installation, we use [Ansible](https://docs.ansible.com/ansible/latest/getting_started/introduction.html) which is a powerful automation platform that will complete the installation 
and system administration tasks using [YAML](https://en.wikipedia.org/wiki/YAML) configuration files defined in Ansible playbooks. You may need to customize the playbooks to fit your needs.

The Ansible playbooks will install docker and run TaxonWorks and its service dependencies in docker containers.

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

Currently two playbooks are provided:

1) bootstrap.yml
2) tw.yml

The bootstrap playbook handles configuring the base Linux system for installing TaxonWorks. The TW playbook
depends upon the boostrap playbook and installs TaxonWorks. The playbooks are designed to be idempotent, 
meaning that you can run them as many times as you want and should always get the same result.

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

### 3) Edit the hosts file

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
`tw` will be the name of the name for the server.

### 4) Edit the global variables file

Copy the global variables file:

```sh
cp playbooks/group_vars/all.template playbooks/group_vars/all
```

Edit the `playbooks/group_vars/all` file to define the global variables for your server.

### 5) Install TaxonWorks

```sh
ansible-playbook -i ./hosts playbooks/tw.yml --user tw --ask-pass --ask-become-pass
```

## Contributing

Bug reports and pull requests are welcome on GitHub at: https://github.com/SpeciesFileGroup/tw-ansible. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/SpeciesFileGroup/tw-ansible?tab=coc-ov-file).

## License

These playbooks are available as open source under the terms of the [MIT](https://opensource.org/licenses/MIT) license.
