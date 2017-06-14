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
AWS_PROFILE_NAME=saml
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
  echo "Starting work with instance: $ec2"
  #4.2 Checking EC2 instance initial status in ELB service and printing it out
  ec2_status="$(aws elb describe-instance-health --load-balancer-name $elb_name --instances $ec2 --query 'InstanceStates[*].[State]' --output text)"
  echo "  -> initial item $ec2 ELB status: $ec2_status";
done
exit 0
