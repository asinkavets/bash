#!/bin/bash

instance=""
art_source="https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war"
art_store="/opt/bitnami/apache-tomcat/artifacts"
art_dest="/opt/bitnami/apache-tomcat/webapps/ROOT"
  #Bitnami info: https://docs.bitnami.com/aws/infrastructure/tomcat/

  #1 stop Tomcat
cmd1="$(sudo /opt/bitnami/ctlscript.sh stop)"
  #2 wget war file and put it in war's store
  #2 ideas: use (2.1 || 2.2)
cmd2.1="$(sudo wget -O $art_store/sample-v1.war $art_source)"
#if art_store doesn't exist, create it
cmd2.2="$(sudo mkdir $art_store && sudo wget -O $art_store/sample-v1.war $art_source)"
  #3 cleanuping site ROOT folder and extracting new artifact in it
cmd3="$(sudo rm -r $art_dest/* && sudo unzip $art_store/sample-v1.war -d $art_dest)"
  #4 start Tomcat
cmd4="$(sudo /opt/bitnami/ctlscript.sh start)"
  #5 healthcheck
cmd5="$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' localhost)"
  # while cmd5 no 200, sleep 3
  # clean old war's
  # unite in one ssh command
