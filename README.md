# wordpress-architecture-evolution
## Overview
This project provides terraform automation scripts for various deployment architectures to migrate web applications deployment on virtual machines to AWS EC2

## Single EC2 Instance architecture
In this architecture, both the application as well as the database will be deployed on a single EC2 instance. Installation of wordpress and MySQL database  on the EC2 instance will be done by user data scripts
### Pros
Simple architecture 
### Cons
• No Horizontal scaling. Only vertical scaling is possible by increasing the EC2 instance size and type

• No resilience. If the EC2 instance is terminated, the entire application and database is lost

• Database is deployed on the publically accessible EC2 instance

#### How to deploy terraform stack
•	Download the terraform code from the github repo

•	cd wordpress-architecture-evolution

• Open single_instance.tfvars file in a text editor and modify the varaibles values as per your requirements

•	terraform init

•	terraform validate

•	terraform apply --auto-approve --var-file=single_instance.tfvars

You will be prompted to enter the password for the wordpress database that will be created as part of this stack

#### How to destroy the terraform stack
•	cd wordpress-architecture-evolution

•	terraform destroy --auto-approve --var-file=single_instance.tfvars

You will be prompted to enter the password for the wordpress database

### Architecture
![Optional Text](../main/images/Wordpress_ec2_single_instance.png) 


## Single EC2 instance with RDS Single Availability Zone architecture
In this architecture, MySql database will be deployed using AWS RDS in Single Availability zone mode. Wordpress application will be deployed on an EC2 instance.
This architecture will help to split the database and application. Application instance can be on a public subnet and database instance can be on a private subnet and the security group attached to the database can be configured to allow the connections only from the application security group
### Pros
• Deploying the database using RDS provides automatic snapshots. These snapshots are AZ resilient and can be used to restore the database even if the entire availability zone goes down

• vertical scaling can be done separately for application and database instances

• Database can be deployed on a private subnet and security groups can be configured to allow connections only from the application EC2 instances

• Read replicas can be created for the RDS database to provide read scaling

### Cons
• No Horizontal scaling for the application layer. 

• No resilience for the application. If the Availability Zone or the EC2 instance goes down, application is lost

• In case of Availability zone failure, though automatic snapshots can be used to recover the database, RPO is dependent on the last successful backup before failure. Moreover, database recovery needs to be carried out manually using the snapshots.

#### How to deploy terraform stack
•	Download the terraform code from the github repo

•	cd wordpress-architecture-evolution

• Open rds_single_az.tfvars file in a text editor and modify the varaibles values as per your requirements

•	terraform init

•	terraform validate

•	terraform apply --auto-approve --var-file=rds_single_az.tfvars

You will be prompted to enter the password for the wordpress database that will be created as part of this stack

#### How to destroy the terraform stack
•	cd wordpress-architecture-evolution

•	terraform destroy --auto-approve --var-file=rds_single_az.tfvars

You will be prompted to enter the password for the wordpress database

### Architecture
![Optional Text](../main/images/Wordpress_ec2_rds_singleaz.png)


## Single EC2 instance with RDS Multi AZ architecture
In this architecture, MySQL database will be deployed using AWS RDS in Multi AZ mode. In Multi AZ mode, you will have a primary instance and a standby instance on a different availability zone. Data from the primary instance will be replicated to the standby instance synchronously. 
### Pros
• Since the data is replicated synchronously between primary and standby instance, standby instance can be promoted to the primary quickly which improves the RPO and RTO in case of AZ failure

• Read replicas can be created to provide read scaling

• Snapshots will be created from the standby instance without imposing any load on the primary instance

• Patching will be done on the standby instance first and then it will be promoted to primary instance

### Cons
• Multi AZ mode only provides a single availability zone resilience

• Multi AZ mode doesnot improve the performance of the database. 

• No Horizontal scaling for the application layer. 

• No resilience for the application. If the Availability Zone or the EC2 instance goes down, application is lost

#### How to deploy terraform stack
•	Download the terraform code from the github repo

•	cd wordpress-architecture-evolution

• Open rds_multi_az.tfvars file in a text editor and modify the varaibles values as per your requirements

•	terraform init

•	terraform validate

•	terraform apply --auto-approve --var-file=rds_multi_az.tfvars

