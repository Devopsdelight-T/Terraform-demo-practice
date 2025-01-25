# Terraform-demo-practice

## 1. Introduction
1. what is **terraform** ? Terraform is an infrastructure as a code (IAc) tool which helps to automate the provisioning, configuring of the infrastructure using declarative configuration language.

2. Terrform vs other IAC tools ? Terraform is a leader among infrastructure-as-code (IAC) tools, known for its declarative syntax, cloud agnostic design and robust eco-system. Terraform's establishment ecosystem make it a go-to choice for many DevOps teams. Key highlights include multi-cloud support, state management & community ecosystem

3. **Declarative vs Imperative Approach** one of the terraform's defining features is its declarative approach. Instead of instructing how to achieve, it just declares the desired (end ) result and terraform will make sure it happens.

ex : 
```.tf
resource "aws_s3_bucket" 
"my_bucket" {...}        
```

ex :
```
aws s3api create-bucket --bucket my-bucket
```

![Terraform high level architecture]](image.png)

Terraform works by connecting your infrastructure code to the actual cloud resources you want to provision.

Terraform Architecture Consists of two main parts. 1. Terraform manifest files 2. Terraform Core

1. **Terraform manifest files** Consists of different(main.tf,provider.tf,variable.tf,output.tf,backend.tf etc..) .tf extension files. which defines your infrastructure's desired state. 
2. **Terraform core** processes the .tf files, plans the changes and ensures the current state matches with the desired state. It manages the state files. which tracks your infrastructure's current configuration.

# 2. Setting up Terrform Environment


1. Teraform installation it is pretty straight forward and you  need any guidance on it you can checkout `installation-guide.md` file in these repo

2. Configuring providers: terraform uses providers to communicate with the infrastructure that you want to manage. Providers are plugins which allows terraform to work with specific services like aws, azure, gcp or even on-prem platforms like vmware

3. How providers work ? 

```
1. Declare providers : Providers are defined using the provider block which tells terraform which APi or service to interact with

2. Download providers : terraform init downloads the specified providers from the terraform registry into the .terraform directory

3. provider caching : use `plugin_cache_dir` to enable caching, speeding up provider downloads and enabling offline workflows

`export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache` used for caching

```

Provider Meta-Arguments
    Alias: Use the same provider with different
        configurations (e.g., multiple accounts, regions).
    Default Provider: If no alias is specified, it is the
        default configuration.


# Terraform state

- Terraform state is a file that keeps track of all the resources that terraform creates and manages. It acts as a source of truth for terraform 

|local state|Remote state|
|---|---|
|stored in local file (terraform.tfstate)|stored in remote storage (i.e;S3, Azure blob)|
|Suitable for single users or testing|Suitable for teams and production|
|Risk of data loss if file is lost or deleted| centralized, secure, and versioned |

- **state locking** prevents multiple users from updating same state file at the same-time avoiding corrupting

**Best practices**
- Always try to backup state files regularly
- use remote backends for state storage
- enable state locking using dynamodb (aws) or equivalent solutions

### configuring backends for state storage

- A backend defines where terraform stores its state. 
- Remote backends are highly recommended for teams and production environments

Terraform creates a *.terraform* directory in your working
directory to store plugins and dependencies.

Terraform configurations define the desired infrastructure in HCL (Hashicorp configuration language). The configuration files are organized logically to maintain clarity, modularity, and ease of management

Key configuration files in terraform project : 

```
providers.tf --> Defines the providers, terraform will use to manage resources.
main.tf --> The main resource definitions, the actual infrastructure you want terraform to create or manage
variable.tf --> Declares input variables to make configuration dynamic and reusable
output.tf --> Declares output values to share key information about the infrastructure after provisioning
backend.tf --> configures backends for storing the terraform's state file remotely (ex: s3, azure blob)
terraform.tfvars --> stores default values for input variables, The file is optional but helps separate configuration values from the code. Ex: `instance_type = "t3.small"`

```

**Terraform working process** 

1. Start with providers (provider.tf) To tell terraform which infrastructure to manage  
2. Define resources in main.tf using resource block  
3. use variables (variables.tf) to make configuration flexible  
4. output important variables (ex: Ips, Dns names) in output.tf  
5. store sensitive or dynamic input values in terraform.tfvars  
6. configure a remote backend (backend.tf) for better state management and team collaboration

`terraform plan -out=tfplan`

`terraform destroy` , we can target specific things to destroy, `terraform destroy -target=aws_instance.example`

## Managing infrastructure with terraform

