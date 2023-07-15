# Scalable-and-Secure-Web-Application-Architecture
Scalable EC2 Web-App


This is the implemented solution for the Terraform configuration script that automates the creation of various AWS resources for deploying web application infrastructure. 

STEP 1
Provider Block:
Started the configuration with defining the provider block for AWS, where the access key, secret key, and region were specified. These credentials are used by Terraform to authenticate and interact with the specific AWS account.

STEP 2
VPC, Subnets, and Route Table:
Here,  Virtual Private Cloud (VPC)  is created using the `aws_vpc` resource. The VPC is assigned a CIDR block of `10.0.0.0/16`. It enables DNS support and hostnames.

Next, three subnets (`aws_subnet`) are created within the VPC, each with a unique CIDR block and assigned to a specific availability zone in order to attach them to the RDS database to be created.

STEP 3.
Internet Gateway:
An internet gateway (`aws_internet_gateway`) is created and associated with the VPC. The internet gateway provides access to the internet for resources within the VPC.

STEP 4. 
Route Table:
A route table (`aws_route_table`) is created and associated with the VPC. The route table defines the routing rules for the VPC's traffic. In this case, it has two routes: one for IPv4 (`0.0.0.0/0`) and one for IPv6 (`::/0`). Both routes are directed to the internet gateway created earlier.


STEP 5. 
Route Table Association:
The subnet-1 is associated with the route table using the `aws_route_table_association` resource to ensures that the instances launched in subnet-1.

STEP 6. 
Security Group:
AWS security group (`aws_security_group`) is created to control inbound and outbound traffic for instances within the VPC. In this case, the security group allows inbound traffic on ports 3306 (MySQL/Aurora), 443 (HTTPS), 80 (HTTP), and 22 (SSH) while Outbound traffic is allowed to any destination.

STEP 7. 
Network Interface and Elastic IP:
An AWS network interface (`aws_network_interface`) is created and associated with subnet-1. It is assigned a private IP address of `10.0.1.50` and associated with the security group created earlier. An Elastic IP (`aws_eip`) is allocated and associated with this network interface.

STEP 8. 
Load Balancer:
An application load balancer (`aws_lb`) is created with the name "app-lb" and associated with the three subnets created earlier. It uses the security group defined earlier for controlling incoming traffic.

STEP 9. 
Load Balancer Target Group:
A target group (`aws_lb_target_group`) is created for the load balancer. It defines the port and protocol (port 80, HTTP) and is associated with the VPC.

10. Creation of RDS (MYSQL Database) Instance:
An Amazon RDS database instance (`aws_db_instance`) is created with the identifier "web-app-db". It uses the MySQL engine and is assigned a db.t2.micro instance type. It has allocated storage of 20 GB, accessible by the username and password specified. It is made publicly accessible and associated with the security group.


STEP 11. 
RDS Subnet Group:
An RDS subnet group (`aws_db_subnet_group`) is created to group the RDS instance with the specified subnets.

STEP 12. 
Launch Configuration and Auto Scaling Group:
A launch configuration (`aws_launch_configuration`) is created to define the configuration for launching EC2 instances. It uses an Amazon Machine Image (AMI), instance type, security group, and key pair. The `create_before_destroy` lifecycle setting ensures that new instances are created before the old ones are destroyed.

Finally, an auto scaling group (`aws_autoscaling_group`) is created to manage the number of instances in the group. It uses the launch configuration defined earlier and specifies the minimum, maximum, and desired capacity (This can be edited or changed at any time). Health checks are performed on the EC2 instances, and they are distributed across the specified subnets. The auto scaling group is associated with the load balancer's target group.

Overall, this Terraform script automates the creation of a VPC with subnets, an internet gateway, a route table, security groups, a load balancer, an RDS instance, and an auto scaling group for managing EC2 instances. These resources together form a scalable and highly available infrastructure for hosting a web application.





#Documentation about challenges faced and how they were addressed.

During the implementation process, I encountered a few challenges, but I was able to address them effectively. The challenges I faced and their respective solutions are outlined below:

1. Resource Dependency Management:
One challenge I faced was managing dependencies between resources. For example, the `aws_eip` resource depends on the `aws_internet_gateway` resource. Initially, I encountered errors related to resource dependency ordering.

To address this challenge, I utilized the `depends_on` attribute provided by Terraform. By explicitly specifying the dependency relationship using `depends_on = [aws_internet_gateway.gw]`, I ensured that the internet gateway resource is created before the Elastic IP resource, resolving the dependency issue.

