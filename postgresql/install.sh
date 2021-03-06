#!/bin/sh

SVR1_IP=192.168.0.164
SVR2_IP=192.168.0.174
SVR3_IP=192.168.0.121

EQ_DATASTORE_PATH=/data/equator

# Global variables
export REPO_RPM_URL=https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
export PGSQL_TARGETVER=11

##### function cleanUp: Completely remove PostgreSQL
##### usage: cleanUp <server_ip> <postgresql version>
#####
function cleanUp {
  case $PGSQL_TARGETVER in
    11)
      # Cleanup and remove PostgreSQL 11
      ssh -t root@$1 "
        (firewall-cmd --remove-service=postgresql --permanent || true) &&
        firewall-cmd --reload &&
        (yum remove -y postgresql11-contrib postgresql11 postgresql11-server postgresql-libs pgdg-redhat-repo || true) &&
        (rm -rf /var/lib/pgsql /usr/pgsql-11 $EQ_DATASTORE_PATH || true) &&
        (userdel -f postgres || true)
      "
      ;;
    10)
      # Cleanup and remove  PostgreSQL 10
      ssh -t root@$1 "
        (firewall-cmd --remove-service=postgresql --permanent || true) &&
        firewall-cmd --reload &&
        (yum remove -y postgresql10-contrib postgresql10-server postgresql10 postgresql-libs pgdg-redhat-repo || true) &&
        (rm -rf /var/lib/pgsql /usr/pgsql-10 $EQ_DATASTORE_PATH || true) &&
        (userdel -f postgres || true)
      "
      ;;
    9.6)
      # Cleanup and remove  PostgreSQL 9.6
      ssh -t root@$1 "
        (firewall-cmd --remove-service=postgresql --permanent || true) &&
        firewall-cmd --reload &&
        (yum remove -y postgresql96-contrib postgresql96-server postgresql96 postgresql-libs pgdg-redhat-repo || true) &&
        (rm -rf /var/lib/pgsql /usr/pgsql-9.6 $EQ_DATASTORE_PATH || true) &&
        (userdel -f postgres || true)
      "
      ;;
    9.5)
      # Cleanup and remove  PostgreSQL 9.5
      ssh -t root@$1 "
        (firewall-cmd --remove-service=postgresql--permanent || true) &&
        firewall-cmd --reload &&
        (yum remove -y postgresql95-contrib postgresql95-server postgresql95 postgresql-libs pgdg-redhat-repo || true) &&
        (rm -rf /var/lib/pgsql /usr/pgsql-9.5 $EQ_DATASTORE_PATH || true) &&
        (userdel -f postgres || true)
      "
      ;;
    9.4)
      # Cleanup and remove  PostgreSQL 9.4
      ssh -t root@$1 "
        (firewall-cmd --remove-service=postgresql --permanent || true) &&
        firewall-cmd --reload &&
        (yum remove postgresql94-contrib -y postgresql94-server postgresql94 postgresql-libs pgdg-redhat-repo || true) &&
        (rm -rf /var/lib/pgsql /usr/pgsql-9.4 $EQ_DATASTORE_PATH || true) &&
        (userdel -f postgres || true)
      "
      ;;
  esac
}

##### function install
##### usage: install <server_ip>
#####
function install {
  case $PGSQL_TARGETVER in
    11)
      # Install PostgreSQL 11
      ssh -t root@$1 "
        yum install -y ${REPO_RPM_URL} && 
        yum install -y postgresql11-server postgresql11 postgresql11-contrib &&
        /usr/pgsql-11/bin/postgresql-11-setup initdb &&
        systemctl start postgresql-11 &&
        systemctl enable postgresql-11 &&
        firewall-cmd --add-service=postgresql --permanent &&
        firewall-cmd --reload
      "
      ;;
    10)
      # Install PostgreSQL 10
      ssh -t root@$1 "
        yum install -y ${REPO_RPM_URL} &&
        yum install -y postgresql10-server postgresql10 postgresql10-contrib &&
        /usr/pgsql-10/bin/postgresql-10-setup initdb -D $EQ_DATASTORE_PATH &&
        systemctl enable postgresql-10 &&
        systemctl start postgresql-10 &&
        firewall-cmd --add-service=postgresql --permanent && 
        firewall-cmd --reload
      "
      ;;
    9.6)
      # Install PostgreSQL 9.6
      ssh -t root@$1 "
        yum install -y ${REPO_RPM_URL} &&
        yum install -y postgresql96-server postgresql96 postgresql96-contrib &&
        /usr/pgsql-9.6/bin/postgresql96-setup initdb -D $EQ_DATASTORE_PATH &&
        systemctl enable postgresql-9.6 &&
        systemctl start postgresql-9.6 &&
        firewall-cmd --add-service=postgresql --permanent &&
        firewall-cmd --reload
      "
      ;;
    9.5)
      # Install PostgreSQL 9.5
      ssh -t root@$1 "
        yum install -y ${REPO_RPM_URL} &&
        yum install -y postgresql95-server postgresql95 postgresql95-contrib &&
        /usr/pgsql-9.5/bin/postgresql95-setup initdb -D $EQ_DATASTORE_PATH &&
        systemctl enable postgresql-9.5 &&
        systemctl start postgresql-9.5 &&
        firewall-cmd --add-service=postgresql --permanent &&
        firewall-cmd --reload
      "
      ;;
    9.4)
      # Install PostgreSQL 9.4
      ssh -t root@$1 "
        yum install -y ${REPO_RPM_URL} &&
        yum install -y postgresql94 postgresql94-server postgresql94-contrib &&
        /usr/pgsql-9.4/bin/postgresql94-setup initdb -D $EQ_DATASTORE_PATH &&
        systemctl enable postgresql-9.4 &&
        systemctl start postgresql-9.4 &&
        firewall-cmd --add-service=postgresql --permanent &&
        firewall-cmd --reload
      "
      ;;
  esac
}

