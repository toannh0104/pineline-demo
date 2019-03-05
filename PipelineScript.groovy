def replaceSecrets(src, keys, secretMap){
   if(src ==null) return null
   if(keys != null && secretMap != null){
      keys.each { k ->
         def val = secretMap.get(k, null)
         def tmp = src.replaceAll("#${k}#", val)
         src = tmp
      }
   }
   return src
}

def skipRemainingStages = false
def vaultLeaderInfo = null
def vaultTokenInfo = null
def svcs = [
      [svcName: 'agent', dbName: 'agent'],
      [svcName: 'ami-admin-portal', dbName: 'admin_portal'],
      [svcName: 'ami-api-gateway', dbName: 'api_gateway'],
      [svcName: 'ami-channel-gateway', dbName: 'channel_gateway'],
      [svcName: 'ami-operation-portal', dbName: 'operation_portal'],
      [svcName: 'bulk-upload', dbName: 'bulk_upload'],
      [svcName: 'centralize-configuration', dbName: 'centralize_configuration'],
      [svcName: 'channel-adapter', dbName: 'channel_adapter'],
      [svcName: 'customer', dbName: 'customer'],
      [svcName: 'data-exporter', dbName: 'data_exporter'],
      [svcName: 'device-management', dbName: 'device_management'],
      [svcName: 'fraud-consultant', dbName: 'fraud_consultant'],
      // [svcName: 'housekeeping', dbName: null],
      [svcName: 'inventory', dbName: 'inventory'],
      [svcName: 'loyalty', dbName: 'loyalty'],
      [svcName: 'otp-management', dbName: 'otp_management'],
      [svcName: 'password-center', dbName: 'password_center'], 
      [svcName: 'payment', dbName: 'payment'],
      [svcName: 'payroll', dbName: 'payroll'],
      [svcName: 'prepaid-card', dbName: 'prepaid_card'],
      [svcName: 'reconciler', dbName: 'reconciler'],
      [svcName: 'report', dbName: 'report'],
      // [svcName: 'rule-action', dbName: null],
      [svcName: 'rule-engine', dbName: 'rule_engine'],
      [svcName: 'sof-bank', dbName: 'sof_bank'],
      [svcName: 'sof-card', dbName: 'sof_card'],
      [svcName: 'sof-cash', dbName: 'sof_cash'],
      // [svcName: 'spi-engine', dbName: null],
      [svcName: 'system-user', dbName: 'system_user'],
      [svcName: 'trust-management', dbName: 'trust_management'],
      [svcName: 'voucher', dbName: 'voucher'],
      [svcName: 'workflow', dbName: 'workflow']
   ]
