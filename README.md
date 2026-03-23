# Cloud Programming Infrastructure Deployment Guide

This repository contains a comprehensive Terraform Infrastructure as Code (IaC) project that deploys a multi-region serverless web application on AWS. The infrastructure includes static website hosting, serverless API endpoints, global content delivery, and DNS management.

## Architecture Overview

The infrastructure deploys the following components across multiple AWS regions:

- **S3 Buckets**: Static website hosting across 4 regions (EU Central 1, US West 1, AP East 1, AF South 1)
- **Lambda Functions**: Serverless email processing functions in multiple regions
- **API Gateway**: HTTP API endpoints for Lambda function integration

Additionally, these global services are deployed:

- **CloudFront**: Global CDN for content delivery and edge computing
- **Route53**: DNS management for custom domain
- **SSL Certificates**: TLS/SSL certificates for secure connections
- **IAM**: Roles and policies for secure resource access
- **Monitoring**: CloudWatch integration for observability

## Prerequisites

Before deploying this infrastructure, ensure you have the following prerequisites:

### 1. Software Requirements

- **Terraform**: Version 1.14.1 (exact version required)
- **AWS CLI**: Latest version
- **Git**: For repository management
- **Python**: For Lambda function development (if modifying functions)

### 2. AWS Account Setup

- Active AWS account with appropriate permissions
- AWS CLI configured with credentials
- AWS profile named `cloud-programming` configured

### 3. Domain Requirements

- Access to manage DNS for domain `aws.familieasenbauer.net`
- Route53 hosted zone for the domain (or ability to create one)

### 4. Required AWS Permissions

Your AWS user/role must have permissions for:
- S3 (bucket creation, object management, policies)
- Lambda (function creation, execution roles)
- API Gateway (API creation, deployment)
- CloudFront (distribution creation, invalidation)
- Route53 (hosted zone management, record creation)
- IAM (role and policy creation)
- CloudWatch (logging and monitoring)
- ACM (certificate management)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd cloud-programming
```

### 2. Configure AWS Profile

Create an AWS profile named `cloud-programming`:

```bash
aws configure --profile cloud-programming
```

Enter your AWS credentials when prompted:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `us-east-1`
- Default output format: `json`

### 3. Verify AWS Configuration

Test your AWS configuration:

```bash
aws sts get-caller-identity --profile cloud-programming
```

### 4. Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

This will:
- Download required providers (AWS provider v6.25.0)
- Initialize backend configuration
- Download and install modules

### 5. Review Configuration

Before deployment, review the configuration in `variables.tf`:

- **Domain**: `cloud-programming.aws.familieasenbauer.net`
- **Regions**: EU Central 1, US West 1, AP East 1, AF South 1
- **Lambda Functions**: send_email, list_emails
- **Static Website**: HTML, CSS, JavaScript files

## Deployment Steps

### 1. Plan the Deployment

Review what Terraform will create:

```bash
terraform plan
```

This command will:
- Show all resources to be created
- Validate configuration syntax
- Check for any potential issues

### 2. Deploy the Infrastructure

Deploy all resources:

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

**Expected Deployment Time**: 10-15 minutes

### 3. Verify Deployment

After successful deployment, verify the infrastructure:

#### Check Outputs
```bash
terraform output
```

#### Test the Website
Navigate to: `https://cloud-programming.aws.familieasenbauer.net`

#### Test API Endpoints
- POST `https://cloud-programming.aws.familieasenbauer.net/api/send-email`
- POST `https://cloud-programming.aws.familieasenbauer.net/api/list-emails`

### 4. Monitor Resources

Check AWS Console for:
- S3 buckets in each region
- Lambda functions deployment
- CloudFront distribution status
- Route53 DNS records
- SSL certificate validation

## Post-Deployment Configuration

### 1. DNS Propagation

DNS changes may take up to 48 hours to propagate globally. You can check propagation status using:

```bash
nslookup cloud-programming.aws.familieasenbauer.net
```

### 2. SSL Certificate Validation

Ensure SSL certificates are validated and active in the AWS Certificate Manager.

### 3. CloudFront Distribution

Wait for CloudFront distribution to be fully deployed (status: "Deployed").

## Deploying to Additional Regions

This infrastructure is designed to support multi-region deployment. Currently, the following regions are configured:
- **eu-central-1** (EU Central 1 - Frankfurt)
- **us-west-1** (US West 1 - N. California)
- **ap-east-1** (AP East 1 - Hong Kong)
- **af-south-1** (AF South 1 - Cape Town)
- **us-east-1** (US East 1 - N. Virginia) - Used for global services only

### Adding New Regions

To deploy the infrastructure to additional AWS regions, follow these steps:

#### Step 1: Update Region Configuration

1. **Edit `variables.tf`**: Add your new region to the `aws_regions` local variable:

```hcl
locals {
  aws_regions = {
    us_east_1    = "us-east-1"
    eu_central_1 = "eu-central-1"
    us_west_1    = "us-west-1"
    ap_east_1    = "ap-east-1"
    af_south_1   = "af-south-1"
    # Add your new regions here
    eu_west_1    = "eu-west-1"     # Example: Europe (Ireland)
    ap_south_1   = "ap-south-1"    # Example: Asia Pacific (Mumbai)
  }
  # ... rest of the configuration remains unchanged
}
```

