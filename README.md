# Terraform AWS Infrastructure Project

This repository contains a modular Terraform configuration that deploys a basic AWS infrastructure including:

- **S3 backend for Terraform state storage**
- **DynamoDB table for state locking**
- **Custom VPC with public and private subnets**
- **ECR repository for container images**
- **EC2 instance stored inside the VPC**

---

## 📁 Project Structure

```
project/
├── main.tf                # Root configuration & module calls
├── outputs.tf             # Root outputs
├── variables.tf           # (optional root variables)
├── backend.tf             # S3 backend configuration
├── modules/
│   ├── s3-backend/
│   │   ├── s3.tf
│   │   ├── dynamodb.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │
│   ├── vpc/
│   │   ├── vpc.tf
│   │   ├── routes.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │
│   ├── ecr/
│   |   ├── ecr.tf
│   |   ├── variables.tf
│   |   ├── outputs.tf
|   |
|   |
|   └── eks/
|       ├── eks.tf
|       ├── variables.tf
|       ├── outputs.tf
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── hpa.yaml
│       │   ├── configmap.yaml
│       │   └── secret.yaml
|       |   
│       ├── values.yaml
|       ├── values-secret.yaml  # gitignored
│       └── Chart.yaml
│
└── README.md             # Project documentation
```

---

## 🚀 How to Deploy

### 1. Initialize Terraform

```
terraform init
```

This downloads providers, configures the backend, and prepares modules.

### 2. Show the execution plan

```
terraform plan
```

This displays what Terraform will create or modify.

### 3. Apply the configuration

```
terraform apply
```

This creates all AWS resources.

### 4. Destroy the infrastructure

```
terraform destroy
```

This removes all created AWS resources.

---

## 📦 Module Descriptions

### 🔹 **s3-backend module**

Creates the backend infrastructure for Terraform state management:

- S3 bucket for storing `terraform.tfstate`
- Versioning enabled for recovery of old state versions
- Bucket ownership controls (BucketOwnerEnforced)
- DynamoDB table for state locking (prevents parallel modifications)

Outputs:

- `s3_bucket_name`
- `dynamodb_table_name`

---

### 🔹 **vpc module**

Creates a complete Virtual Private Cloud with networking components:

Resources created:

- Main VPC
- 3 public subnets
- 3 private subnets
- Internet Gateway
- Public route table + route associations

Outputs:

- `vpc_id`
- `public_subnets`
- `private_subnets`
- `internet_gateway_id`

---

### 🔹 **ecr module**

Creates an Amazon Elastic Container Registry (ECR) repository:

- Repository name configurable via `ecr_name`
- Optional image scan on push

Outputs:

- `ecr_url`

---

## eks module

Deploys a fully functional EKS cluster.

**Resources:**

- IAM roles for cluster and worker nodes
- EKS control plane
- Managed Node Group
- Networking integration with VPC subnets

**Outputs:**

- `eks_cluster_name`
- `eks_cluster_endpoint`
- `node_role_arn`

---

# Docker & ECR Workflow (Django Application)

### 1. Build the Docker image

```bash
docker build -t django-app:latest .
```

### 2. Authenticate Docker to ECR

```bash
aws ecr get-login-password --region eu-central-1   | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com
```

### 3. Tag and push the image

```bash
docker tag django-app:latest   <AWS_ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest

docker push   <AWS_ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/lesson-5-ecr:latest
```

---

# Connect kubectl to EKS

```bash
aws eks --region eu-central-1 update-kubeconfig --name <cluster_name>
kubectl get nodes
```

---

# Helm Chart (Django Application)

### Deployment

Runs the Django container from ECR with environment variables from ConfigMap and Secret.

### Service (LoadBalancer)

Exposes the Django application externally.

### Horizontal Pod Autoscaler

Scales between **2 and 6 pods** when CPU exceeds **70%**.

### ConfigMap

Stores non-sensitive environment variables.

### Secret (gitignored)

Stores sensitive data:

- Django secret key
- Database password

### values.yaml

Defines image configuration, service settings, autoscaler configuration, and environment variables.

---

# Notes

- All resources are deployed in **eu-central-1**.
- `secret.yaml` is excluded from Git for security.
- For deployment overrides, `values-secret.yaml` can be used (also gitignored).
- Terraform backend requires the S3 bucket to exist before enabling it.
- EKS access requires AWS CLI and kubectl installed.

---

# Project Ready

This README includes full documentation for:

- Terraform infrastructure
- VPC, S3, DynamoDB, ECR
- EKS cluster
- Docker image workflow
- Helm chart for Django deployment
- kubectl integration