def vaultCredMap = [
   dev: 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJlcXVhdG9yLWRlZmF1bHQtZGV2Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImFjbS1kZXBsb3llci10b2tlbi14cjk3ZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhY20tZGVwbG95ZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI2NjI3YzZkNS03ZWE3LTExZTgtOTNiMi0wMDUwNTY5YjBhNzAiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZXF1YXRvci1kZWZhdWx0LWRldjphY20tZGVwbG95ZXIifQ.RIe4NGkBw87-XrVBRDt66oulNtXyZOpNUrtbUWAIeyCxHAf46GWvc_t88gHwR_4N1vP8tMhP4LsU-rmJGqAcgeHgmT103llUkx8eLzcxQeJ7_0w9jP-L_iiRhdMY5Sa5ok7Z0YEPsMu1Dg0x95i86UrQqwKjceEFlpGGJEVlcccX_W8r20Sg4dUFIuSIGYHfvVDPXA2LpimomCI9jWiTV2fdzUXd9Stkw64S3NvWBuWEVajj5dIkhhazK7t5KeW0ecp4ayFyY0k4sRFTC0prxhMjq3Af7oyw4eYpd6Vy3PAfgEnIt0ObcjU44qmH3LDmxF332czZM4JDdJS8RKCreg',
   qa:  'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJlcXVhdG9yLWRlZmF1bHQtcWEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiYWNtLWRlcGxveWVyLXRva2VuLWRnZGZkIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFjbS1kZXBsb3llciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjY2NjRhNjBlLTdlYTctMTFlOC05M2IyLTAwNTA1NjliMGE3MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDplcXVhdG9yLWRlZmF1bHQtcWE6YWNtLWRlcGxveWVyIn0.hkCoAtLIp6vcy3yERKg1fj8DvDrxrXIRAvMlvUFZhmouSZc_yp8xZW0qR0SJJai8oXR_si6GreDEmH7Ap5cS9uQxznuX6AxyBbTiVfOYO9xwGCvq6P4m0Vu4nBpcgFhCsMYW7Q_oqygBUh5nXjvyBbJitqbKQ_ow_SBviY-APrQebSHDzRYM5GgRLIlZDD4ji0oon0VILHSg1KcQAvSkUq9VxiFebEXS53RbHJT2rxggdUAXUlAjaw3iwSvcqN4GDqoJw3FI56WRLh2rq3OXb0KdNCWRwttCyBDr7kQIjYM2arVKv3juEed7bUOJkhJCuQBURzswaIRHDA1HVyIeTg',
   performance: 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJlcXVhdG9yLWRlZmF1bHQtcGVyZm9ybWFuY2UiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiYWNtLWRlcGxveWVyLXRva2VuLTk5bGdrIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFjbS1kZXBsb3llciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjY2OWQxNTNiLTdlYTctMTFlOC05M2IyLTAwNTA1NjliMGE3MCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDplcXVhdG9yLWRlZmF1bHQtcGVyZm9ybWFuY2U6YWNtLWRlcGxveWVyIn0.UTUYq8Jrb0gCT2k2f8k2vHGO5j9X2ms3hvfoUSakzoAegmQNCzzxGDun3TiGKP-0qPjwf82AdMsJO3pShOLqxj2mpmuT8-0wCFRjdHrmoC5TPZaRCgPWmcE2D7ePhUaMBbiieSiKQ0Opm83FWYrQ9XN0_kYiw1Fkj4XcuhSxkHYWpGrxgupBoLHvqpZwvFroWIF4bkx4mTH9t3683g0-VT9AaNQCPcFWGiGaGV-XbUlDH8W9vLLBFhq3cmqdoUuQ7qbjpOgNw_rRIdzqIwKLu5iYS9eWGKrzkabx1GXcs2AHGKJDL4G1BV99194lyrvIeSgZpHIb1pRrZrS0KkGShg',
]
def unprocessedSvcs = []