#### Step 2: Configure AWS Providers

2. **Edit `providers.tf`**: Add AWS provider configurations for each new region:

```hcl
# Add provider for each new region
provider aws {
  alias   = "eu_west_1"
  region  = local.aws_regions.eu_west_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}

provider aws {
  alias   = "ap_south_1"
  region  = local.aws_regions.ap_south_1
  profile = "cloud-programming"

  default_tags {
    tags = {
      project_name = local.project.name
    }
  }
}
```

#### Step 3: Deploy Regional Resources

3. **Edit `s3.tf`**: Add S3 module instances for each new region:

```hcl
module s3_eu_west_1 {
  source = "./s3_module"
  providers = {
    aws = aws.eu_west_1
  }
  region                      = local.aws_regions.eu_west_1
  project                     = local.project
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  static_websites             = local.static_websites
}

module s3_ap_south_1 {
  source = "./s3_module"
  providers = {
    aws = aws.ap_south_1
  }
  region                      = local.aws_regions.ap_south_1
  project                     = local.project
  cloudfront_distribution_arn = module.cloudfront_distribution.distribution_arn
  static_websites             = local.static_websites
}
```

4. **Edit `lambda.tf`**: Add Lambda module instances for each new region:

```hcl
module lambda_eu_west_1 {
  source = "./lambda_module"
  providers = {
    aws = aws.eu_west_1
  }
  region                    = local.aws_regions.eu_west_1
  project                   = local.project
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_path                  = local.api_path
  lambda_functions          = local.lambda_functions
}

module lambda_ap_south_1 {
  source = "./lambda_module"
  providers = {
    aws = aws.ap_south_1
  }
  region                    = local.aws_regions.ap_south_1
  project                   = local.project
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_path                  = local.api_path
  lambda_functions          = local.lambda_functions
}
```

5. **Edit `api_gateway.tf`**: Add API Gateway module instances for each new region:

```hcl
module api_gateway_eu_west_1 {
  source = "./api_gateway_module"
  providers = {
    aws = aws.eu_west_1
  }
  region           = local.aws_regions.eu_west_1
  project          = local.project
  lambda_functions = module.lambda_eu_west_1.lambda_functions
  stage_name       = local.stage_name
}

module api_gateway_ap_south_1 {
  source = "./api_gateway_module"
  providers = {
    aws = aws.ap_south_1
  }
  region           = local.aws_regions.ap_south_1
  project          = local.project
  lambda_functions = module.lambda_ap_south_1.lambda_functions
  stage_name       = local.stage_name
}
```

#### Step 4: Verify and Deploy

6. **Validate Configuration**: Run Terraform validation to ensure syntax is correct:

```bash
terraform validate
```

7. **Plan Deployment**: Review the changes that will be made:

```bash
terraform plan
```

8. **Deploy New Regions**: Apply the changes to deploy resources to new regions:

```bash
terraform apply
```

### Important Considerations

#### Regional Availability
- **Service Availability**: Ensure that all required AWS services (Lambda, API Gateway, S3) are available in your target regions
- **Pricing**: Different regions have different pricing structures
- **Compliance**: Consider data residency and compliance requirements for your target regions

#### CloudFront Integration
- The CloudFront distribution will automatically include the new regional origins
- Edge routing will direct traffic to the nearest healthy region
- No additional CloudFront configuration is required

#### Testing New Regions
After deployment, test the new regional endpoints:

```bash
# Test new regional endpoints (replace eu-west-1 with your region)
curl -w "@timefile.txt" -o /dev/null -s "https://cloud-programming.aws.familieasenbauer.net/eu-west-1"
curl -w "@timefile.txt" -o /dev/null -s "https://cloud-programming.aws.familieasenbauer.net/eu-west-1/prod/api/send-email"
```

#### Monitoring
- Monitor all regional deployments through AWS CloudWatch
- Set up alerts for each region to ensure high availability
- Use the performance testing scripts to verify latency improvements

### Removing Regions

To remove a region from deployment:

1. Comment out or remove the corresponding module blocks from `s3.tf`, `lambda.tf`, and `api_gateway.tf`
2. Run `terraform plan` to review what will be destroyed
3. Run `terraform apply` to remove the regional resources
4. Optionally remove the provider and region configuration if no longer needed

## Teardown Instructions

### 1. Plan Destruction

Review what will be destroyed:

```bash
terraform plan -destroy
```

### 2. Destroy Infrastructure

Remove all resources:

```bash
terraform destroy
```

When prompted, type `yes` to confirm the destruction.

**Important Note**: This will permanently delete all resources, apart from the CloudFront distribution. I
t can't be deleted via terraform due to dependencies with Lambda@Edge. You have to manually delete the distribution after the Lambda@Edge functions have been deleted, which takes a few hours.

## Performance Measurement