You will be prompted to enter the password for the wordpress database that will be created as part of this stack

#### How to destroy the terraform stack
•	cd wordpress-architecture-evolution

•	terraform destroy --auto-approve --var-file=rds_multi_az.tfvars

You will be prompted to enter the password for the wordpress database


####Architecture
![Optional Text](../main/images/Wordpress_ec2_rds_multiaz.png)


## Single EC2 instance with EFS and RDS Multi AZ Architecture
In this architecture, database is hosted on RDS in multi AZ mode. Additionaly, an EFS file system is mounted on to the EC2 instance hosting the wordpress application. All application related files can be stored on the EFS file system which is regional resilient. In case of an availability zone failure, application instance can be recovered by bringing up an EC2 instance in an another availability zone and attaching it with the same EFS file system
### Pros
• Data stored on the EFS file system is regional resilient. EFS can be attached to EC2 instances on any availability zone by creating a mount target. This improves the availability of the application layer
###Cons
• No Horizontal scaling for the application layer.

• Though EFS provides resilience against an AZ failure, recovery(deployment of EC2 instance) is still manual.

#### How to deploy terraform stack
•	Download the terraform code from the github repo

•	cd wordpress-architecture-evolution

• Open ec2_rds_multiaz_efs.tfvars file in a text editor and modify the varaibles values as per your requirements

•	terraform init

•	terraform validate

•	terraform apply --auto-approve --var-file=ec2_rds_multiaz_efs.tfvars

You will be prompted to enter the password for the wordpress database that will be created as part of this stack

#### How to destroy the terraform stack
•	cd wordpress-architecture-evolution

•	terraform destroy --auto-approve --var-file=ec2_rds_multiaz_efs.tfvars

You will be prompted to enter the password for the wordpress database


###Architecture
![Optional Text](../main/images/Wordpress_ec2_EFS_rds_multiaz.png)


## EC2 Auto Scaling with EFS and RDS Multi AZ Architecture
In this architecture, application layer is hosted using auto scaling group of EC2 instance with an application load balancer to load balance the requests between the available application servers
###Pros
• Application layer can be scaled out or in based on the load on the EC2 instances

• Application is accessed using the load balancer DNS name which routes the requests to one of the EC2 instances hosting the application layer

• Load balancer checks the health of the EC2 instances to avoid routing the application requests to unhealthy instances

• Load balancer health checks will be used by the auto scaling group to replace the unhealthy instances

###Cons
• RDS Multi AZ mode only provides a single availability zone resilience

• RDS Multi AZ mode doesnot improve the performance of the database. 
#### How to deploy terraform stack
•	Download the terraform code from the github repo

•	cd wordpress-architecture-evolution

• Open asg_rds_multiaz_efs.tfvars file in a text editor and modify the varaibles values as per your requirements

•	terraform init

•	terraform validate

•	terraform apply --auto-approve --var-file=asg_rds_multiaz_efs.tfvars

You will be prompted to enter the password for the wordpress database that will be created as part of this stack

#### How to destroy the terraform stack
•	cd wordpress-architecture-evolution

•	terraform destroy --auto-approve --var-file=asg_rds_multiaz_efs.tfvars

You will be prompted to enter the password for the wordpress database
###Architecture
![Optional Text](../main/images/Wordpress_autoscaling_rds_multiaz.png)

## EC2 Auto Scaling with EFS and Aurora
In this architecture, the database layer is deployed using RDS aurora. Aurora provides 3 AZ resilience
###Pros
• Aurora provides 3 AZ resilience

#### How to deploy terraform stack
•	Download the terraform code from the github repo

•	cd wordpress-architecture-evolution

• Open asg_aurora_efs.tfvars file in a text editor and modify the varaibles values as per your requirements

•	terraform init

•	terraform validate

•	terraform apply --auto-approve --var-file=asg_aurora_efs.tfvars

You will be prompted to enter the password for the wordpress database that will be created as part of this stack

#### How to destroy the terraform stack
•	cd wordpress-architecture-evolution

•	terraform destroy --auto-approve --var-file=asg_aurora_efs.tfvars

You will be prompted to enter the password for the wordpress database


###Architecture
![Optional Text](../main/images/Wordpress_autoscaling_aurora.png)

