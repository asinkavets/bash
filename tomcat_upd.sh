#!/bin/bash
instance=""
art_name="sample.war"
#art_source="https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war"
art_source="/$art_name"
art_store="/opt/bitnami/apache-tomcat/artifacts"
art_dest="/opt/bitnami/apache-tomcat/webapps/ROOT"
  #Bitnami info: https://docs.bitnami.com/aws/infrastructure/tomcat/
  #1 stop Tomcatsample-v2.war
#cmd1="sudo /opt/bitnami/ctlscript.sh stop"
  #2 wget war file and put it in war's store, if art_store doesn't exist, create it
#cmd2="sudo wget -O $art_dest/$art_name $art_source || (sudo mkdir $art_dest && sudo wget -O $art_dest/$art_name $art_source)"
  #3 cleanuping site ROOT folder and extracting new artifact in it
#cmd3="sudo rm -r $art_dest/* && sudo unzip $art_store/$art_name -d $art_dest"
  #4 start Tomcat
#cmd4="sudo /opt/bitnami/ctlscript.sh start"
  #5 healthcheck
#cmd5="curl -o /dev/null --silent --head --write-out '%{http_code}\n' localhost"
  # while cmd5 no 200, sleep 3
  # clean old war's
#ssh -o StrictHostKeyChecking=no -l bitnami $instance "date"
ssh -o StrictHostKeyChecking=no -l bitnami $instance 'bash -s' <<'ENDSSH'
  # stop Tomcat Server
echo "[STEP]: Stopping Tomcat Server"
sudo /opt/bitnami/ctlscript.sh stop
  # wget war file and put it in war's store, if art_store doesn't exist, create it
echo "[STEP]: Downloading artifact and extracting it"
sleep 5
sudo wget -O $art_dest/$art_name $art_source || (sudo mkdir $art_dest && sudo wget -O $art_dest/$art_name $art_source)
  # cleanuping site ROOT folder and extracting new artifact in it
sleep 5e
sudo rm -r $art_dest/* && sudo unzip $art_store/$art_name -d $art_dest
  # start Tomcat
echo "[STEP]: Starting Tomcat Server"
sleep 5
sudo /opt/bitnami/ctlscript.sh start
  # HealthCheck
echo "[STEP]: Checking if application is ready for work"
until [[ "$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' localhost)" == 200 ]]; do
  echo "->  waiting for Web Server"
  echo "    ....trying again......"
  sleep 3
done
echo "[STEP]: New application version has been successfully deployed to: $instance"
  echo "Successfull"
ENDSSH
