# Install Ansible software:
------------
## Install Ansible tool on host machine
- For RHEL based family:
  > [sudo] yum --enablerepo=extras install -y epel-release
  > [sudo] yum install -y ansible
- For MacOS:
  > brew install ansible

  you may need to install sshpass as well, this package is considered to be blacklisted due to some security concern but you can install it from personal repo:
  > brew install hudochenkov/sshpass/sshpass

## Install required packages for Ansible modules: 
  Following packages have to be installed on remote machines. These packages used by Ansible modules, not a part of PostgreSQL installation
- [python2-pexpect v4.5](https://cbs.centos.org/kojifiles/packages/python-pexpect/4.5/1.el7/noarch/python2-pexpect-4.5-1.el7.noarch.rpm) which requires `python2-ptyprocess` from EPEL repo
- `python2-psycopg2`
- `python-ipaddress`
- `libsemanage-python`

example: `sudo yum install ~/python2-pexpect-4.5-1.el7.noarch.rpm python2-psycopg2 python-ipaddress libsemanage-python`


# Install Postgres using Ansible playbooks
------------
## Inventory configuration
  Create a file named `inventory.cfg` in the same folder with playbooks. You can copy sample content and edit from `inventory_sample.cfg` file. example:
  > ```
  >[pgmaster]
  > db-master.sample.internal ansible_host=192.168.0.79 ansible_connection=ssh ansible_user=<your ssh account> ansible_password=<your password>
  >[pgread]
  > psql2 ansible_host=192.168.0.149 ansible_connection=ssh ansible_user=<your ssh account> ansible_password=<your password>
  >[pgback]
  >[pgstandby:children]
  > pgback
  > pgread
  >[all:children]
  > pgmaster
  > pgstandby
  >```
  each host record should be in the format of:
  >`hostname`   `host_ip(v4)`   `ansible_connect_description...`
  Should keep only one record in [pgmaster] group because we have only one master node for PostgreSQL
## Install postgres package repo
  Depends on linux distro, you have to install public postgres repository from https://download.postgresql.org
  The guidance is also on website. For example: https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm will need to be installed for RHEL based distros. 
## Run Playbooks
To install
>`[user@psql1 ~]# sh ./install.sh`

To uninstall
>`[user@psql1 ~]# sh ./uninstall.sh`