#!/bin/bash

  #0 check if parameters exists
if [ "$1" == "" ]; then
  echo "Err: No parameter file has been specified!"
  echo ""
  echo "  Usage:  sh deploy.sh path/to/param/file"
  echo ""
  exit 1
elif ! [[ -f "$1" ]]; then
  echo "Err: No such parameters file, please put valid parameters file/path"
  echo ""
  exit 1
fi

  #1 define AWS profile and exporting to ENV
AWS_PROFILE_NAME=default
export AWS_PROFILE=$AWS_PROFILE_NAME

  #2 getting variables from parameters file and brake the script if file does not exists
params=$1
source $params || exit 1

  #3.1 building an array of ec2 instances, members of ELB
ec2_list="$(aws elb describe-load-balancers --load-balancer-names $elb_name --query LoadBalancerDescriptions[].Instances[].InstanceId --output text)"
ec2_list=($ec2_list)
  #3.2 checking if array has more than 0 instance/s
while [[ ${#ec2_list[@]} == 0 ]]; do
  echo "Err: You have 0 instances inside ELB"
  exit 1
done

  #4 'for' loop to process within each of EC2 instances in ELB
for ec2 in "${ec2_list[@]}"; do
  #4.1 Printing instance ID
  echo "Starting work on instance: $ec2"
  #4.2 Checking EC2 instance initial status in ELB service and printing it out
  ec2_status="$(aws elb describe-instance-health --load-balancer-name $elb_name --instances $ec2 --query 'InstanceStates[*].[State]' --output text)"
  echo "  -> initial item $ec2 ELB status: $ec2_status"
  #4.3 Disconnect EC2 instance out from ELB rotation
  echo "  -> disconnecting $ec2 from ELB rotation ..."
  aws elb deregister-instances-from-load-balancer --load-balancer-name $elb_name --instances $ec2
  #4.4 Convert EC2 ID to IP/CNAME
  ec2_ip="$(aws ec2 describe-instances --instance-ids $ec2 --query 'Reservations[*].Instances[*].PublicDnsName' --output text)"
  #4.5 Connecting by ssh and deploying application
  ssh -o StrictHostKeyChecking=no -l $ec2_username -t $ec2_ip "
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
  "
  #4.6 Check instance status (health check)
  echo "  -> checking $ec2 application health"
  until [[ "$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' $ec2_ip)" == 200 ]]; do
    echo "  ->  waiting for Web Server"
    echo "    ....trying again......"
    sleep 5
  done
  echo "  -> Web Server health is OK"
  #4.7 Getting instance back to ELB if HealthCheck successfull
  echo "  -> get back $ec2 into ELB rotation"
  aws elb register-instances-with-load-balancer --load-balancer-name $elb_name --instances $ec2
  #4.8 Checking EC2 instance status in ELB service after artifact deployment
  until [[ "$(aws elb describe-instance-health --load-balancer-name $elb_name --instances $ec2 --query 'InstanceStates[*].[State]' --output text)" == InService ]]; do
    echo "  ->  waiting for instance $ec2 health in ELB"
    echo "    ....trying again......"
    sleep 3
  done
  echo ""
  echo "  -> !Application has been successfully deployed to $ec2!"
done
exit 0