pipeline {
   agent any
   // Environment
   environment {
      // Global Variable Declartion
      TOOL_REPO_URL='https://bitbucket.org/ascendcorp/ami-equator-openshift-db-tool.git'
      TOOL_HOME_PATH='tools'
      S3_APPCFG_ENDPOINT='https://s3-ap-southeast-1.amazonaws.com'
      S3_APPCFG_REGION='ap-southeast-1'
      S3_APPCFG_BUCKET='acm-eq-th-openshift-app-configs'
      APP_CONFIG_PATH='appconfigs'
      VAULT_LEADER_URL='https://vault-cluster.common-cicd-platform.svc:8200/v1/sys/leader'
      KUBERNETES_APP_SCOPE='equator'
      KUBERNETES_APP_SVC_GROUP='default'
   }
   parameters {
      choice(name: 'DatabaseEnvironment', choices: 'dev\nqa\nperformance', description: 'Select target database environment')
      choice(name: 'DatabaseOperation',  choices: 'clean\nrebuild', description: 'Clean: try to clear user data without applying any structure changes\nRebuild: Reset database to initial state. This Operation will drop database and rebuild from scratch')
      text(name: 'SkipServices', defaultValue: 'agent\nami-admin-portal\nami-api-gateway\nami-channel-gateway\nami-operation-portal\nbulk-upload\ncentralize-configuration\nchannel-adapter\ncustomer\ndata-exporter\ndevice-management\nfraud-consultant\ninventory\nloyalty\notp-management\npassword-center\npayment\npayroll\nprepaid-card\nreconciler\nreport\nrule-engine\nsof-bank\nsof-card\nsof-cash\nsystem-user\ntrust-management\nvoucher\nworkflow', description: 'Above services will be skipped')
      string(name: 'DbMasterUser', defaultValue: 'eq_db', description: 'Database master account which has DDL permission')
      password(name: 'DbMasterPassword', defaultValue: 'P@ss99W0rd', description: 'Database master account password')
   }
   options {
      buildDiscarder(logRotator(numToKeepStr:'5'))
      skipDefaultCheckout true
      disableConcurrentBuilds()
      timeout(time: 15, unit: 'MINUTES')
   }
   stages {
      stage('Prepare Information') {
         steps {
            dir ("${env.APP_CONFIG_PATH}") {
               deleteDir()
            }

            script {
               if (isUnix()) {
                  echo "######### INFO: OS is Unix-like #########"
               } else {
                  echo '######### ERROR: OS is NOT Unix-like. Pipeline does not support #########'
                  currentBuild.result = 'FAILED'
                  skipRemainingStages = true
                  error 'This Pipleline does not support non-Unix OS'
                  return
               }
            }

            dir("${env.TOOL_HOME_PATH}") {
               git(url: "${env.TOOL_REPO_URL}", credentialsId: "equator-cicd-bitbucket-credential-secret")
               script {
                  // Test provided Database credential
                  //def dbUrl = "${env.DatabaseEnvironment}-master-db.ascendmoney-dev.internal:3306"
                  def dbUrl = "10.14.255.3:3306"
                  def dbTestStatus = sh (script: "set +x; ./goose/goose mysql '${env.DbMasterUser}:${env.DbMasterPassword}@tcp(${dbUrl})/' ping > /dev/null; set -x", returnStatus: true)
                  if (dbTestStatus != 0) {
                     echo '######### ERROR: Invalid DB username password #########'
                     currentBuild.result = 'FAILED'
                     skipRemainingStages = true
                     error 'The given Database master credential is not correct'
                     return
                  }
               }
            }

            script {
               try{
                  // Prepare for Vault fetching
                  def VAULT_TOKEN = vaultCredMap.get(env.DatabaseEnvironment)
                  def VAULT_LEADER_RAW = sh(script: "set +x; curl -s -k ${env.VAULT_LEADER_URL}; set -x;", returnStdout: true).trim()
                  vaultLeaderInfo = readJSON(text: "${VAULT_LEADER_RAW}")
                  def VAULT_TOKEN_RAW = sh(script: "set +x; curl -s -X POST -d '{\"jwt\": \"${VAULT_TOKEN}\", \"role\": \"${env.KUBERNETES_APP_SCOPE}-${env.KUBERNETES_APP_SVC_GROUP}-read-only-${env.DatabaseEnvironment}-role\"}' -k ${vaultLeaderInfo.leader_cluster_address}/v1/auth/kubernetes/login; set -x;", returnStdout: true).trim()
                  vaultTokenInfo = readJSON(text: "${VAULT_TOKEN_RAW}")
               } catch (err) {
                  echo "######### ERROR: cannot fetch Vault for environment <${env.DatabaseEnvironment}> #########"
                  echo "${err.toString()}"
                  currentBuild.result = 'FAILED'
                  skipRemainingStages = true
                  return
               }
            }
         }
      }
      stage('Processing') {
         when {
            expression {
               !skipRemainingStages
            }
         }
         steps {
            script {
               //def dbUrl = "${env.DatabaseEnvironment}-master-db.ascendmoney-dev.internal:3306"
               def dbUrl = "10.14.255.3:3306"
               dir ("${env.APP_CONFIG_PATH}") {
                  def skipList = []
                  env.SkipServices.split('\n').each { item ->
                     if(item?.trim()) {
                        skipList << item.trim()
                     }
                  }
                  // Get services version
                  svcs.each { el ->
                     def svcName = el.get("svcName", null)
                     def dbName = el.get("dbName", null)
                     try {
                        if (skipList.contains(svcName) || dbName == null) {
                           echo "######### INFO: Service ${svcName} is either skipped by request or has no database. No operation needed. #########"
                        } else {
                           sh(script: "curl -s -k https://${svcName}.equator-default-${env.DatabaseEnvironment}.svc:8443/${svcName}/info > ${svcName}-info.json", returnStdout: false)
                           if (fileExists("${svcName}-info.json")) {
                              def buildInfo = readJSON(file: "${svcName}-info.json")
                              def artifact = "${svcName}-${buildInfo.build.version}"
                              withAWS(credentials:'openshift-s3-credential', endpointUrl: "${env.S3_APPCFG_ENDPOINT}", region: "${env.S3_APPCFG_REGION}") {
                                 s3Download(pathStyleAccessEnabled: true, bucket: "${env.S3_APPCFG_BUCKET}", file: "${artifact}.tar.gz", path: "${env.DatabaseEnvironment}/${svcName}/${artifact}.tar.gz", force: true)
                              }
                              sh "/bin/tar -zxvf ${artifact}.tar.gz -C . > /dev/null"
                              // Check if service has DB script
                              if(fileExists("${artifact}/version_sql_after.txt")) {
                                 dir ("${artifact}/db_migration") {
                                    def VAULT_DATA_RAW = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeaderInfo.leader_cluster_address}/v1/secret/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                    def vaultData = readJSON(text: "${VAULT_DATA_RAW}").data
                                    def envData = ["ENV": "${env.DatabaseEnvironment}"]
                                    vaultData = vaultData + envData
                                    def keys = readJSON(file: "keys.json")
                                    def keyList = []
                                    keyList << "ENV"
                                    keys.each { k ->
                                       keyList << k.get('key')
                                    }
                                    dir ("create-databases") {
                                       def files = findFiles(glob: '*.sql')
                                       files.each { f ->
                                          def sqlDB = readFile(file: "${f.name}", encoding: "utf-8")
                                          sqlDB = replaceSecrets(sqlDB, keyList, vaultData)
                                          sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose/goose mysql '${env.DbMasterUser}:${env.DbMasterPassword}@tcp(${dbUrl})/' runsql \"DROP DATABASE IF EXISTS ${dbName}_${env.DatabaseEnvironment};\" > /dev/null; set -x", returnStatus: true)
                                          sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose/goose mysql '${env.DbMasterUser}:${env.DbMasterPassword}@tcp(${dbUrl})/' runsql \"${sqlDB};\" > /dev/null; set -x", returnStatus: true)
                                       }
                                    }
                                    // Find and replace secrets
                                    def sqlFiles = findFiles(glob: '*.sql')
                                    sqlFiles.each { f ->
                                       def sql = readFile(file: "${f.name}", encoding: "utf-8")
                                       sql = replaceSecrets(sql, keyList, vaultData)
                                       writeFile (file: "${f.name}", text: sql, encoding: "utf-8")
                                    }
                                    // Execute goose up migration
                                    def migrationStatus = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose/goose mysql '${env.DbMasterUser}:${env.DbMasterPassword}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' up > /dev/null; set -x", returnStatus: true)
                                    if (migrationStatus != 0) {
                                       unprocessedSvcs << "${svcName}"
                                       currentBuild.result='UNSTABLE'
                                    }
                                 }
                              }
                           }
                        }
                     } catch (exc) {
                        echo "######### WARNING: cannot get current info of service. DB Operation will be skipped for <${svcName}> #########"
                        echo "${exc.toString()}"
                        sh "rm -rf ${svcName}-info.json"
                        unprocessedSvcs << "${svcName}"
                        currentBuild.result='UNSTABLE'
                     }
                  }
               }
            }
         }
      }
   }
   post {
      success {
         echo '######### BUILD SUCCESS! #########'
      }
      failure {
         echo '######### BUILD FAILED! #########'
      }
      unstable {
         echo '######### BUILD UNSTABLE #########'
         echo 'the following databases haven\'t been processed'
         script {
            def unprocessedLst = ""
            unprocessedSvcs.each { i ->
               def dbErr = "${i}_${env.DatabaseEnvironment}"
               unprocessedLst = unprocessedLst + "\n${dbErr.replace("-", "_")}"
            }
            if(unprocessedLst?.trim()){
               echo unprocessedLst
            }
         }
      }
   }
}
