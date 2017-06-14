#!/bin/bash

  #0 check if parameters exists and put Usage if not
if [ "$1" == "" ]; then
  echo "Usage:  sh deploy.sh path/to/param/file"
  echo ""
  exit 0
fi

  #1 define AWS profile and exporting to ENV
AWS_PROFILE_NAME=saml
export AWS_PROFILE=$AWS_PROFILE_NAME

  #2 getting variables from parameters file
params=$1
source $params

  #3 building an array of ec2 instances, members of ELB
EC2_LIST="$(aws elb describe-load-balancers --load-balancer-names $ELB_NAME --query LoadBalancerDescriptions[].Instances[].InstanceId --output text)"
EC2_LIST=($EC2_LIST)

  #4 'for' loop to process within each of EC2 instances in ELB
for ec2 in "${EC2_LIST[@]}"; do
  #4.1 Printing instance ID
  echo "Starting work with instance: $ec2"
  #4.2 Checking EC2 instance initial status in ELB service and printing it out
  ec2_status="$(aws elb describe-instance-health --load-balancer-name $ELB_NAME --instances $ec2 --query 'InstanceStates[*].[State]' --output text)"
  echo "  -> initial item $ec2 ELB status: $ec2_status";
done
