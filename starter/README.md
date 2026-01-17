# CD12352 - Infrastructure as Code Project Solution
# [Miguel Granica]

# Udagram Infrastructure as Code (CloudFormation)

## Overview

This repository contains the **Infrastructure as Code (IaC)** definition for the **Udagram project**, implemented using **AWS CloudFormation**. The goal is to provision a **highly available, secure, and scalable web application infrastructure** following AWS best practices.

The infrastructure is split into **logical stacks** to enforce separation of concerns:

* **Network stack**: VPC, subnets, routing, NAT, and internet access
* **Application stack**: Load balancer, auto-scaling web servers, security groups, IAM, and S3

A unified shell script (`run.sh`) is provided to **deploy, preview, and delete** CloudFormation stacks in a consistent and repeatable way.

---
## IaC Diagram
![Aic diagram](../images/AWS-hybrid-cloud-via-VPN.png)


## Repository Structure

```text
.
├── run.sh
├── network.yml
├── udagram.yml
├── parameters/
│   ├── network-parameters.json
│   └── udagram-parameters.json
└── README.md
```

### Key Files

| File                | Description                                               |
| ------------------- | --------------------------------------------------------- |
| `run.sh`            | Automation script to deploy / preview / delete stacks     |
| `network.yml`       | Defines the networking layer (VPC, subnets, NAT, routing) |
| `udagram.yml`        | Defines the application layer (ALB, ASG, EC2, IAM, S3)    |
| `parameters/*.json` | Environment-specific stack parameters                     |

---

## Architecture Summary

### High-Level Architecture

* **VPC** spanning two Availability Zones
* **Public subnets** for Load Balancer and NAT Gateways
* **Private subnets** for EC2 web servers
* **Application Load Balancer (ALB)** exposing HTTP (port 80)
* **Auto Scaling Group** of EC2 instances running Nginx
* **IAM Role + Instance Profile** for controlled S3 access
* **Private S3 bucket** for application assets

This design ensures:

* High availability
* No direct internet exposure of EC2 instances
* Controlled outbound internet access via NAT Gateways
* Reusability through CloudFormation exports/imports

---

## CloudFormation Stack Design

### 1. Network Stack (`network.yml`)

The network stack is the **foundation** and must be deployed first.

#### Resources Created

* VPC with DNS support enabled
* Internet Gateway attached to the VPC
* 2 Public Subnets (AZ1, AZ2)
* 2 Private Subnets (AZ1, AZ2)
* 2 NAT Gateways (one per AZ)
* Route tables for public and private traffic

#### Design Decisions

* **One NAT Gateway per AZ** to avoid cross-AZ dependency
* **Public subnets** route directly to the Internet Gateway
* **Private subnets** route outbound traffic through NAT
* Subnets and route tables are **exported** for reuse by other stacks

#### Outputs & Exports

The network stack exports critical identifiers such as:

* VPC ID
* Public subnet IDs
* Private subnet IDs
* Route table IDs

These are consumed by the application stack via `Fn::ImportValue`.

---

### 2. Application Stack (`server.yml`)

The application stack builds on top of the network layer.

#### Resources Created

* Security Groups for Load Balancer and EC2 instances
* Application Load Balancer (ALB)
* Listener and listener rules (HTTP)
* Target Group with health checks
* Launch Template for EC2 instances
* Auto Scaling Group
* IAM Role and Instance Profile
* Private, encrypted S3 bucket

#### EC2 Configuration

* AMI: Ubuntu-based AMI
* Instance type: `t2.micro`
* Nginx installed and started via `UserData`
* Instances launched in **private subnets only**

#### Security Model

* ALB Security Group allows inbound HTTP from the internet
* EC2 Security Group only allows HTTP from the ALB
* EC2 instances have **no public IPs**
* S3 bucket is **private**, encrypted, and versioned

---

## Automation Script (`run.sh`)

The `run.sh` script standardizes CloudFormation operations.

### Supported Modes

| Mode      | Description                              |
| --------- | ---------------------------------------- |
| `deploy`  | Creates or updates a stack               |
| `preview` | Generates a change set without executing |
| `delete`  | Deletes the stack                        |

### Script Parameters

```text
./run.sh <mode> <region> <stack-name> <template-file> <parameter-file>
```

| Parameter      | Description                  |
| -------------- | ---------------------------- |
| mode           | deploy | delete | preview    |
| region         | AWS region (e.g. us-east-1)  |
| stack-name     | CloudFormation stack name    |
| template-file  | Path to the YAML template    |
| parameter-file | Path to JSON parameters file |

### Examples

Deploy network stack:

```bash
./run.sh deploy us-east-1 Udagram-Network network.yml parameters/network-parameters.json
```

Preview application stack changes:

```bash
./run.sh preview us-east-1 Udagram-App server.yml parameters/server-parameters.json
```

Delete application stack:

```bash
./run.sh delete us-east-1 Udagram-App server.yml parameters/server-parameters.json
```

---

## Deployment Order

⚠️ **Important**: Stacks must be deployed in order.

1. **Network stack**
2. **Application stack**

Deleting should be done in reverse order.

---

## Prerequisites

* AWS CLI installed and configured
* Valid AWS credentials with CloudFormation, EC2, IAM, S3 permissions
* Bash-compatible shell

---

## Operational Notes

* Changes should always be reviewed using `preview` before deployment
* Stack names should be environment-scoped (e.g. `dev`, `staging`, `prod`)
* Parameters allow reusing templates across environments

---

## Future Improvements

* HTTPS support via ACM and ALB listener
* Blue/Green deployments
* CI/CD integration (GitHub Actions)
* Parameter Store / Secrets Manager integration
* Auto Scaling policies based on metrics

---

## Author & Context

This repository follows **production-grade DevOps and IaC principles** and is aligned with Udacity Cloud DevOps best practices.

It is designed to be:

* Deterministic
* Repeatable
* Auditable
* Environment-agnostic

---

✅ *Infrastructure should be boring. This repository ensures exactly that.*
