# Gatus Monitoring Platform on AWS (ECS Fargate, Terraform, CI/CD)

![AWS](https://img.shields.io/badge/AWS-ECS%20Fargate-orange)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-blue)
![Docker](https://img.shields.io/badge/Docker-Containers-blue)
![OIDC](https://img.shields.io/badge/Security-OIDC-green)
![IAM](https://img.shields.io/badge/IAM-Least%20Privilege-red)

![docker-build-push](https://github.com/hasanenv/ecs-fargate-platform/actions/workflows/docker-build-push.yml/badge.svg?branch=main)
![terraform-apply](https://github.com/hasanenv/ecs-fargate-platform/actions/workflows/terraform-apply.yml/badge.svg?branch=main)
![manual-destroy](https://github.com/hasanenv/ecs-fargate-platform/actions/workflows/manual-destroy.yml/badge.svg?branch=main)

<p align="center">
  <img src="assets/ecs-diagram.png" width="1300">
</p>

---

## Table of Contents

- [Overview](#overview)
- [Design Priorities](#design-priorities)
- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [CI/CD Workflow](#cicd-workflow)
- [Containers & Runtime](#containers--runtime)
- [IAM & Least Privilege Access](#iam--least-privilege-access)
- [Terraform & State Management](#terraform--state-management)
- [Observability](#observability)
- [Key Technical Decisions](#key-technical-decisions)
- [Known Limitations and Future Improvements](#known-limitations-and-future-improvements)
- [Quick Start](#quick-start)
- [Teardown](#teardown)

## Overview

A **secure container platform** on AWS built with **ECS Fargate**, **Terraform** and **GitHub Actions**. The workload is [Gatus](https://github.com/TwiN/gatus), an open source health monitoring and status page tool.

The platform focuses on **infrastructure design, security, and deployment automation**, with an emphasis on architectural clarity, safe delivery, and operational correctness.

## Design Priorities

- Infrastructure defined as code
- Secure CI/CD using OIDC, eliminating need for long-lived credentials
- Principle of least privilege applied consistently
- Deployments based on immutable container images
- Explicit availability and cost tradeoffs

## Architecture Overview

The platform runs in a custom VPC spanning two Availability Zones:

- Public subnets hosting an Application Load Balancer (multi-AZ) and a standard zonal NAT Gateway
- Private subnets running ECS Fargate tasks
- HTTPS and HTTP redirect enforced using ACM and Route 53
- Runtime configuration stored in **SSM Parameter Store**
- Centralised logging via CloudWatch
- Provisioned and managed through Terraform

### Gatus UI Running Behind ALB

<p align="center">
  <img src="assets/gatus-demo.gif" width="1200">
</p>

## Repository Structure

```
ecs-fargate-platform/
├── .github/
│   └── workflows/
│       ├── docker-build-push.yml  # Build, scan, push image to ECR, store tag in SSM
│       ├── terraform-apply.yml    # Manual apply of the application stack
│       └── manual-destroy.yml     # Manual destroy of the application stack with plan step
├── app/
│   └── gatus/                     # Upstream Gatus source (cloned)
│       ├── Dockerfile             # Multi-stage, non-root image build
│       ├── entrypoint.sh          # Container entrypoint
│       └── ...
├── assets/
│   ├── ecs-diagram.png
│   └── gatus-demo.gif      
│   
├── infra/
│   ├── bootstrap/                 # Separate root and state: CI/CD roles and ECR repository
│   │   ├── .terraform.lock.hcl
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   ├── config/
│   │   └── config.yaml            # Gatus configuration
│   ├── modules/
│   │   ├── acm/
│   │   ├── alb/
│   │   ├── cicd-iam/              # CI/CD roles and policies (used by bootstrap)
│   │   ├── ecr/                   # ECR repository (used by bootstrap)
│   │   ├── ecs/
│   │   ├── iam/                   # ECS task execution role
│   │   ├── route53/
│   │   ├── security-groups/
│   │   └── vpc/
│   ├── .terraform.lock.hcl
│   ├── data.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── ssm.tf
│   └── variables.tf
├── .gitignore
├── .grype.yaml                    # Accepted vulnerabilities with justification
├── LICENSE
└── README.md
```

## CI/CD Workflow

This project uses three GitHub Actions workflows with clear separation of responsibility.

### Docker Build and Push
- Runs on push and PRs to main when app/** changes.
- Builds and scans the container image (Anchore scan with high severity cut off)
- Prints high and critical findings to the log before the scan gates the build
- Authenticates to AWS via OIDC and pushes SHA-tagged image to ECR
- Stores the image tag in **SSM Parameter Store**

> [!IMPORTANT]
> Two findings are explicitly ignored via `.grype.yaml`, each with a justification:
> - [CVE-2026-22184](https://nvd.nist.gov/vuln/detail/CVE-2026-22184#vulnCurrentDescriptionTitle) only affects the `untgz` utility of the `zlib` library, which is not used by our application.
> - CVE-2026-85091 is a zlib heap overflow in the `gzprintf` and `gzvprintf` path after a stalled non-blocking `gzwrite`. Gatus is a Go application and does not use the zlib `gz*` API, and no fixed version is available upstream.

### Terraform Apply (Manual)
- Triggered manually via GitHub Actions
- Applies changes to the application stack using Terraform
- Pulls current image tag from SSM if no new image was deployed
- Uses OIDC with no long lived credentials

### Terraform Destroy (Manual)
- Triggered manually via GitHub Actions
- Creates a destroy plan before execution
- Uses a dedicated IAM role scoped for destructive actions
- Tears down the application stack in a controlled manner. The CI/CD roles and ECR repository live in the bootstrap root and are never part of this destroy

## Containers & Runtime

- Multi-stage Docker build strips out tooling and reduces image size
- Reduced final image size by ~40% (from ~120 MB to ~75 MB)
- Explicit non-root user enforcing least privilege at runtime
- Docker Hardened Images Alpine base (`dhi.io/alpine-base`) used to minimise runtime footprint and improve security
- Reduced attack surface by removing unused binaries, package managers, and shells

## IAM & Least Privilege Access

> [!NOTE]
> IAM policies are intentionally scoped to the minimum permissions required for each role.

Access control is a foundational part of the platform design:

- Three dedicated CI/CD roles (image build and push, apply, destroy), each with its own scoped policy and defined in the bootstrap root
- The apply role is limited to day two changes and cannot create core infrastructure
- An explicit Deny on the destroy policy blocks deletion or modification of the CI/CD roles
- Separate ECS task execution role limited to runtime needs, managed with the application stack
- All IAM configuration managed in Terraform to prevent drift

## Terraform & State Management

- Two Terraform roots with separate state: `infra/bootstrap` (CI/CD roles and ECR repository) and `infra` (the application stack)
- Modular structure for clarity and reuse
- Remote Terraform state stored in S3
- State locking via DynamoDB
- Domain name and backend settings are variables, so nothing account specific is hard coded

## Observability

- ECS task logs shipped to CloudWatch
- Log groups created and managed via Terraform
- No manual logging configuration or console setup required

## Key Technical Decisions

### Bootstrap stack separate from the application stack

The CI/CD roles and the ECR repository live in their own Terraform root with a separate state key. An earlier layout kept them in the same state as the application, and the destroy workflow deleted the role it was running as within seconds. Its credentials died mid-run, leaving resources behind, an unsaved state and a stale state lock. With the split, `manual-destroy` can only reach the application stack, so it cannot remove the identity it runs under. The explicit Deny on role deletion is a second line of defence. A side benefit is that the ECR repository and its images survive a destroy, so a redeploy does not need a rebuild.

### Fargate over EC2

Fargate removes node patching and capacity management. For a single small service, the operational overhead of running EC2 nodes outweighs any cost saving.

### Single zonal NAT Gateway

The ALB spans two Availability Zones, so customer facing ingress stays available. A single NAT Gateway handles outbound traffic only, which keeps cost down at the price of an AZ-level single point of failure for outbound traffic. Acceptable for this project, not for production.

### Image tag stored in SSM Parameter Store

The Docker pipeline writes the SHA-tagged image reference to SSM. Terraform reads it on apply, so infrastructure changes deploy the current image without needing a new build.

### Separate IAM role for destroy

Destructive actions use a dedicated, scoped role, so the day to day pipeline role cannot tear down infrastructure.

## Known Limitations and Future Improvements

- **Manual bootstrap.** The state backend and GitHub OIDC provider are created by hand, the bootstrap root is applied locally, and the first full apply of the application stack runs locally because the pipeline role only has day two permissions
- **State locking** uses DynamoDB. Terraform 1.10 and later supports native S3 locking (`use_lockfile`), which would remove the DynamoDB table. The pipelines currently pin Terraform 1.5.5, so this needs a version bump
- **Pipeline apply noise.** `terraform-apply` reports two in-place updates (the SSM config parameter and the ACM certificate) on every run with no visible difference
- **Terraform modules** repeat resources in places. Heavier use of `for_each` and maps would reduce repetition and improve scalability
- **NAT Gateway design** should be revisited to evaluate regional vs single-AZ NAT Gateways, following recent AWS changes
- **Single environment** only. Environment-based workflows (for example dev and prod) with promotion between stages would be the next step
- **Observability** stops at logs. CloudWatch alarms and metrics would extend it

## Quick Start

### Prerequisites

- AWS account, plus admin level credentials available locally for the one-off bootstrap steps. Everything after that runs through GitHub Actions with OIDC
- Your own domain with a public Route 53 hosted zone in the same account. The app is published at `tm.<your-domain>`. A subdomain delegated to Route 53 also works: create a public hosted zone for it and add its four name servers as `NS` records at your DNS provider
- An S3 bucket and DynamoDB table for Terraform state, created in step 1
- GitHub OIDC identity provider in IAM (`token.actions.githubusercontent.com`). The CI/CD roles trust it but Terraform does not create it
- Docker Hardened Images account with pull access to `dhi.io/alpine-base`, the runtime base image
- Terraform >= 1.5 (the pipelines pin 1.5.5), AWS CLI and Git installed
- GitHub repository forked from this one

### 1. Create the State Backend and OIDC Provider

```bash
aws s3api create-bucket --bucket <your-state-bucket> --region <your-region> \
  --create-bucket-configuration LocationConstraint=<your-region>
aws s3api put-bucket-versioning --bucket <your-state-bucket> \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name <your-lock-table> \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region <your-region>

aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

> [!NOTE]
> AWS no longer validates the thumbprint for GitHub's OIDC provider, so the value does not matter. For `us-east-1`, omit the `--create-bucket-configuration` flag.

### 2. Configure GitHub Actions

Add the following to your repository under Settings > Secrets and Variables > Actions.

**Variables:**
- `AWS_ACCOUNT_ID` (e.g. `123456789012`)
- `AWS_REGION` (e.g. `eu-west-2`)
- `AWS_REPO` (must be `gatus-repo`, the ECR repository name is fixed in code)
- `OWNER` (e.g. `your name`)
- `DOMAIN_NAME` (e.g. `example.com`, the Route 53 hosted zone name)
- `TF_STATE_BUCKET` (e.g. `my-tf-state`)
- `TF_LOCK_TABLE` (e.g. `terraform-state-lock`)
- `AVAILABILITY_ZONES` (e.g. `["eu-west-2a","eu-west-2b"]`)
- `VPC_CIDR` (e.g. `10.0.0.0/16`)
- `PUBLIC_SUBNET_CIDRS` (e.g. `["10.0.1.0/24","10.0.2.0/24"]`)
- `PRIVATE_SUBNET_CIDRS` (e.g. `["10.0.3.0/24","10.0.4.0/24"]`)
- `DHI_IO_USERNAME` (your Docker Hardened Images username)

**Secrets:**
- `DHI_IO_TOKEN` (Docker Hardened Images access token)

> [!IMPORTANT]
> The domain, availability zone and CIDR variables must match the values in `infra/terraform.tfvars` (step 5). If they differ, `terraform-apply` plans to replace resources such as the private subnets and fails partway.

> [!NOTE]
> `AWS_REGION` sets the provider region, the backend region and the ECR registry URL, so the state bucket and lock table must live in that region.

> [!NOTE]
> The VPC module creates exactly two public and two private subnets, so each list must contain exactly two entries. The lists are passed to Terraform as `TF_VAR_*` environment variables, so use HCL list syntax as shown.

### 3. Bootstrap the CI/CD Roles and ECR Repository

The three workflows assume IAM roles, and the Docker workflow pushes to an ECR repository. Both live in the bootstrap root, which has its own state and is applied once, locally.

Create `infra/bootstrap/terraform.tfvars` (gitignored):

```hcl
aws_account_id  = "123456789012"
aws_region      = "eu-west-2"
github_repo     = "your-org/ecs-fargate-platform"
owner           = "your name"
tf_state_bucket = "my-tf-state"
tf_lock_table   = "terraform-state-lock"
```

```bash
cd infra/bootstrap
terraform init \
  -backend-config="bucket=<your-state-bucket>" \
  -backend-config="key=bootstrap/terraform.tfstate" \
  -backend-config="region=<your-region>" \
  -backend-config="dynamodb_table=<your-lock-table>"
terraform apply
```

This creates `docker-build-push-role-2`, `terraform-apply-role`, `manual-destroy-role` and the `gatus-repo` ECR repository.

> [!IMPORTANT]
> `docker-build-push-role-2` and `terraform-apply-role` trust only `refs/heads/main` of `github_repo`. Runs from any other branch fail at the Configure AWS credentials step. Pull request runs of `docker-build-push` build and scan the image, then fail at the same step, which is expected.

### 4. Build and Push the First Image

`docker-build-push` has no manual trigger. It runs on pushes to `main` that touch `app/**`, so push a commit under `app/` to `main`. The workflow pulls the hardened base image, builds, scans with Anchore (high severity cut off), pushes a SHA tagged image to ECR and writes the tag to the SSM parameter `/gatus/current_image_tag`.

> [!IMPORTANT]
> This must complete before the full apply. The ECS module reads `/gatus/current_image_tag` as a data source, so `terraform plan` fails with `ParameterNotFound` until the Docker workflow has run once.

### 5. First Full Apply

`terraform-apply-role` is scoped to day two changes (task definitions, service updates, SSM parameters, listener rules and DNS records). It cannot create the VPC, ALB, ECS cluster, ACM certificate or IAM roles, so run the first full apply of the application stack locally.

Create `infra/terraform.tfvars` (gitignored) with the same values as step 2:

```hcl
aws_region           = "eu-west-2"
owner                = "your name"
domain_name          = "example.com"
availability_zones   = ["eu-west-2a", "eu-west-2b"]
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
```

```bash
cd infra
terraform init \
  -backend-config="bucket=<your-state-bucket>" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=<your-region>" \
  -backend-config="dynamodb_table=<your-lock-table>"
terraform apply
```

> [!NOTE]
> The plan fails fast if the bootstrap root has not been applied, because the ECR repository is read through a data source. Terraform also waits for ACM DNS validation, which usually adds a few minutes. The service starts two Fargate tasks and the ALB health check expects HTTP 200 from `/health` on port 8080.

### 6. Deploy Changes Through the Pipelines

Once bootstrapped, the day to day flow is:

1. Push a change under `app/` to `main`. `docker-build-push` builds, scans, pushes and updates the SSM tag.
2. Run `terraform-apply` from the Actions tab. It reads the new tag from SSM, registers a new task definition and rolls the service.

> [!NOTE]
> `docker-build-push` never touches the ECS service. A new image only goes live after `terraform-apply` runs. Changes to `infra/config/config.yaml` update the `/gatus/config` parameter but do not change the task definition, because the container references the parameter ARN. Force a redeploy to pick them up:
> `aws ecs update-service --cluster gatus-cluster --service gatus-service --force-new-deployment --region <your-region>`

### 7. Verify

```bash
aws ecs describe-services --cluster gatus-cluster --services gatus-service --region <your-region> \
  --query "services[0].{status:status,running:runningCount,desired:desiredCount}"

curl -I https://tm.<your-domain>/health
curl -I http://tm.<your-domain>
```

Expect two running tasks, HTTP 200 from `/health`, a 301 redirect from port 80 to HTTPS, and the Gatus dashboard at the service URL.

## Teardown

### 1. Destroy the application stack

Trigger `manual-destroy` from the Actions tab. It assumes `manual-destroy-role` (trusts any ref of the repository), writes a destroy plan and applies it. It removes the VPC, ALB, ECS cluster and service, ACM certificate, Route 53 records, log group, `/gatus/config` parameter and the ECS task execution role.

> [!IMPORTANT]
> The workflow never touches the CI/CD roles or the ECR repository, because they live in the bootstrap root. The ECR repository and its images survive, so a redeploy does not need a rebuild. A redeploy does need a local `terraform apply` of the application stack (step 5), because the apply role cannot create core infrastructure.

### 2. Optional cleanup

The following are not managed by the application stack and are left in place: the CI/CD roles and ECR repository (bootstrap root), the state bucket, the lock table, the OIDC provider, the hosted zone and the `/gatus/current_image_tag` parameter.

To remove the bootstrap resources, empty the ECR repository first because it is not configured with `force_delete`, then destroy the bootstrap root with admin credentials:

```bash
aws ecr batch-delete-image \
  --repository-name gatus-repo \
  --region <your-region> \
  --image-ids "$(aws ecr list-images --repository-name gatus-repo --region <your-region> --query 'imageIds[*]' --output json)"

cd infra/bootstrap
terraform init -reconfigure \
  -backend-config="bucket=<your-state-bucket>" \
  -backend-config="key=bootstrap/terraform.tfstate" \
  -backend-config="region=<your-region>" \
  -backend-config="dynamodb_table=<your-lock-table>"
terraform destroy
```

> [!NOTE]
> If the repository is already empty, the first command errors because `batch-delete-image` rejects an empty list. That is harmless.

If you destroy the bootstrap root, the `/gatus/current_image_tag` parameter still points at an image in the deleted repository. Rebuild the image (step 4) before the next full apply, and remove the parameter if you no longer need it:

```bash
aws ssm delete-parameter --name /gatus/current_image_tag --region <your-region>
```

Empty and delete the state bucket, and delete the lock table and OIDC provider, once they are no longer needed. If you delegated a subdomain to Route 53, delete the hosted zone and the matching `NS` records at your DNS provider.
