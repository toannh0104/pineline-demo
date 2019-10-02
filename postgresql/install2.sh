#!/bin/sh

export MASTER_SERVER=192.168.0.164
export SYN_STANDBY_SERVER=192.168.0.174
export ASYN_STANDBY_SERVER=192.168.0.121

EQ_DATASTORE_PATH=/data/equator

# Global variables
export REPO_RPM_URL=https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
export PGSQL_TARGETVER=11

# Function cleanUp
function cleanUp {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <server_ip>' ; exit 1; }
  case $PGSQL_TARGETVER in
    11)
      # Cleanup and remove PostgreSQL 11
      ssh -t root@$1 "
        (firewall-cmd --remove-service=postgresql --permanent || true) &&
        firewall-cmd --reload &&
        (yum remove -y postgresql11-contrib postgresql11 postgresql11-server postgresql-libs pgdg-redhat-repo || true) &&
        (rm -rf /var/lib/pgsql/11 /usr/pgsql-11 $EQ_DATASTORE_PATH || true) &&
        (userdel -f postgres || true)
      "
      # (rm -rf /var/lib/pgsql /usr/pgsql-11 $EQ_DATASTORE_PATH || true) &&
      ;;
  esac
}

function installUser {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <server_ip>' ; exit 1; }
  scp ./configs/hosts root@$1:/etc
  # echo \"postgres\" | passwd --stdin postgres &&
  ssh -t root@$1 "
    useradd -m -d /var/lib/pgsql postgres &&
    sudo -u postgres ssh-keygen -t rsa -f /var/lib/pgsql/.ssh/id_rsa -N \"\"  &&
    sudo -u postgres sh -c \"ssh-keyscan -t rsa -H $MASTER_SERVER >> ~/.ssh/known_hosts\" &&
    sudo -u postgres sh -c \"ssh-keyscan -t rsa -H $SYN_STANDBY_SERVER >> ~/.ssh/known_hosts\" &&
    sudo -u postgres sh -c \"ssh-keyscan -t rsa -H $ASYN_STANDBY_SERVER >> ~/.ssh/known_hosts\" &&
    sudo -u postgres sh -c \"ssh-keyscan -t rsa -H MASTER_SERVER >> ~/.ssh/known_hosts\" &&
    sudo -u postgres sh -c \"ssh-keyscan -t rsa -H SYN_STANDBY_SERVER >> ~/.ssh/known_hosts\" &&
    sudo -u postgres sh -c \"ssh-keyscan -t rsa -H ASYN_STANDBY_SERVER >> ~/.ssh/known_hosts\" &&
    sudo -u postgres sh -c \"touch ~/.ssh/authorized_keys\" &&
    sudo -u postgres sh -c \"restorecon -R -v ~/.ssh\"
  "
}

# Function install
function install {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <server_ip>' ; exit 1; }
  case $PGSQL_TARGETVER in
    11)
      # Install PostgreSQL 11
      scp ./configs/hosts root@$1:/etc
      ssh -t root@$1 "
        yum install -y ${REPO_RPM_URL} &&
        yum install -y postgresql11-server postgresql11 postgresql11-contrib
      "
      ;;
  esac
}

# Function install Master
function installMaster {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <master_ip>' ; exit 1; }
  case $PGSQL_TARGETVER in
    11)
      # Install PostgreSQL 11
      # /usr/pgsql-11/bin/postgresql-11-setup initdb &&
      ssh -t root@$1 "
        /usr/pgsql-11/bin/postgresql-11-setup initdb &&
        systemctl start postgresql-11 &&
        systemctl enable postgresql-11 &&
        firewall-cmd --add-service=postgresql --permanent &&
        firewall-cmd --reload
      "
      ;;
  esac
}



##### function config_replica
##### usage: config_replica <master_ip>
#####
function configMaster {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <master_ip>' ; exit 1; }
  ssh -t root@$1 "
    sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'postgres';\" &&
    sudo -u postgres psql -c \"SELECT * FROM pg_remove_physical_replication_slot('syn_standby_server');\"
    sudo -u postgres psql -c \"SELECT * FROM pg_remove_physical_replication_slot('asyn_standby_server');\"
  "
  scp ./configs/master/postgresql.conf postgres@$1:/var/lib/pgsql/11/data
  scp ./configs/master/pg_hba.conf postgres@$1:/var/lib/pgsql/11/data
}

##### function configSynStandby
##### usage: configSynStandby <syn_standby_ip>
#####
function configSynStandby {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <syn_standby_ip>' ; exit 1; }

  ssh -t root@$1 "
    sudo -u postgres /usr/pgsql-11/bin/pg_basebackup -D /var/lib/pgsql/11/data/ -c fast -X fetch -P -Fp -R -h MASTER_SERVER -p 5432 &&
    sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'postgres';\"
  "
  scp ./configs/standby/syn/postgresql.conf postgres@$1:/var/lib/pgsql/11/data
  scp ./configs/standby/syn/pg_hba.conf postgres@$1:/var/lib/pgsql/11/data
  scp ./configs/standby/syn/recovery.conf postgres@$1:/var/lib/pgsql/11/data
  ssh -t root@$1 "
    systemctl enable postgresql-11 &&
    systemctl restart postgresql-11 &&
    firewall-cmd --add-service=postgresql --permanent &&
    firewall-cmd --reload
  "

}

##### function configAsynStandby
##### usage: configAsynStandby <Asyn_standby_ip>
#####
function configAsynStandby {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 <Asyn_standby_ip>' ; exit 1; }
  echo '----- START SETUP STANDBY SERVER -------'
  ssh -t root@$1 "
    sudo -u postgres mkdir /var/lib/pgsql/11/walarchive &&
    sudo -u postgres /usr/pgsql-11/bin/pg_basebackup -D /var/lib/pgsql/11/data/ -c fast -X fetch -P -Fp -R -h MASTER_SERVER -p 5432 &&
    sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'postgres';\"
  "
  scp ./configs/standby/asyn/postgresql.conf postgres@$1:/var/lib/pgsql/11/data
  scp ./configs/standby/asyn/pg_hba.conf postgres@$1:/var/lib/pgsql/11/data
  scp ./configs/standby/asyn/recovery.conf postgres@$1:/var/lib/pgsql/11/data
  ssh -t root@$1 "
    systemctl restart postgresql-11 &&
    systemctl enable postgresql-11 &&
    firewall-cmd --add-service=postgresql --permanent &&
    firewall-cmd --reload
  "
  echo '----- END SETUP STANDBY SERVER -------'

}

#====================== MAIN script body =====================

##### STEP1: install PostgreSQL packages

# cleanUp $MASTER_SERVER
# installUser $MASTER_SERVER
#install $MASTER_SERVER

# installMaster   $MASTER_SERVER
# configMaster    $MASTER_SERVER


# cleanUp $SYN_STANDBY_SERVER
# installUser $SYN_STANDBY_SERVER
# install $SYN_STANDBY_SERVER
configSynStandby   $SYN_STANDBY_SERVER



# cleanUp $ASYN_STANDBY_SERVER
# installUser $ASYN_STANDBY_SERVER
# install $ASYN_STANDBY_SERVER
configAsynStandby   $ASYN_STANDBY_SERVER