- Terraform provides modules for reusability and workspaces for environment isolation. 
- Modules are reusable, logical units of terraform code. By encapsulating resources into modules, you can reduce duplication, improve maintainability and share infrastructure patterns across projects.

  **1. structure your module** - Module is just a folder containing terraform configuration files

  **2. define the module** -main.tf (core resource logic), variable.tf (input variables), output.tf (export values) 

  **3. use the module in your project** - in your root folder you can reference the module

```
module "ec2_instance" {
    source = "./terraform-modules/ec2-instance"
    ami = "ami-2445"
    instance_type = "t2.small"
}
```
    **4. Initialize and apply**: modules are off two types 1. Root modules 2. Child modules

- we can use external modules also if in case required

**workspace**
- Workspace creates multiple instances of the same terraform state file. This is useful for managing different environments with a single configuration

`terraform workspace new dev` `terraform workspace list` `terraform workspace select dev`
- Even we can customize resources based on workspace name using the terraform.workspace variable file

```
resource "aws_s3_bucket" "example" {
    bucket = "my-app-${terraform.workspace}"
}
```
- In dev, the bucket name become my-app-dev, in prod, it will be my-app-prod

|command|Description|
|---|---|
|terraform workspace new <name>|create a new workspace|
|terraform workspace list| To list workspaces|
|terraform workspace select <name>|To switch to a specific workspace|
|terraform workspace show|show the current active workspace|
|terraform workspace delete <name>|delete a workspace(if not in use)|


- use workspaces for lightweight, isolated environments
- store state files in remote backends (ex: S3) to prevent conflicts
- use variables to customize environment-specific values

# 5. variables, data types and outputs

- Think of variables as inputs to your configuration and outputs as its result terraform provides after creating or managing your resources

we can define variables using the variable block in a variable.tf file.

variable "instance_type" {
    description = "type of Ec2 instance to use"
    default = "t2.micro"
}

variable "instance_count" {
    description = "no.of instances to create"
    type = number
    default = 1
}

**passing values to variables**
1. using variable.tf file
2. using CLI : pass values using -var variable `terraform apply -var="instance_type=t3.large" -var="instace_count=3"
3. using Environmental values. export TF_VAR_instance_type="t3.small"

Variable precedence :

    `cli,env,terraform.tfvars,*.auto.tfvars,default values in variable.tf`

Data Type Description Example Usage
String A single line of text. name = var.name
Number

Numeric values
(integers/floats).

count = var.count

Boolean True or false values.

enabled =
var.enabled

List

Ordered sequence of
values.

cidr =
var.subnets[0]
Map Key-value pairs. tags = var.tags
Object Complex structures.

name =
var.config.name

```variable.tf

variable "app_config" {
description = "Configuration for the
application"
type = object({
name = string
instance_count = number
tags = map(string)
})
default = {
name = "my-app"
instance_count = 3
tags = {
environment = "dev"
owner = "team-devops"
}
}
}
```

```main.tf
resource "aws_instance" "example" {
count = var.app_config.instance_count
ami = "ami-12345678"
instance_type = "t2.micro"
tags = var.app_config.tags
}
```

```root module

