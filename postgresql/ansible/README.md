Following packages have to be installed on remote machines. These packages used by Ansible modules, not a part of PostgreSQL installation
- python2-pexpect # https://cbs.centos.org/kojifiles/packages/python-pexpect/4.5/1.el7/noarch/python2-pexpect-4.5-1.el7.noarch.rpm #
  which requires python2-ptyprocess from EPEL repo
- python2-psycopg2
- python-ipaddress
- libsemanage-python