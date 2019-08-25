#!/usr/bin/env groovy
// This branch [master] is specified to local countries. Equator must use [equator] branch instead
def replaceSecrets(src, keys, secretMap) {
   if(src ==null) return null
   if(keys != null && secretMap != null) {
      keys.each { k ->
         def val = secretMap.get(k, null)
         val = val.replaceAll("\r\n|\n\r|\n|\r","\\\\r\\\\n")
         def tmp = src.replace("#${k}#", val)
         src = tmp
      }
   }
   return src
}

def extractVersionInfo(str) {
   def i = str.indexOf("goose: version ")
   if(i != -1) {
      return str.substring(i+15)
   }
   return "unavailable"
}

def skipRemainingStages = false
def vaultTokenInfo = null
def vaultLeader = null
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
      // [svcName: 'data-exporter', dbName: 'data_exporter'],
      [svcName: 'device-management', dbName: 'device_management'],
      [svcName: 'file-management', dbName: 'file_management'],
      [svcName: 'fraud-consultant', dbName: 'fraud_consultant'],
      // [svcName: 'housekeeping', dbName: null],
      [svcName: 'inventory', dbName: 'inventory'],
      // [svcName: 'loyalty', dbName: 'loyalty'],
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
      [svcName: 'sof-loan', dbName: 'sof_loan'],
      // [svcName: 'spi-engine', dbName: null],
      [svcName: 'system-user', dbName: 'system_user'],
      [svcName: 'trust-management', dbName: 'trust_management'],
      [svcName: 'voucher', dbName: 'voucher'],
      [svcName: 'workflow', dbName: 'workflow']
   ]
