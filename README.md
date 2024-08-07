# AWS CI/CD Pipeline Deployment with Terraform

## Overview

This project aims to deploy a complete CI/CD pipeline in AWS using Terraform. The pipeline integrates several tools including GitLab, SonarQube, Jenkins, Grafana, and Nexus, and automates the deployment of a simple "Hello World" Node.js application. The infrastructure is managed as code using Terraform, ensuring consistent and repeatable deployments.

## Project Structure

```Terraform (Dossier aws-terraform-project-master)
├── data-sources.tf
├── EC2 (Instance.tf)
│   ├── grafana
│       │ ────── grafana-resource.tf
│       │ ────── install-grafana.sh
│   ├── nexus
│       │ ──────  nexus-resource.tf
│       │ ────── install-nexus.sh
│   ├── sonarqube
│       │ ────── sonarqube-resource.tf
│       │ ────── install-sonarqube.sh
│   ├── GitLab_Server
│       │ ────── gitlab-resource.tf
│       │ ────── 
│   ├── Jenkins
│        │ ────── jenkins-resource.tf
│        │ ────── install-jenkins.sh
├── key_pair.tf (to connect to VMs to upload scripts and run bash cmd)
├── main.tf 
├── output.tf
├── security-group.tf
├── subnet.tf
└── variables.tf
```

## Components

### Infrastructure

- **VPC**: Default VPC for isolated network environment.
- **Subnets**: Three public subnets for high availability across different availability zones.
- **Security Groups**: Configured for access control and traffic management.
- **EC2 Instances**: Hosts for GitLab, Jenkins, and Nexus.
- **Kubernetes**: Manages deployments for SonarQube, Grafana, and Nexus using Helm charts.

### Tools

- **GitLab**: Version control and CI/CD management.
- **Jenkins**: Continuous integration and deployment.
- **SonarQube**: Code quality analysis.
- **Nexus**: Artifact repository management.
- **Grafana**: Monitoring and observability.

### Architecture Diagram Description

1. **AWS VPC**:

   - Contains three public subnets for high availability across different availability zones (eu-west-3a, eu-west-3b, eu-west-3c).

2. **Subnets**:

   - **Public Subnet 1**: Hosts Jenkins, Nexus, SonarQube, Grafana.
   - **Public Subnet 2**: Hosts GitLab .
   

3. **Security Groups**:

   - **GitLab Security Group**: Allows traffic on ports 80 or gitlab.veyagroupe.com.
   - **Jenkins Security Group**: Allows traffic on ports 8080 and 22.
   - **Nexus Security Group**: Allows traffic on ports 8081 and 22.
   - **SonarQube Security Group** : Allows traffic on ports 9000 and 22
   - **Grafana Security Group** : Allows traffic on ports 3000 and 22, **Prometeus on GitLab** : Allows traffic on ports 3000 and 22

4. **EC2 Instances**:

   - **Jenkins Nexus, SonarQube, Grafana Servers**: Deployed in Public Subnet 1.
   - **GitLab Server**: Deployed in Public Subnet 2.


5. **Kubernetes Cluster**:

   - Manages containerized applications for the web site

6. **Load Balancers**:

   - Manage external access to web site.

7. **Communication Flow**:
   - **Developers** push code to **GitLab**.
   - **GitLab** triggers **Jenkins** for CI/CD pipeline.
   - **Jenkins** uses **SonarQube** for code quality analysis and **Nexus** for storing artifacts.
   - **Grafana** monitors the entire system.

```plaintext
                                    +-------------------+
                                    |       AWS VPC     |
                                    |-------------------|
                                    |                   |
                 +------------------>    Internet       |
                 |                  |                   |
                 |                  +-------------------+
                 |                           |
                 |                           |
                 |                           |
        +--------v--------+          +---------v---------+        +---------v---------+
        |   Public Subnet 2 |        |   Public Subnet 1 |        |   Public Subnet 1 |
        |-------------------|        |-------------------|        |-------------------|
        |                   |        |                   |        |                   |
        |  +-------------+  |        |  +-------------+  |        |  +-------------+  |
        |  |    GitLab   |  |        |  |   Jenkins   |  |        |  |Nexus,Grafana,Sonarqube    
        |  +-------------+  |        |  +-------------+  |        |  +-------------+  |
        |                   |        |                   |        |                   |
        +--------+----------+        +---------+---------+        +---------+---------+
                                            |                          
                                            |                          
                                            |                          
                                            |                          
                                            |                           
                                            |                           
                                      +-------v-------+          
                                      |  Kubernetes   |          
                                      | |  SiteWeb  | |           
                                      | +-----------+ |           
                                      |               |                          
                                      +-------+-------+                                                                                 
                                            |
                                            |                           
                                      +-------v-------+           
                                      | Load Balancer |           
                                      +---------------+           
```

### Architecture Diagram Explanation

1. **AWS VPC**:

   - The entire infrastructure is hosted within an AWS Virtual Private Cloud (VPC), ensuring a secure and isolated network environment.

2. **Subnets**:

   - **Public Subnet 1**: Hosts Jenkins, Nexus, SonarQube, Grafana.
   - **Public Subnet 2**: Hosts GitLab .

