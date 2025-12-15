# GoIT DevOps. RDS/Aurora + Jenkins + ArgoCD + EKS + Helm + Terraform

## Purpose:
Automate cloud infrastructure deployment for CI/CD using jenkins and allocating resources in AWS EKS. 
I use Terraform and Helm Charts.

### General structure Terraform
The code automates the creation of the basic AWS infrastructure for a DevOps project using a modular approach.

### S3 Backend
* Creates an S3 bucket to store Terraform state.
* Creates a DynamoDB table for state locking.
* Configures Terraform to use this backend (backend.tf file).
### VPC (Virtual Private Cloud)
* Creates a VPC with a specified CIDR block.
* Creates public and private subnets in three availability zones.
* Creates an Internet Gateway for public subnets.
* Creates a NAT Gateway for private subnets (via Elastic IP).
* Creates two route tables:
    * Public: routes traffic through the Internet Gateway.
    * Private: routes traffic through the NAT Gateway.
* Associates the corresponding subnets with the route tables.

### ECR (Elastic Container Registry)
* Creates an ECR repository to store Docker images.
* You can enable automatic image scanning when loading.

### EKS (Elastic Kubernetes Service)
* Sets up networking and IAM roles required for EKS operation.
* Provisions an EKS cluster for container orchestration.
* Configures worker nodes and node groups for scalable workloads.

### Jenkins
* Creates jenkins instance
* Creates seed-job
* Expects repository with app
* Pushes Docker image to ECR

### Argo-CD
* Pull Docker image from ECR
* Deploy to EKS

### RDS/Aurora
* creates Classic RDS Postgres or Aurora depending on flag `use_aurora`
* provides `parameters` for DB configuration

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [AWSCLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed
- Properly configured AWS provider credentials
- [kubectl]
- Properly configuret kubectl
- Before start provision infrastructure navigate to `init-s3`, perform `terraform init` and `terraform apply`. This will create S3 and DynamoDB table for backend
- Create EKS first using CLI `terraform apply -var-file="<vars>.tfvars" -var="enable_platform=false"`
- Provision all stack using `terraform apply -var-file="<vars>.tfvars" -var="enable_platform=true"`


## CLI Commands

### Configure profile

```sh
aws configure
```

With profile
```sh
aws configure --profile <name>
```

get RDS DB endpoint
```sh
aws rds describe-db-instances --profile <profile> --query "DBInstances[0].Endpoint" --output json
``` 

get Aurora endpoint 
```sh 
aws rds describe-db-clusters \
  --profile <profile> \
  --query "DBClusters[].{id:DBClusterIdentifier, writer:Endpoint, reader:ReaderEndpoint, port:Port}" \
  --output table
```

or get from terraform ouput
```sh
Outputs:

ECR_repository_url = <repository url>
jenkins_namespace = "jenkins"
jenkins_release = "jenkins"
oidc_provider_arn = <oidc provider ARN>
oidc_provider_url = <oidc provider URL>
postgres_endpoint = "<host>:5432"
```

### Kubectl
Update config
```sh
aws eks update-kubeconfig --region <region> --name <claster-name> --profile <profile>
```
Get jenkins UI on 8080 port
```sh
kubectl get pod -n jenkins
kubectl port-forward jenkins-0 8080:8080 -n jenkins
```

### Jenkins UI
* Navigate to jenkins http://localhost:8080/ and use credentials in config
* run `seed-job` using `Build Now` button and approve script if required (Manage Jenkins)
* run `goit-django-docker` using `Build Now` button and approve script if required (Manage Jenkins)
![Jenkins](./docs/jenkins.png)

### Argo CD
Get ArgoCD UI on 8443 port
```sh
kubectl get pods -n argocd
kubectl port-forward -n argocd svc/argo-cd-argocd-server 8443:443
```
Get password, username `admin`
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Argo-CD UI
* Navigate to Argo-CD http://localhost:8443/ and use credentials
* Create application
![Argo](./docs/argo.png)

### Grafana
Get grafana UI on 3000 port
```sh
kubectl -n monitoring port-forward svc/kube-prometheus-grafana 3000:80
```

## Common Terraform Commands

### 1. `terraform init`
Initializes a Terraform working directory. Downloads required providers and sets up the backend.

```sh
terraform init
```

### 2. `terraform plan`
Creates an execution plan, showing what actions Terraform will perform.

```sh
terraform plan
```

### 3. `terraform apply`
Applies the changes required to reach the desired state of the configuration.

```sh
terraform apply
```

### 4. `terraform destroy`
Destroys the infrastructure managed by Terraform.

```sh
terraform destroy
```

## Useful Links

- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform CLI Commands](https://developer.hashicorp.com/terraform/cli/commands)