module "network" {
source = "./modules/network"
}
module "app" {
source = "./modules/app"
subnet_id = module.network.subnet_id
```

```child module

output "subnet_id" {
value = aws_subnet.example.id
}
```

## 6. advancec terraform techniques

- Terraform automatically detects implicit dependencies when one resource references another. you do not need to define these explicitly.

```
resource "aws_vpc" "example" {
cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "example" {
vpc_id = aws_vpc.example.id
cidr_block = "10.0.1.0/24"
}
```
- Here terraform understands that aws_subnet depends on aws_vpc because vpc_id references the vpc id

Explicit dependencies :

- For cases where terraform cannot infer dependencies automatically, you can use depends_on meta argument to define explicit dependencies

```

resource "aws_instance" "example" {
ami = "ami-12345678"
instance_type = "t2.micro"
depends_on = [aws_vpc.example]
}
```

Here Ec2 instance explicitly depends on the vpc 

- Terrform can generate resource dependency graph to help you visualize relationships between resources

`terraform graph` 
- By default, it generates a graph in DOT format (Directed graph language) 

Best practices to manage sensitive data :

1. use remote backends

2. enable state file encryption

3. avoid hard coding secrets

4. use sensitive aruguments in the output.tf file


Dealing with Large infrastructure :

- Scaling infrasturcture with terraform [1. use modules 2. parallel resource creation, use -parallelism  flag to control concurrency `terraform apply -parallelism=10 3. Leverage workspaces (use workspaces to manage multiple environments ex: dev,staging,prod) with same codebase] 


- When terraform makes too many api requests to a provider (aws,azure) you might hit rate limits

Techniques to avoid rate limits :
1. Batch Resource creation : use **count** or **for_each** to group resources logically, minimizing requests
2. use parallelism : Reduce the number of concurent operations `terraform apply -parallelism=5`
3. use terraform's provider block to configure retry settings (if supported by the provider)

```
provider "aws" {
    max_retries = 4
}
```

## 7. provisioners and life-cycle management

- provisioners are used to run scripts or commands on a local or remote system. use them for tasks like installing software, configuring servers, or running post-deployment tasks.

|provisioner type | usecase| execution|
|---|---|---|
|local-exec|run scripts/commands locally on your machine|executes on the machine running terraform|
|remote-exec|Run scripts/commands on a remote resource|Requires SSH or WinRM connection to the resource |

```
resource "aws_instance" "web" {
ami = "ami-12345678"
instance_type = "t2.micro"
provisioner "local-exec" {
command = "echo 'EC2 instance created' >
instance_status.txt"
}
}
```

Remote-exec provisioner :

Running commands on an EC2 instance to install a web server
```
resource "aws_instance" "web" {
ami = "ami-12345678"
instance_type = "t2.micro"
connection {
type = "ssh"
user = "ec2-user"
private_key = file("~/.ssh/id_rsa")
host = self.public_ip
}
provisioner "remote-exec" {
inline = [
"sudo yum update -y",
"sudo yum install -y httpd",
"sudo systemctl start httpd"
]
}
}
```

## 8. Managing Resource lifecycle

- Terraform provides lifecycle hooks to manage updates,tainting, and scaling resources
    `terraform taint aws_instance.web`

1. updating resource : terraform detects changes in the configurations and applies updates without recreating resource.

resource "aws_instance" "web" {
instance_type = "t2.micro"
}


2. Scaling Resources : use the `count` or `for-each` argument to scale resources

3. Modify resources : Modify resource attributes in the configuration. Terraform will update only the changed attributes.


## 9. Managed Resource cleanup and failure Scenarios

- when using provisioners, failures can occur. Terraform offers ways to control cleanup and handle errors

**handling Failure behavior in provisioners**

|Behavior|Description|
|---|---|
|continue|Terraform continues despite provisioner failure|
|fail(default)|Terraform stops immediately on failure|

```
provisioner "local-exec" {
command = "exit 1"
on_failure = "continue"
}

```

cleanup resources on failure :
- if a provisioner fails, Terraform doesn't automatically roll back changes
  1. we can handle cleanup manually by 
      terraform destroy to delete all resources `terraform destroy`
  2. we can even use external scripts to cleanup incomplete resources

```
provisioner "local-exec" {
command = "./cleanup_script.sh"
on_failure = "continue"
}
```

## 10. Debugging and troubleshooting in terraform

- terraform also provides lifecycle management to control resource creation, updates and cleanup

- To enable logs we have to set TF_LOG variable before running any terraform command

```
export TF_LOG=DEBUG
terraform apply
```

understanding TF_LOG levels

|Log level|purpose|
|---|---|
|TRACE|Very detailed logs, including internal operations (use for deep debugging)|
|DEBUG|Detailed information about resource changes and provider interactions|
|INFo|High-level overview of the operations (default level)|
|WARN|Warnings about potential issues|
|ERROR|critical errors that caused the process to fail|

- To save logs to a file for later review, set `TF_LOG_PATH` variable along with TF_LOG
provisioner "local-exec" {
command = "./cleanup_script.sh"
on_failure = "continue"
}

- Terraform validate to check for syntax errors
- `terraform state rm aws_instance.web`

Best Practices for Debugging Terraform

1. Use `TF_LOG` to capture logs and `TF_LOG_PATH` to
persist them for review.
2. Run `terraform validate` to detect syntax or
configuration errors before applying changes.
3. Save and reuse plan files with `terraform plan -out` to
debug and reproduce issues consistently.
4. Use `terraform refresh` to align the state file with actual
infrastructure.
5. Verify `terraform.tfvars` or CLI inputs for mismatched or
missing values.
6. Ensure proper provider credentials and environment
variables are set.
7. Isolate problematic sections of the code by testing
smaller configurations independently.
8. Leverage tools like Datadog, or Logstash to monitor
Terraform logs and set alerts.
9. Keep track of API rate limits and adjust `-parallelism` if
needed.