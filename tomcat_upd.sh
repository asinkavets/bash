#!/bin/bash
instance=""
art_name="sample-v2.war"
art_source=" /$art_name"
art_store="/opt/bitnami/apache-tomcat/artifacts"
art_dest="/opt/bitnami/apache-tomcat/webapps/ROOT"
#art_source="https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war"
  #Bitnami info: https://docs.bitnami.com/aws/infrastructure/tomcat/

ssh -o StrictHostKeyChecking=no -l bitnami -t $instance "
  # stop Tomcat Server
echo ''
echo '[STEP]: Stopping Tomcat Server'
sudo /opt/bitnami/ctlscript.sh stop
  # wget war file and put it in war's store, if art_store doesn't exist, create it
echo ''
echo '[STEP]: Downloading artifact'
echo ''
sudo wget -O $art_store/$art_name $art_source || (sudo mkdir $art_store && sudo wget -O $art_store/$art_name $art_source)
  # cleanuping site ROOT folder and extracting new artifact in it
echo ''
echo '[STEP]: Extracting new artifact'
echo ''
(sudo rm -r $art_dest/* && sudo unzip $art_store/$art_name -d $art_dest) || (sudo unzip -o $art_store/$art_name -d $art_dest)
    # start Tomcat
echo ''
echo '[STEP]: Starting Tomcat Server'
echo ''
sudo /opt/bitnami/ctlscript.sh start
  # HealthCheck
#echo ''
#echo '[STEP]: Checking if application is ready for work'
#echo ''
#until [[ "$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' localhost)" == 200 ]]; do
#  echo '->  waiting for Web Server'
#  echo '    ....trying again......'
#  sleep 5
#done
echo ''
echo '[STEP]: New application version has been successfully deployed to: $instance'
echo '[Successfull]'
"
#PENDING
#[STEP] healthcheck
#cmd5="curl -o /dev/null --silent --head --write-out '%{http_code}\n' localhost"
#[STEP] clean old war files