3. **Security Groups**:

   - **GitLab Security Group**: Allows traffic on ports 80 or gitlab.veyagroupe.com.
   - **Jenkins Security Group**: Allows traffic on ports 8080 and 22.
   - **Nexus Security Group**: Allows traffic on ports 8081 and 22.
   - **SonarQube Security Group** : Allows traffic on ports 9000 and 22
   - **Grafana Security Group** : Allows traffic on ports 3000 and 22, **Prometeus on GitLab** : Allows traffic on ports 3000 and 22
     
4. **EC2 Instances**:

   - **GitLab Server**: Deployed in Public Subnet 2. Manages source code and CI/CD pipelines.
   - **Jenkins Server**: Deployed in Public Subnet 1. Automates builds, testing, and deployments.
   - **Nexus Server**: Deployed in Public Subnet 3. Manages build artifacts and dependencies.
   - **Grafana** monitors the overall system health and performance, providing observability and insights.
   - **Sonarqube** Manage and analyse the qualitu of the code.



5. **Kubernetes Cluster**:

   - Hosts containerized applications such as SonarQube for code quality analysis and Grafana for monitoring. Nexus is also managed within the Kubernetes cluster for artifact repository management.

6. **Load Balancers**:
   - Load balancers ensure that SonarQube, Grafana, and Nexus services are accessible from the internet, distributing traffic and providing high availability.

### Communication Flow

- **Developers** push code changes to **GitLab**.
- **GitLab** triggers the **Jenkins** pipeline for continuous integration and deployment.
- **Jenkins** performs builds, and runs tests, and uses **SonarQube** for code quality analysis.
- Build artifacts are stored in **Nexus**.
- **Grafana** monitors the overall system health and performance, providing observability and insights.
- **Sonarqube** Manage and analyse the qualitu of the code.


## Getting Started

### Prerequisites

- AWS account with appropriate permissions.
- Terraform installed on your local machine.
- SSH key pair for accessing EC2 instances.
- GitLab personal access token.

### Configuration

1. **Clone the repository:**

   ```bash
   git clone http://gitlab.veyagroupe.com/root/sanavenunye.git
   cd project_sanavenunye\sanavenunye
   git add .
   git commit -m "name_of_changement"
   git push -u origin main
   
   ```

2. **Configure AWS and GitLab tokens:**

   Ensure you have your AWS credentials and GitLab personal access token ready. Update the `variables.tf` file with your token path:

   ```hcl
   variable "gitlab_token_path" {
     description = "The path to the file containing the GitLab personal access token"
     type        = string
     default     = "/path/to/your/gitlab/token"
   }
   ```


### Deployment

1. **Initialize Terraform:**

   ```bash
   terraform init
   ```

2. **Apply Terraform configuration:**

   ```bash
   terraform apply
   ```

   Confirm the apply action by typing `yes` when prompted. This will provision the necessary infrastructure and deploy the CI/CD tools.

### Outputs

After successful deployment, Terraform will output essential information such as:

- GitLab server IP address
- Instance IDs and public IPs
- AWS region
- Subnet IDs
- GitLab root password
- Jenkins root password

These outputs can be found in the `output.tf` file and will be displayed in the terminal.

## Tools Overview

### GitLab

- **Role**: Manages source code and CI/CD pipelines.
- **Deployment**: Provisioned on an EC2 instance with Docker.
- **Configuration**: Accessible via the public IP provided in the Terraform output.

### Jenkins

- **Role**: Automates builds, testing, and deployments.
- **Deployment**: Runs in a Docker container on an EC2 instance.
- **Configuration**: Configured to trigger builds based on GitLab changes.

### SonarQube

- **Role**: Performs static code analysis to ensure code quality.
- **Deployment**: Deployed on a Kubernetes cluster.
- **Configuration**: Accessible via a LoadBalancer service.

### Nexus

- **Role**: Manages build artifacts and dependencies.
- **Deployment**: Deployed on a Kubernetes cluster.
- **Configuration**: Accessible via a LoadBalancer service.

### Grafana

- **Role**: Provides monitoring and observability.
- **Deployment**: Deployed on a Kubernetes cluster.
- **Configuration**: Accessible via a LoadBalancer service.

## Challenges and Solutions

### Challenges

- **Resource Dependencies**: Managing the order of resource creation.
- **Networking Issues**: Configuring subnets and security groups.
- **Integration Issues**: Ensuring seamless operation of all tools.
- **Provisioning Delays**: Long setup times for instances and Kubernetes.

### Solutions

- **Resource Dependencies**: Used Terraform's `depends_on` to manage order.
- **Networking Issues**: Carefully planned subnet CIDR blocks and configuring security group rules appropriately.
- **Integration Issues**: Thorough testing and configuration adjustments.
- **Provisioning Delays**: Used optimized AMIs and efficient provisioning scripts.

## Conclusion

This project successfully deploys a CI/CD pipeline in AWS using Terraform, integrating GitLab, Jenkins, SonarQube, Nexus, and Grafana. The setup automates the deployment process, improves code quality, and provides comprehensive monitoring. Future improvements could include further automation and scaling enhancements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