##### function configure
##### usage: configure <key> <value>
##### 
function configure {
  [[ $# -ne 2 ]] && { exit 1; }
  KEY=$1
  NEWVAL=${2:-""}
  FILE_NAME="/var/lib/pgsql/${PGSQL_TARGETVER}/data/postgresql.conf"
  echo "sed -i \"/$KEY *= *.*/s/^ *# *//g\" $FILE_NAME && sed -i \"s/\($KEY *= *\).*\$/\1$NEWVAL/\" $FILE_NAME"
}


##### function config_remove
##### usage: config_remove <server_ip> <key>
##### 
function config_remove {
  [[ $# -ne 2 ]] && { echo 'Usage: $0 server_ip key' ; exit 1; }
  KEY=$2
  FILE_NAME="/var/lib/pgsql/${PGSQL_TARGETVER}/data/postgresql.conf"
  ssh -t root@$1 "
    if [ -f $FILE_NAME ]; then
      sed -i \"/$KEY *= *.*/s/^/ *# */g\" $FILE_NAME;
    fi
  
  "
}

##### function config_apply
##### usage: config_apply <server_ip>
##### 
function config_apply {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 server_ip' ; exit 1; }
  ssh -t root@$1 "systemctl restart postgresql-${PGSQL_TARGETVER}"
}


##### function config_basic
##### usage: config_basic <server_ip>
##### 
function config_basic {
  [[ $# -ne 1 ]] && { echo 'Usage: $0 server_ip' ; exit 1; }
  FILE_NAME="/var/lib/pgsql/${PGSQL_TARGETVER}/data/postgresql.conf"
  ssh -t root@$1 "
    if [ -f $FILE_NAME ]; then
      $(configure listen_addresses "\'*\'");
      $(configure superuser_reserved_connections 3);
      $(configure max_connections 400);
      $(configure log_line_prefix "\'%t %u %d '");
    fi
  "
}

##### function create_masterdb
##### usage: create_masterdb <server_ip> <db_name> <username> <password>
##### 
function create_masterdb {
  [[ $# -ne 4 ]] && { echo 'Usage: $0 server_ip db_name db_owner password' ; exit 1; }
  FILE_NAME="/var/lib/pgsql/${PGSQL_TARGETVER}/data/postgresql.conf"
  ssh -t root@$1 "
    if [ -f $FILE_NAME ]; then
      su - postgres;

    fi
  "
}

##### function config_replica
##### usage: config_replica <master_ip> <slave_ip>
##### 
function config_replica {
  [[ $# -ne 2 ]] && { echo 'Usage: $0 <master_ip>  <slave_ip>' ; exit 1; }
  FILE_NAME="/var/lib/pgsql/${PGSQL_TARGETVER}/data/postgresql.conf"
  SCP_FILE="/usr/pgsql-${PGSQL_TARGETVER}/bin/syncwal.sh"
  
  echo "configure master node...."
  rm -rf /tmp/syncwal.sh
  touch /tmp/syncwal.sh
  echo "#!/bin/sh" >> /tmp/syncwal.sh
  echo "scp \$1 postgres@$2:/var/lib/pgsql/11/walarchive/\$2" >> /tmp/syncwal.sh
  echo "if [ \$? != 0 ]; then" >> /tmp/syncwal.sh
  echo "   echo \"Archiver error:\"; exit 1;" >> /tmp/syncwal.sh
  echo "fi" >> /tmp/syncwal.sh
  echo "exit 0" >> /tmp/syncwal.sh
  scp /tmp/syncwal.sh root@$1:"$SCP_FILE"
  ssh -t root@$1 "
    chown postgres: ${SCP_FILE};
    chmod 700 ${SCP_FILE};
    if [ -f $FILE_NAME ]; then
      $(configure wal_level replica);
      $(configure max_wal_senders 10);
      $(configure wal_keep_segments 256);
      $(configure archive_mode on);
      $(configure archive_command \'/usr/pgsql-11/bin/syncwal.sh %p %f\');
    fi
  "
  
  echo "configure hot-standby slave node...."
}

#====================== MAIN script body =====================

##### STEP1: install PostgreSQL packages
#cleanUp $SVR1_IP
#cleanUp $SVR2_IP
cleanUp $SVR3_IP

#install $SVR1_IP

#cleanUp $SVR2_IP
#install $SVR2_IP

##### STEP2: Basic configuration
#config_basic $SVR1_IP
#config_basic $SVR2_IP

##### STEP3: Configure hot-standby replica
#config_replica $SVR1_IP $SVR1_IP 


#config_apply $SVR1_IP
#config_apply $SVR2_IP