def unprocessedSvcs = []
def versionChanges = []
def dbUrl = ''
def msgOut = ''
def commandGetLastMigrationNumber = 'ls *.sql | sed -e s/_.*//g | sed -e s/^0*//g | sort -n | tail -1'
pipeline {
   agent any
   // Environment
   environment {
      // Global Variable Declartion
      TOOL_HOME_PATH='tools'
      S3_ENDPOINT='https://s3-ap-southeast-1.amazonaws.com'
      S3_REGION='ap-southeast-1'
      S3_APPCFG_BUCKET='acm-eq-th-openshift-app-configs'
      S3_GOOSE_BUCKET='equator-bucket' //s3://equator-bucket/software/goose
      APP_CONFIG_PATH='appconfigs'
      VAULT_LEADER_V1_URL = 'https://vault-cluster.common-cicd-platform.svc:8200/v1/sys/leader'
      KUBERNETES_APP_SCOPE='equator'
      KUBERNETES_APP_SVC_GROUP='default'
   }
   parameters {
      choice(name: 'DatabaseEnvironment', choices: 'dev\nqa\nperformance\nstaging', description: 'Select target database environment')
      choice(name: 'VaultAPIVersion', choices: '1\n2', description: 'Select Vault API Version (default 1 for pipeline library < 1.7.1)')
      choice(name: 'Action', choices: 'check\nupgrade\ndowngrade\nreset', description: 'check: report current version compare to release information.\nupgrade: Upgrade database to the latest released version without losing user data.\ndowngrade: Downgrade database to the version coresponding current running service.\nreset: Upgrade to the latest version and CLEAR ALL USER DATA(!!!)')
      text(name: 'SkipServices', defaultValue: 'agent\nami-admin-portal\nami-api-gateway\nami-channel-gateway\nami-operation-portal\nbulk-upload\ncentralize-configuration\nchannel-adapter\ncustomer\ndevice-management\nfile-management\nfraud-consultant\ninventory\notp-management\npassword-center\npayment\npayroll\nprepaid-card\nreconciler\nreport\nrule-engine\nsof-bank\nsof-card\nsof-cash\nsof-loan\nsystem-user\ntrust-management\nvoucher\nworkflow', description: 'By default for safe, in upgrade or reset mode, above services will be skipped.\nIf you want to restore/upgrade specific database schemas, you need to remove them out from the list.')
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
               script {
                  // Download softwares
                  withAWS(credentials:'openshift-s3-credential', endpointUrl: "${env.S3_ENDPOINT}", region: "${env.S3_REGION}") {
                     s3Download(pathStyleAccessEnabled: true, bucket: "${env.S3_GOOSE_BUCKET}", file: "goose", path: "software/goose", force: true)
                  }
                  // Test provided Database credential
                  // if (env.DatabaseEnvironment == "production") {
                  //    dbUrl = "production-master-db.ascendmoney.internal:3306"
                  // } else {
                  dbUrl = "${env.DatabaseEnvironment}-master-db.ascendmoney-dev.internal:3306"
                  // }
                  // dbUrl = "10.14.255.3:3306" //Performance database of V-team
                  
                  withCredentials([usernameColonPassword(credentialsId: 'eqDbMasterNonProdCred', variable: 'DbCred')]) {
                     def dbTestStatus = sh (script: "set +x; chmod +x goose; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/?rejectReadOnly=true' ping > /dev/null; set -x", returnStatus: true)
                     if (dbTestStatus != 0) {
                        echo '######### ERROR: Invalid DB username password #########'
                        currentBuild.result = 'FAILED'
                        skipRemainingStages = true
                        error 'The given Database master credential is not correct'
                        return
                     }
                  }
               }
            }

            script {
               def eqVaultCred = "eqVaultCred${env.DatabaseEnvironment}"
               // Prepare for Vault fetching
               if(env.Action != 'check'){
                  withCredentials([string(credentialsId: "${eqVaultCred}", variable: 'VAULT_TOKEN')]) {
                     try{
                        if (env.VaultAPIVersion == '1') {
                           def vaultLeaderInfoJson = sh(script: "set +x; curl -s -k ${env.VAULT_LEADER_V1_URL}; set -x;", returnStdout: true).trim()
                           echo "Vault leader JSON: ${vaultLeaderInfoJson}"
                           def vaultLeaderInfo = readJSON(text: "${vaultLeaderInfoJson}")
                           vaultLeader = vaultLeaderInfo.leader_cluster_address
                        } else {
                           vaultLeader = 'https://vault-cluster-01.common-cicd-platform.svc:8200'
                        }
                        def vaultTokenInfoJson = sh(script: "set +x; curl -s -X POST -d '{\"jwt\": \"${VAULT_TOKEN}\", \"role\": \"${env.KUBERNETES_APP_SCOPE}-${env.KUBERNETES_APP_SVC_GROUP}-read-only-${env.DatabaseEnvironment}-role\"}' -k ${vaultLeader}/v1/auth/kubernetes/login; set -x;", returnStdout: true).trim()
                        vaultTokenInfo = readJSON(text: "${vaultTokenInfoJson}")
                        if(vaultTokenInfo && vaultTokenInfo.errors) {
                           error "Vault processing failed, errors: ${vaultTokenInfo}"
                        }
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
         }
      }
      stage('Processing') {
         when {
            expression {
               !skipRemainingStages
            }
         }
         steps {
            // Begin step
            script {
               // Begin Script
               switch(env.Action) {
                  case "check":
                     msgOut = "|-- Database ----------------------------|- Current Ver -|- Expected Ver |\n"
                     dir ("${env.APP_CONFIG_PATH}") {
                        // Begin directory
                        // Get services version
                        svcs.each { el ->
                           def svcName = el.get("svcName", null)
                           def dbName = el.get("dbName", null)
                           try {
                              if (dbName == null) {
                                 echo "######### INFO: Service ${svcName} has no associated database. Skip!. #########"
                              } else {
                                 def dbVersionInfo = [db_name: "${dbName}_${env.DatabaseEnvironment}", old_version: null, new_version: null, expect_version: null]
                                 sh(script: "curl -s -k https://${svcName}.equator-default-${env.DatabaseEnvironment}.svc:8443/${svcName}/info > ${svcName}-info.json", returnStdout: false)
                                 if (fileExists("${svcName}-info.json")) {
                                    def buildInfo = readJSON(file: "${svcName}-info.json")
                                    def artifact = "${svcName}-${buildInfo.build.version}"
                                    withAWS(credentials:'openshift-s3-credential', endpointUrl: "${env.S3_ENDPOINT}", region: "${env.S3_REGION}") {
                                       s3Download(pathStyleAccessEnabled: true, bucket: "${env.S3_APPCFG_BUCKET}", file: "${artifact}.tar.gz", path: "production/${svcName}/${artifact}.tar.gz", force: true)
                                    }
                                    sh "/bin/tar -zxvf ${artifact}.tar.gz -C . > /dev/null"
                                    // Check if service has DB script
                                    def expectVer = 'unknown'
                                    dir ("${artifact}/db_migration") {
                                       expectVer = sh (script: "set +x; ${commandGetLastMigrationNumber}; set -x", returnStdout: true).trim()
                                    }
                                    withCredentials([usernameColonPassword(credentialsId: 'eqDbMasterNonProdCred', variable: 'DbCred')]) {
                                       // Store existing version
                                       def oldVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                       echo "Old Verion: ${oldVer}"
                                       dbVersionInfo.old_version = extractVersionInfo(oldVer)
                                       dbVersionInfo.expect_version = expectVer
                                       if (dbVersionInfo.old_version != dbVersionInfo.expect_version) {
                                          dbVersionInfo.db_name = dbVersionInfo.db_name + ' *'
                                       }
                                       versionChanges << dbVersionInfo
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
                     }  // End directory
                     break
                  case "upgrade":
                     msgOut = "|-- Database -----------------------|-- Old Ver -| Applied Ver|Expected Ver|\n"
                     dir ("${env.APP_CONFIG_PATH}") {
                        // Begin directory
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
                                 echo "######### INFO: Service ${svcName} is either skipped by request or has no associated database. No operation needed. #########"
                              } else {
                                 def dbVersionInfo = [db_name: "${dbName}_${env.DatabaseEnvironment}", old_version: null, new_version: null, expect_version: null]
                                 sh(script: "curl -s -k https://${svcName}.equator-default-${env.DatabaseEnvironment}.svc:8443/${svcName}/info > ${svcName}-info.json", returnStdout: false)
                                 if (fileExists("${svcName}-info.json")) {
                                    def buildInfo = readJSON(file: "${svcName}-info.json")
                                    def artifact = "${svcName}-${buildInfo.build.version}"
                                    withAWS(credentials:'openshift-s3-credential', endpointUrl: "${env.S3_ENDPOINT}", region: "${env.S3_REGION}") {
                                       s3Download(pathStyleAccessEnabled: true, bucket: "${env.S3_APPCFG_BUCKET}", file: "${artifact}.tar.gz", path: "production/${svcName}/${artifact}.tar.gz", force: true)
                                    }
                                    sh "/bin/tar -zxvf ${artifact}.tar.gz -C . > /dev/null"
                                    // Check if service has DB script
                                    def expectVer = 'unknown'
                                    dir ("${artifact}/db_migration") {
                                       expectVer = sh (script: "set +x; ${commandGetLastMigrationNumber}; set -x", returnStdout: true).trim()
                                       def vaultData = null
                                       if (env.VaultAPIVersion == '1') {
                                          def vaultDataJson = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeader}/v1/secret/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                          vaultData = readJSON(text: "${vaultDataJson}").data
                                       } else {
                                          def vaultDataJson = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeader}/v1/secret/data/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                          vaultData = readJSON(text: "${vaultDataJson}").data.data
                                       }
                                       def envData = ["ENV": "${env.DatabaseEnvironment}"]
                                       vaultData = vaultData + envData
                                       def keys = readJSON(file: "keys.json")
                                       def keyList = []
                                       keyList << "ENV"
                                       keys.each { k ->
                                          keyList << k.get('key')
                                       }
                                       withCredentials([usernameColonPassword(credentialsId: 'eqDbMasterNonProdCred', variable: 'DbCred')]) {
                                          // Store existing version
                                          def oldVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                          echo "Old Verion: ${oldVer}"
                                          dbVersionInfo.old_version = extractVersionInfo(oldVer)
                                          // Find and replace secrets
                                          def sqlFiles = findFiles(glob: '*.sql')
                                          sqlFiles.each { f ->
                                             def sql = readFile(file: "${f.name}", encoding: "utf-8")
                                             sql = replaceSecrets(sql, keyList, vaultData)
                                             writeFile (file: "${f.name}", text: sql, encoding: "utf-8")
                                          }
                                          // Execute goose up migration
                                          def migrationStatus = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}?multiStatements=true&rejectReadOnly=true' up > /dev/null; set -x", returnStatus: true)
                                          def newVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                          dbVersionInfo.new_version = extractVersionInfo(newVer)
                                          dbVersionInfo.expect_version = expectVer
                                          if (migrationStatus != 0 || dbVersionInfo.new_version != dbVersionInfo.expect_version) {
                                             dbVersionInfo.db_name = dbVersionInfo.db_name + ' *'
                                             unprocessedSvcs << "${svcName}"
                                             currentBuild.result='UNSTABLE'
                                          }
                                          versionChanges << dbVersionInfo
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
                     }  // End directory
                     break
                  case "downgrade":
                     msgOut = "|-- Database -----------------------|-- Old Ver -| Applied Ver|Expected Ver|\n"
                     dir ("${env.APP_CONFIG_PATH}") {
                        // Begin directory
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
                                 echo "######### INFO: Service ${svcName} is either skipped by request or has no associated database. No operation needed. #########"
                              } else {
                                 def dbVersionInfo = [db_name: "${dbName}_${env.DatabaseEnvironment}", old_version: null, new_version: null, expect_version: null]
                                 sh(script: "curl -s -k https://${svcName}.equator-default-${env.DatabaseEnvironment}.svc:8443/${svcName}/info > ${svcName}-info.json", returnStdout: false)
                                 if (fileExists("${svcName}-info.json")) {
                                    def buildInfo = readJSON(file: "${svcName}-info.json")
                                    def artifact = "${svcName}-${buildInfo.build.version}"
                                    if (svcName == 'centralize-configuration') {
                                       artifact = "centralize-configuration-4.9.0-576"
                                    }
                                    withAWS(credentials:'openshift-s3-credential', endpointUrl: "${env.S3_ENDPOINT}", region: "${env.S3_REGION}") {
                                       s3Download(pathStyleAccessEnabled: true, bucket: "${env.S3_APPCFG_BUCKET}", file: "${artifact}.tar.gz", path: "production/${svcName}/${artifact}.tar.gz", force: true)
                                    }
                                    sh "/bin/tar -zxvf ${artifact}.tar.gz -C . > /dev/null"
                                    // Check if service has DB script
                                    def expectVer = 'unknown'
                                    dir ("${artifact}/db_migration") {
                                       expectVer = sh (script: "set +x; ${commandGetLastMigrationNumber}; set -x", returnStdout: true).trim()
                                       def vaultData = null
                                       if (env.VaultAPIVersion == '1') {
                                          def vaultDataJson = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeader}/v1/secret/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                          vaultData = readJSON(text: "${vaultDataJson}").data
                                       } else {
                                          def vaultDataJson = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeader}/v1/secret/data/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                          vaultData = readJSON(text: "${vaultDataJson}").data.data
                                       }
                                       def envData = ["ENV": "${env.DatabaseEnvironment}"]
                                       vaultData = vaultData + envData
                                       def keys = readJSON(file: "keys.json")
                                       def keyList = []
                                       keyList << "ENV"
                                       keys.each { k ->
                                          keyList << k.get('key')
                                       }
                                       withCredentials([usernameColonPassword(credentialsId: 'eqDbMasterNonProdCred', variable: 'DbCred')]) {
                                          // Store existing version
                                          def oldVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                          echo "Old Verion: ${oldVer}"
                                          dbVersionInfo.old_version = extractVersionInfo(oldVer)
                                          // Find and replace secrets
                                          def sqlFiles = findFiles(glob: '*.sql')
                                          sqlFiles.each { f ->
                                             def sql = readFile(file: "${f.name}", encoding: "utf-8")
                                             sql = replaceSecrets(sql, keyList, vaultData)
                                             writeFile (file: "${f.name}", text: sql, encoding: "utf-8")
                                          }
                                          // Execute goose down migration
                                          def migrationStatus = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}?multiStatements=true&rejectReadOnly=true' down > /dev/null; set -x", returnStatus: true)
                                          def newVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                          dbVersionInfo.new_version = extractVersionInfo(newVer)
                                          dbVersionInfo.expect_version = expectVer
                                          if (migrationStatus != 0 || dbVersionInfo.new_version != dbVersionInfo.expect_version) {
                                             dbVersionInfo.db_name = dbVersionInfo.db_name + ' *'
                                             unprocessedSvcs << "${svcName}"
                                             currentBuild.result='UNSTABLE'
                                          }
                                          versionChanges << dbVersionInfo
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
                     }  // End directory
                     break
                  case "reset":
                     msgOut = "|-- Database -----------------------|-- Old Ver -| Applied Ver|Expected Ver|\n"
                     dir ("${env.APP_CONFIG_PATH}") {
                        // Begin directory
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
                                 echo "######### INFO: Service ${svcName} is either skipped by request or has no associated database. No operation needed. #########"
                              } else {
                                 def dbVersionInfo = [db_name: "${dbName}_${env.DatabaseEnvironment}", old_version: null, new_version: null, expect_version: null]
                                 sh(script: "curl -s -k https://${svcName}.equator-default-${env.DatabaseEnvironment}.svc:8443/${svcName}/info > ${svcName}-info.json", returnStdout: false)
                                 if (fileExists("${svcName}-info.json")) {
                                    def buildInfo = readJSON(file: "${svcName}-info.json")
                                    def artifact = "${svcName}-${buildInfo.build.version}"
                                    withAWS(credentials:'openshift-s3-credential', endpointUrl: "${env.S3_ENDPOINT}", region: "${env.S3_REGION}") {
                                       s3Download(pathStyleAccessEnabled: true, bucket: "${env.S3_APPCFG_BUCKET}", file: "${artifact}.tar.gz", path: "production/${svcName}/${artifact}.tar.gz", force: true)
                                    }
                                    sh "/bin/tar -zxvf ${artifact}.tar.gz -C . > /dev/null"
                                    // Check if service has DB script
                                    def expectVer = 'unknown'
                                    dir ("${artifact}/db_migration") {
                                       expectVer = sh (script: "set +x; ${commandGetLastMigrationNumber}; set -x", returnStdout: true).trim()
                                       def vaultData = null
                                       if (env.VaultAPIVersion == '1') {
                                          def vaultDataJson = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeader}/v1/secret/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                          vaultData = readJSON(text: "${vaultDataJson}").data
                                       } else {
                                          def vaultDataJson = sh(script: "set +x; curl -s -H 'X-Vault-Token: ${vaultTokenInfo.auth.client_token}' -k ${vaultLeader}/v1/secret/data/${env.KUBERNETES_APP_SCOPE}/${env.KUBERNETES_APP_SVC_GROUP}/${env.DatabaseEnvironment}/apps/${svcName}_db_deployer; set -x", returnStdout: true).trim()
                                          vaultData = readJSON(text: "${vaultDataJson}").data.data
                                       }
                                       def envData = ["ENV": "${env.DatabaseEnvironment}"]
                                       vaultData = vaultData + envData
                                       def keys = readJSON(file: "keys.json")
                                       def keyList = []
                                       keyList << "ENV"
                                       keys.each { k ->
                                          keyList << k.get('key')
                                       }
                                       withCredentials([usernameColonPassword(credentialsId: 'eqDbMasterNonProdCred', variable: 'DbCred')]) {
                                          // Store existing version
                                          def oldVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                          echo "Old Verion: ${oldVer}"
                                          dbVersionInfo.old_version = extractVersionInfo(oldVer)
                                          dir ("create-databases") {
                                             def files = findFiles(glob: '*.sql')
                                             files.each { f ->
                                                def sqlDB = readFile(file: "${f.name}", encoding: "utf-8")
                                                sqlDB = replaceSecrets(sqlDB, keyList, vaultData)
                                                sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/' runsql \"DROP DATABASE IF EXISTS ${dbName}_${env.DatabaseEnvironment};\" > /dev/null; set -x", returnStatus: true)
                                                sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/' runsql \"${sqlDB};\" > /dev/null; set -x", returnStatus: true)
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
                                          def migrationStatus = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}?multiStatements=true&rejectReadOnly=true' up > /dev/null; set -x", returnStatus: true)
                                          def newVer = sh (script: "set +x; ${WORKSPACE}/${env.TOOL_HOME_PATH}/goose mysql '${DbCred}@tcp(${dbUrl})/${dbName}_${env.DatabaseEnvironment}' version 2>&1; set -x", returnStdout: true).trim()
                                          dbVersionInfo.new_version = extractVersionInfo(newVer)
                                          dbVersionInfo.expect_version = expectVer
                                          if (migrationStatus != 0 || dbVersionInfo.new_version != dbVersionInfo.expect_version) {
                                             dbVersionInfo.db_name = dbVersionInfo.db_name + ' *'
                                             unprocessedSvcs << "${svcName}"
                                             currentBuild.result='UNSTABLE'
                                          }
                                          versionChanges << dbVersionInfo
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
                     }  // End directory
                     break
                  default:
                     echo "######### ERROR: Invalid Action, must be either Check, Upgrade or Reset #########"
                     echo "Selected action: ${env.Action}"
                     currentBuild.result = 'FAILED'
                     skipRemainingStages = true
                     break
               }
            } // End script
         } // End step
      }
   }
   post {
      success {
         script {
            try {
               if(env.Action == "check") {
                  msgOut = 'Database Checking status: Succesfully\n' + msgOut
                  versionChanges.each { i ->
                     msgOut = msgOut + String.format( "| %-39s|%14s |%14s |\n", i.db_name, i.old_version, i.expect_version)
                  }
                  msgOut = msgOut + '|----------------------------------------|---------------|---------------|'
               } else {
                  msgOut = 'Database Migration status: Succesfully\n' + msgOut
                  versionChanges.each { i ->
                     msgOut = msgOut + String.format( "| %-34s|%14s |%14s |%14s |\n", i.db_name, i.old_version, i.new_version, i.expect_version)
                  }
                  msgOut = msgOut + '|-----------------------------------|------------|------------|------------|'
               }
               echo msgOut
            } catch(e) {
               echo "${e}"
            }
         }
      }
      failure {
         echo '######### BUILD FAILED! #########'
      }
      unstable {
         script {
            try {
               if(env.Action == "check") {
                  msgOut = 'Database Checking status: Incomplete\n' + msgOut
                  versionChanges.each { i ->
                     msgOut = msgOut + String.format( "| %-39s|%14s |%14s |\n", i.db_name, i.old_version, i.expect_version)
                  }
                  msgOut = msgOut + '|----------------------------------------|---------------|---------------|'
               } else {
                  msgOut = 'Database Migration status: Incomplete\n' + msgOut
                  versionChanges.each { i ->
                     msgOut = msgOut + String.format( "| %-34s|%14s |%14s |%14s |\n", i.db_name, i.old_version, i.new_version, i.expect_version)
                  }
                  msgOut = msgOut + '|-----------------------------------|------------|------------|------------|'
               }               
               echo msgOut
               
               def unprocessedLst = "the following databases haven\'t been processed\n"
               unprocessedSvcs.each { i ->
                  def dbErr = "${i}_${env.DatabaseEnvironment}"
                  unprocessedLst = unprocessedLst + "\n${dbErr.replace("-", "_")}"
               }
               if(unprocessedLst?.trim()){
                  echo unprocessedLst
               }
            } catch(e) {
               echo "${e}"
            }   
         }
      }
   }
}
