variable "is_aws_service" {
  default = true
  type = bool
  description = "false if crearing endpoint for third party"
}
variable "third_party_service" {
  default = ""
  type = string
  description = "complete value for third party endpoint string" 
}
variable "region" {
#   default = ""
  type = string
  description = "aws region where endpoint will be created"  
}
variable "aws_service" {
#   default = ""
  type = string
  description = "aws service for the endpoint" 
}
variable "vpc_id" {
  type = string
  description = "vpc id for the endpoint"   
}
variable "security_groups" {
  type = list
  description = "list of security group IDs for vpc endpoint."    
}
variable "subnets" {
  type = list
  description = "list of subnet IDs for vpc endpoint."
}
variable "vpc_endpoint_type" {
  default = "Interface"
  type = string
  description = "vpc endpoint type"
}
variable "vpc_endpoint_policy" {
  default = null
  type = string
  description = "JSON policy for the endpoint"
}
variable "default_tags" {
  default = {}
  type = map
  description = "tags for the endpoint"
}
variable "app" {
  default = ""
  type = string
  description = "app tag for endpoint"   
}
variable "environment" {
    default = ""
    type = string
    description = "environment tag for endpoint"
}
variable "owner" {
    default = ""
    type = string
    description = "owner tag for endpoint"
}
variable "org" {
    default = ""
    type = string
    description = "org tag for endpoint"   
}
variable "env" {
    default = ""
    type = string
    description = "env tag for endpoint"   
}






📘 Terraform Workspace with Vault Access in Private VPC via GitHub + TFC Agent + AWS CodeBuild
🔧 Problem Statement
Terraform workspaces (in Terraform Cloud) by default cannot access internal resources (like Vault running in a private VPC), because Terraform Cloud executes code in its own isolated SaaS environment.

To securely execute Terraform plans with access to self-hosted Vault inside an AWS VPC, we needed to:

Ensure that Terraform runs within the VPC.

Authenticate Terraform with Vault.

Integrate this setup with GitHub Actions CI/CD.

✅ Final Solution Overview
The solution uses:

AWS CodeBuild as a self-hosted GitHub Runner and Terraform Agent environment.

Custom Docker image with Terraform, Vault CLI, and tfc-agent binary.

Terraform Cloud Agent Pools to delegate Terraform execution to your private infrastructure.

Vault token injection into the CodeBuild environment.

Terraform Workspace configured to use the custom agent pool.

📐 Architecture Diagram
yaml
Copy
Edit
GitHub Action Workflow
       |
       v
+-----------------------------+
|  GitHub Runner in CodeBuild |
|-----------------------------|
| - tfc-agent                 |
| - vault CLI                 |
| - terraform CLI             |
+-----------------------------+
       |
       v
  Registers with TFC Agent Pool
       |
       v
Terraform Cloud Workspace (agent-based)
       |
       v
Runs Plan/Apply via agent inside VPC
       |
       v
Access Vault Securely in VPC
🧱 Components Breakdown
1. Docker Image
Dockerfile includes:

terraform CLI

vault CLI

tfc-agent binary

Any required AWS CLI, Python, jq, etc.

dockerfile
Copy
Edit
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl unzip gnupg jq awscli

# Terraform
ENV TERRAFORM_VERSION=1.7.5
RUN curl -s -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
 && unzip terraform.zip -d /usr/local/bin && rm terraform.zip

# Vault
ENV VAULT_VERSION=1.15.4
RUN curl -s -o vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
 && unzip vault.zip -d /usr/local/bin && rm vault.zip

# TFC Agent
ENV TFC_AGENT_VERSION=1.15.0
RUN curl -s -Lo tfc-agent https://releases.hashicorp.com/tfc-agent/${TFC_AGENT_VERSION}/tfc-agent_${TFC_AGENT_VERSION}_linux_amd64 \
 && chmod +x tfc-agent && mv tfc-agent /usr/local/bin/

ENTRYPOINT ["/bin/bash"]
Push this image to Amazon ECR for use in CodeBuild.

2. AWS CodeBuild Project
Hosted in the same VPC as Vault.

Uses the custom Docker image built above.

Environment variables:

TFC_AGENT_TOKEN

VAULT_TOKEN

Any required AWS/Vault config.

IAM permissions should allow:

Access to GitHub (via GitHub Runner setup).

Access to Vault within the VPC.

3. GitHub Workflow (.github/workflows/deploy.yml)
yaml
Copy
Edit
name: Terraform Plan via TFC Agent

on:
  push:
    branches: [main]

jobs:
  run-tfc-agent:
    runs-on: [self-hosted, terraform-codebuild] # Label for CodeBuild-hosted runner
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Start TFC Agent
        run: |
          export VAULT_TOKEN=${{ secrets.VAULT_TOKEN }}
          export TFC_AGENT_TOKEN=${{ secrets.TFC_AGENT_TOKEN }}
          tfc-agent
Note: The runner here starts tfc-agent, which registers with Terraform Cloud.

4. Terraform Cloud Workspace Configuration
Set Execution Mode to: Agent

Assign the workspace to the custom Agent Pool.

Add variables:

VAULT_ADDR (env var)

VAULT_TOKEN (env var, sensitive)

Any Terraform variables required.

5. Agent Registration Flow
When the workflow triggers:

GitHub job runs in CodeBuild (private VPC).

tfc-agent binary runs and connects to Terraform Cloud agent pool using TFC_AGENT_TOKEN.

Terraform Cloud recognizes the agent and sends commands (like plan, apply) to it.

Since the agent is in the VPC, it can securely reach Vault, and terraform commands can access secrets via vault.

🔐 Vault Access
Vault is accessible inside the VPC, and the following environment is pre-configured:

VAULT_ADDR=https://vault.mycompany.internal

VAULT_TOKEN injected from GitHub Secrets or AWS SSM.

Terraform can now use Vault provider or secrets lookup like:

hcl
Copy
Edit
data "vault_generic_secret" "aws_creds" {
  path = "aws/creds/deploy-role"
}
📊 Benefits
Security: Vault never exposed to internet.

Compliance: Full control of Terraform execution.

Flexibility: Run custom tools (jq, curl, etc.) in your agent container.

Integration: Works with existing GitHub CI/CD flows.

🧪 POC Validation
✅ Terraform workspace successfully executed using agent pool.

✅ Vault token authenticated and secrets retrieved.

✅ CodeBuild project inside private VPC successfully hosted the GitHub runner and executed plans.

📌 To Do for Production
Store TFC_AGENT_TOKEN and VAULT_TOKEN in a secure secret store (e.g., AWS Secrets Manager).

Add logging/monitoring for agent runs.

Use IAM Roles for Vault (if integrated with AWS auth method).

Use terraform apply and remote state lock validation.

