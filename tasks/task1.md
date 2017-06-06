## General describtion:

Here we have 2 ec2 instance in AWS with ELB behind of them. Each instance has Tomcat with HelloWorld site inside it. So we need to create bash script for zero-downtime deployment within the next requirements:
- [ ] kick of EC2 instance from ELB service
- [ ] Check if EC2 has no more active sessions form ELB
- [ ] Deploy new site version and restart Tomcat instance
- [ ] Check if site alive on the instance
- [ ] Turn this EC2 instance back to ELB
- [ ] Check if it start processing requests from ELB
- [ ] Proceed same deployment process for the 2d/etc instance

## Additional requirements:
- [ ] Script should be re-usable for any amount of EC2 instances and any ELB specified
- [ ] it should be parametrized via property file
- [ ] script should run max with 2 parameters:
  * path to property file
  * configuration name (if you have multiple configurations in it)