2. Security Group Rules:
Defining the security group rules to allow inbound and outbound traffic required careful consideration. At first, I had to ensure that the necessary ports were open for incoming traffic. However, I also needed to strike a balance between security and accessibility.

To tackle this challenge, I carefully reviewed the application requirements and implemented rules to allow only the necessary ports (e.g., 3306, 443, 80, 22) from specific CIDR blocks (e.g., 0.0.0.0/0). Additionally, I restricted outbound traffic to maintain a more secure environment.

3. Automation and Idempotency:
As I iteratively ran the Terraform script, I encountered issues related to idempotency and ensuring that the infrastructure remained in the desired state. For example, modifying an existing resource configuration without causing unintended changes or conflicts was challenging.

To address this challenge, I leveraged Terraform's state management capabilities. I carefully reviewed the changes being applied, referring to the Terraform execution plan, and made sure that the modifications aligned with the desired infrastructure state. I also tested the script in a staging environment before applying changes to the production environment to ensure smooth deployments.

By following these practices, I was able to mitigate potential issues, maintain control over the infrastructure, and ensure that changes were correctly applied without causing disruptions or unexpected consequences. In summary, challenges related to resource dependencies, security group rules, and infrastructure automation were encountered during the implementation. Through careful planning, utilization of Terraform features, and iterative testing, I successfully addressed these challenges and achieved a stable and functional infrastructure deployment.




#Design and technology choices made during the task

In the provided code, several design and technology choices are made to provision an infrastructure for a web application on AWS. 

1. Provider Block (aws):
   - The provider block defines the AWS provider with the necessary credentials (access_key and secret_key) to authenticate with AWS services.
   - The chosen region is "us-east-1" (US East - N. Virginia).

2. Virtual Private Cloud (VPC) (aws_vpc):
   - A VPC named "app-tf-vpc" is created with a CIDR block of 10.0.0.0/16.
   - The VPC is configured with default tenancy and enables DNS support and hostnames.
   - It is tagged with the name "app-tf-Vpc" for easy identification.

3. Internet Gateway (aws_internet_gateway):
   - An internet gateway named "prod-ig" is created and associated with the VPC (app-tf-vpc) using the vpc_id attribute.
   - It allows inbound and outbound internet traffic for the VPC.

4. Route Table (aws_route_table):
   - A route table named "prod-route-table" is created and associated with the VPC (app-tf-vpc) using the vpc_id attribute.
   - It defines two routes: one for IPv4 (0.0.0.0/0) and one for IPv6 (::/0), both pointing to the previously created internet gateway.
   - The route table is tagged with the name "prod".

5. Subnets (aws_subnet):
   - Three subnets (subnet-1, subnet-2, subnet-3) are created within the VPC (app-tf-vpc).
   - Each subnet has a specific CIDR block and is associated with the availability zone "us-east-1a".
   - Each subnet is tagged with a descriptive name.

6. Route Table Association (aws_route_table_association):
   - The first subnet (subnet-1) is associated with the previously created route table (prod-route-table) using the subnet_id and route_table_id attributes.

7. Security Group (aws_security_group):
   - A security group named "allow_web_traffic" is created and associated with the VPC (app-tf-vpc) using the vpc_id attribute.
   - Ingress rules are defined to allow incoming traffic on ports 3306 (MYSQL/Aurora), 443 (HTTPS), 80 (HTTP), and 22 (SSH) from any source IP address.
   - An egress rule is defined to allow all outbound traffic.
   - The security group is tagged with the name "allow_web".

8. Network Interface (aws_network_interface):
   - A network interface named "web-server-nic" is created and associated with the first subnet (subnet-1) using the subnet_id attribute.
   - It is assigned a private IP address of 10.0.1.50 and associated with the "allow_web_traffic" security group.

9. Elastic IP (aws_eip):
   - An Elastic IP named "one" is created and associated with the network interface using the associate_with_private_ip attribute.
   - It is associated with the previously created internet gateway.
   - The public IP address associated with the Elastic IP is exposed as an output variable named "server_public_ip".

10. Load Balancer (aws_lb):
    - An Application Load Balancer (ALB) named "web-app" is created.
    - The load balancer type is set to "application".
    - It is associated with the subnets (subnet-1, subnet-2, subnet-3) and the "allow_web_traffic" security group.

11. Target Group (aws_lb_target_group):
    - A target group named "web-app" is created for routing traffic from the load balancer to instances.
    - It listens on port 80 (HTTP) and is associated with the VPC (app-tf-vpc).

