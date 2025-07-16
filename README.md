# **Secure Web App with Public Proxy \+ Private Backend on AWS using Terraform**

This project deploys a secure, highly-available, and multi-tiered web application infrastructure on AWS using Terraform. The architecture is designed for security and scalability, featuring a public-facing reverse proxy layer that forwards traffic to a completely private backend application layer.

This repository reflects the final, working state of the project after a comprehensive debugging process that addressed common infrastructure-as-code challenges, including provisioner failures, security group misconfigurations, and load balancer health check issues.

## **Architecture**

(Note: You would replace the above URL with a link to your uploaded architecture diagram)

* **VPC:** A custom Virtual Private Cloud (VPC) with a 10.0.0.0/16 CIDR block to provide network isolation.  
* **Public Subnets (x2):** Deployed across two Availability Zones for high availability. These subnets host the Nginx reverse proxy EC2 instances.  
* **Private Subnets (x2):** Also deployed across two Availability Zones. These subnets host the private backend Node.js application servers, which are not accessible from the internet.  
* **Internet Gateway:** Allows resources in the public subnets to communicate with the internet.  
* **NAT Gateway:** Deployed in a public subnet to allow instances in the private subnets to initiate outbound internet connections (e.g., for software updates) without being directly exposed.  
* **Load Balancers:**  
  * **Public Application Load Balancer:** Faces the internet and distributes incoming HTTP traffic across the Nginx proxy instances.  
  * **Internal Application Load Balancer:** Receives traffic from the Nginx proxies and distributes it across the private backend application instances.  
* **Security Groups:** A set of granular firewall rules that strictly control traffic between the different layers of the application.

## **Prerequisites**

Before you begin, ensure you have the following installed and configured:

1. **Terraform:** [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)  
2. **AWS CLI:** [Install and Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)  
3. **AWS Account:** An active AWS account with permissions to create the resources defined in this project.  
4. **EC2 Key Pair:** An existing EC2 Key Pair in your target AWS region, with the private key file (.pem) saved on your local machine.

## **Deployment Steps**

### **1\. Initial Setup**

First, clone this repository and set up the remote backend for Terraform state management.

a. Create S3 Bucket for Terraform State  
Choose a globally unique name for your bucket and create it.  
aws s3 mb s3://your-unique-name-tfstate-project \--region us-east-1

b. Enable Versioning on the Bucket

aws s3api put-bucket-versioning \--bucket your-unique-name-tfstate-project \--versioning-configuration Status=Enabled \--region us-east-1

c. Create DynamoDB Table for State Locking

aws dynamodb create-table \\  
    \--table-name terraform-state-lock \\  
    \--attribute-definitions AttributeName=LockID,AttributeType=S \\  
    \--key-schema AttributeName=LockID,KeyType=HASH \\  
    \--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \\  
    \--region us-east-1

d. Configure the Backend File  
Open the backend.tf file and replace your-unique-name-tfstate-project with the bucket name you just created.  
e. Configure Variables  
Create a file named terraform.tfvars in the root of the project and add the following content, replacing the placeholder values with your own:  
\# The name of your EC2 Key Pair as it appears in the AWS Console  
ssh\_key\_name \= "your-ec2-key-pair-name"

\# The local file path to the corresponding private key (.pem) file  
private\_key\_path \= "\~/.ssh/your-ec2-key-pair-name.pem"

\# Your computer's public IP address for secure SSH access  
my\_ip        \= "YOUR.PUBLIC.IP.ADDRESS/32"

### **2\. Run Terraform**

Now, you can deploy the infrastructure.

a. Initialize Terraform  
This will download the necessary provider plugins and configure the backend.  
terraform init \-upgrade

b. Create a New Workspace  
All work must be done in a dev workspace.  
terraform workspace new dev

c. Plan the Deployment  
Review the changes Terraform will make to your infrastructure.  
terraform plan \-var-file="terraform.tfvars"

d. Apply the Configuration  
Build all the resources on AWS. Type yes when prompted.  
terraform apply \-var-file="terraform.tfvars"

## **Testing the Results**

After successfully running terraform apply with the final corrected code, you can verify that the entire infrastructure is working as expected by following these steps.

### **1\. Find the Public Load Balancer URL**

Terraform provides the public DNS name of your load balancer as an output.

* In your terminal, run the following command from the root directory of your project:  
  terraform output public\_alb\_dns\_name

* This will print a URL to your screen, which will look something like this:  
  secure-app-1234567890.us-east-1.elb.amazonaws.com

### **2\. Test the Endpoint in Your Browser**

* Copy the URL you obtained from the previous step.  
* Paste it into your web browser's address bar and press Enter.

### **3\. Verify the Result**

* **Expected Result:** You should now see the "Hello World" message from the sample Node.js application that was deployed to your private backend instances.**Hello World**  
* **What this confirms:**  
  * The public load balancer is active and accepting traffic.  
  * The Nginx proxy instances are healthy and correctly forwarding requests.  
  * The internal load balancer is healthy and correctly forwarding requests.  
  * The backend instances successfully installed Node.js and started the application via the user\_data script.  
  * All security group rules are correctly configured to allow traffic to flow through every layer of the architecture.

### **4\. How to Troubleshoot (If Necessary)**

If you do not see the "Hello World" page, the most likely place to check for issues is the health status of the load balancer targets.

* **Check Target Groups in AWS:**  
  1. Go to the **EC2 Console** in your AWS account.  
  2. In the left navigation pane, scroll down to "Load Balancing" and click on **Target Groups**.  
  3. You will see two target groups: secure-app-public-tg and secure-app-private-tg.  
  4. Click on each one and then select the **Targets** tab.  
  5. The **Health status** for all registered instances in both groups should be **healthy**.  
* Check the Startup Log:  
  If the private targets are unhealthy, you can check the log file created by the startup script.  
  1. SSH into one of the public proxy instances.  
  2. From the proxy, SSH into one of the private backend instances using its private IP address.  
  3. Run the command: cat /var/log/user-data.log  
  4. This will show you the complete output of the startup script, which can help identify any errors during the npm install or application start phases.

## **Cleanup**

To avoid ongoing AWS charges, destroy all the resources you created when you are finished.

terraform destroy \-var-file="terraform.tfvars"

**Note:** The S3 bucket and DynamoDB table created manually for the Terraform backend will not be deleted by this command. You must delete them manually from the AWS console if you no longer need them.