This repository includes a `timefile.txt` file that can be used to measure the performance of your deployed infrastructure. This file contains curl timing format variables that help you analyze various aspects of HTTP request performance.

### Using timefile.txt

The `timefile.txt` file is designed to be used with curl's `-w` (write-out) option to measure detailed timing information for HTTP requests to your deployed endpoints.

#### Basic Usage

```bash
# Test website performance
curl -w "@timefile.txt" -o /dev/null -s "https://cloud-programming.aws.familieasenbauer.net"

# Test API endpoint performance
curl -w "@timefile.txt" -o /dev/null -s -X POST "https://cloud-programming.aws.familieasenbauer.net/api/send-email"
```

#### Advanced Usage with Output Redirection

```bash
# Save performance metrics to a file
curl -w "@timefile.txt" -o /dev/null -s "https://cloud-programming.aws.familieasenbauer.net" >> performance_results.txt

# Test multiple endpoints and compare performance
for endpoint in "/" "/api/send-email" "/api/list-emails"; do
    echo "Testing: $endpoint" >> performance_results.txt
    curl -w "@timefile.txt" -o /dev/null -s "https://cloud-programming.aws.familieasenbauer.net$endpoint" >> performance_results.txt
    echo "---" >> performance_results.txt
done
```

### Performance Metrics Explained

The `timefile.txt` file measures the following timing metrics:

| Metric               | Description            | What It Measures                                        |
|----------------------|------------------------|---------------------------------------------------------|
| `time_namelookup`    | DNS lookup time        | Time to resolve the domain name to an IP address        |
| `time_connect`       | Connection time        | Time to establish a TCP connection to the server        |
| `time_appconnect`    | SSL/TLS handshake time | Time to complete SSL/TLS negotiation (HTTPS only)       |
| `time_pretransfer`   | Pre-transfer time      | Time from start until file transfer is about to begin   |
| `time_redirect`      | Redirect time          | Total time for all redirect steps before final transfer |
| `time_starttransfer` | Time to first byte     | Time until the first byte is received from the server   |
| `time_total`         | Total time             | Complete transaction time from start to finish          |

### Performance Analysis

#### Understanding the Metrics

- **DNS Performance**: `time_namelookup` should be low (< 100ms) for good DNS performance
- **Network Latency**: `time_connect` indicates network latency to the CloudFront edge locations
- **SSL Overhead**: `time_appconnect - time_connect` shows SSL/TLS handshake overhead
- **Server Processing**: `time_starttransfer - time_pretransfer` indicates server-side processing time
- **Content Delivery**: `time_total - time_starttransfer` shows content download time

#### Benchmarking Different Regions

Test performance from different geographic locations to verify CloudFront edge performance:

```bash
# Create a performance test script
#!/bin/bash
echo "Performance Test - $(date)" > performance_report.txt
echo "=================================" >> performance_report.txt

endpoints=(
    # Default origin with edge routing
    "https://cloud-programming.aws.familieasenbauer.net"
    "https://cloud-programming.aws.familieasenbauer.net/prod/api/send-email"
    "https://cloud-programming.aws.familieasenbauer.net/prod/api/list-emails"
    # Region origins
    "https://cloud-programming.aws.familieasenbauer.net/eu"
    "https://cloud-programming.aws.familieasenbauer.net/eu/prod/api/send-email"
    "https://cloud-programming.aws.familieasenbauer.net/eu/prod/api/list-emails"
    "https://cloud-programming.aws.familieasenbauer.net/us"
    "https://cloud-programming.aws.familieasenbauer.net/us/prod/api/send-email"
    "https://cloud-programming.aws.familieasenbauer.net/us/prod/api/list-emails"
    "https://cloud-programming.aws.familieasenbauer.net/ap"
    "https://cloud-programming.aws.familieasenbauer.net/ap/prod/api/send-email"
    "https://cloud-programming.aws.familieasenbauer.net/ap/prod/api/list-emails"
    "https://cloud-programming.aws.familieasenbauer.net/af"
    "https://cloud-programming.aws.familieasenbauer.net/af/prod/api/send-email"
    "https://cloud-programming.aws.familieasenbauer.net/af/prod/api/list-emails"
)

for endpoint in "${endpoints[@]}"; do
    echo "Testing: $endpoint" >> performance_report.txt
    for i in {1..5}; do
        echo "Run $i:" >> performance_report.txt
        curl -w "@timefile.txt" -o /dev/null -s "$endpoint" >> performance_report.txt
    done
    echo "---" >> performance_report.txt
done
```

Note #1: Due to CloudFronts Caching mechanism, you will receive different values on multiple reruns, which are caused by potentially required origin-fetches (slower) and cache retrievals (faster).

Note #2: To avoid uncertainties in the measurement, use should never run this measurement locally. Rather use the AWS Management Consoles shell.


---

Disclaimer #1: This infrastructure was created by Felix Asenbauer for Portfolio Project DLBSEPCP01_D.

Disclaimer #2: For the content within `src` (the demo website) "artificial intelligence" (Jetbrains AI Assistant) was used to create the styling and layout of the pages.