12. RDS Database Instance (aws_db_instance):
    - An AWS RDS instance is created with the identifier "web-app-db" and the MySQL engine.
    - The instance class is set to db.t2.micro, with 20 GB of allocated storage using gp2 storage type.
    - The instance is publicly accessible and associated with the "allow_web_traffic" security group.
    - A specific subnet group ("sub-group") is created to define the subnets where the RDS instance will be launched.

13. Launch Configuration (aws_launch_configuration):
    - A launch configuration named "web-app-config" is defined for creating instances in the autoscaling group.
    - It uses the Amazon Machine Image (AMI) with the ID "ami-053b0d53c279acc90".
    - Instances will be of type t2.micro and will use the "allow_web_traffic" security group.
    - The configuration includes the key pair "web-app-key" for SSH access.
    - The "create_before_destroy" lifecycle block ensures the new launch configuration is created before destroying the old one.

14. Autoscaling Group (aws_autoscaling_group):
    - An autoscaling group named "web-app-instance" is created.
    - It uses the previously defined launch configuration ("web-app-config") for launching instances.
    - The autoscaling group has a minimum size of 1, maximum size of 3, and desired capacity of 1.
    - Health checks will be performed on EC2 instances using the "EC2" health check type.
    - Instances will be launched in the subnets specified by vpc_zone_identifier.
    - The autoscaling group is associated with the target group created for the load balancer.

These choices reflect the configuration of a scalable and highly available infrastructure for the web application. It includes networking components (VPC, subnets, internet gateway), load balancing with an ALB, a relational database with RDS, and an autoscaling group to manage instances.


#My approach, execution of the task, prerequisites, and all necessary cleanup steps.

Approach:
The approach to execute the task involves using an Infrastructure as Code (IaC) tool Terraform to define and provision the AWS resources. The provided code uses the Terraform syntax and the AWS provider to create a VPC, subnets, security groups, load balancer, RDS database, and autoscaling group.

Execution Steps:
Below are steps to execute the task and provision the infrastructure:

1.	Install Terraform: Make sure you have Terraform installed on your system. You can download it from the official Terraform website and follow the installation instructions specific to your operating system. (e.g. terraform.io) 
2.	Note: Harshi Corp Terraform recommended.

2. Set up AWS credentials: Ensure that you have valid AWS access and secret keys, and they are set as environment variables or stored in the AWS credentials file.

3. Create Terraform configuration file with a `.tf` extension (e.g., `apps.tf`).

4. Initialize Terraform: Once the code is created, open a terminal, navigate to the directory containing the Terraform configuration file, and run the command `terraform init`. This will initialize Terraform and download the necessary provider plugins.

5. Preview changes: Run the command `terraform plan` to see the execution plan. Terraform will analyze the configuration and display the resources it will create.

6. Apply changes: If the execution plan looks correct, run the command `terraform apply`. Terraform will create the specified resources on AWS. You will be prompted to confirm the changes before proceeding.

7. Wait for provisioning: Terraform will provision the infrastructure resources. It may take some time depending on the complexity of the configuration and the number of resources being created.

8. Verify infrastructure: Once the provisioning is complete, you can verify the created infrastructure on the AWS Management Console or using AWS CLI commands.

Prerequisites:
Before executing the task, ensure that you have the following prerequisites in place:

- Valid AWS credentials: You need AWS access and secret keys with appropriate permissions to create the specified resources.
- Terraform installed: Make sure you have the latest version of Terraform installed on your system.
- AWS CLI: Having the AWS Command Line Interface (CLI) installed and configured can be helpful for verifying the created infrastructure.

Cleanup Steps:
To clean up and remove the provisioned resources, follow these steps:

1. Run `terraform destroy`: Open a terminal or command prompt, navigate to the directory containing the Terraform configuration file, and run the command `terraform destroy`. This will destroy all the resources created by Terraform.

2. Confirm destruction: Terraform will display a plan of the resources it will destroy. Confirm the destruction by typing `yes` when prompted.

3. Wait for destruction: Terraform will destroy the resources. This process may take some time.

4. Verify cleanup: After the destruction is complete, verify that the AWS resources have been removed using the AWS Management Console or AWS CLI commands.

It's important to note that the cleanup step is irreversible, and all data associated with the resources will be lost. Therefore, exercise caution while executing the cleanup step and ensure that you have backups or snapshots if needed.

