# Atlassian Operations Terraform Provider

This project aims to enable users to manipulate Operations resources in Atlassian (Jira Service Management and Compass), via Terraform.
It is a functional replication of the _now transitioned_ [Opsgenie Provider](https://github.com/opsgenie/terraform-provider-opsgenie).

The provider is still under development. It currently supports the following resources:

* Team
* Schedule (**incl.** Rotation)
* Escalation
* Email Integration
* API-Based Integration
* Notification Rule
* Routing Rule
* Custom Role
* Alert Policy
* User Contact

And the following data sources:
* User\*
* Team
* Schedule (**excl.** Rotation)

\*Due to the internal structure of the Operations, _user_ is implemented solely as a data source and supports **read operations only**.

### Related Links

- [Terraform Website](https://www.terraform.io)
- [Jira Service Management](https://www.atlassian.com/software/jira/service-management?tab=it-operations)
- [JSM Ops REST API](https://developer.atlassian.com/cloud/jira/service-desk-ops/rest/v2/intro/)
- [Compass Operations API](https://developer.atlassian.com/cloud/compass/rest/v1/intro/)

## How To Run Locally

The process to run the provider in a local environment requires the following steps:

- [Atlassian Operations Terraform Provider](#atlassian-operations-terraform-provider)
    - [Related Links](#related-links)
  - [How To Run Locally](#how-to-run-locally)
    - [1. Requirements](#1-requirements)
    - [2. Cloning the repository](#2-cloning-the-repository)
    - [3. Compiling \& Installing](#3-compiling--installing)
    - [4. Setting local overrides](#4-setting-local-overrides)
    - [5. Debugging](#5-debugging)
      - [5.1 Create a simple `main.tf` file:](#51-create-a-simple-maintf-file)
      - [5.2. Enable Debugging](#52-enable-debugging)
    - [6. Running Acceptance Tests](#6-running-acceptance-tests)

### 1. Requirements

This project requires the following programs to be installed on your computer, and their main executables to be
available in your PATH:

-	[Go](https://golang.org/doc/install) 1.22 (or higher, to build the provider plugin)
-	[Terraform](https://www.terraform.io/downloads.html) 1.9.5 (To test the plugin)


### 2. Cloning the repository

```bash
git clone git@github.com:atlassian/terraform-provider-atlassian-operations.git
```

### 3. Compiling & Installing
_Make sure that go is already installed and the command is available on your path.
Check the [Go Documentation](https://go.dev/wiki/SettingGOPATH) for instructions on how to add the
go executable to your path, if not already added._

While in the project directory, run the following commands:

```bash
go mod download
go install .
```
Go, _unless specified otherwise with the -o flag_, will install the resulting binary in the `$GOPATH/bin` directory.
If you do not know where your `$GOPATH` is, you can run:
```bash
go env GOPATH
```

### 4. Setting local overrides
This step is required for Terraform to use the plugin executable that you just compiled,
instead of the one downloaded from the Terraform Registry.

* For macOS & Linux: Create a file called `.terraformrc` in your `$HOME` directory
* For Windows: Create a file called `terraform.rc` in your `%APPDATA%` directory

Add the following content to the file:

```hcl
provider_installation {

   # "/Users/<YOUR_USERNAME>/go/bin" is the path to the compiled provider ($GOPATH/bin).
   # Change it accordingly if your configuration is different.
   dev_overrides {
      # Replace <YOUR_USERNAME> with your username
      "registry.terraform.io/atlassian/atlassian-operations" = "/Users/<YOUR_USERNAME>/go/bin"
   }

   # For all other providers, install them directly from their origin provider
   # registries as normal. If you omit this, Terraform will _only_ use
   # the dev_overrides block, and so no other providers will be available.
   direct {}
}
```

### 5. Debugging

#### 5.1 Create a simple `main.tf` file:

   ```hcl
   terraform {
   required_providers {
      atlassian-operations = {
         source = "registry.terraform.io/atlassian/atlassian-operations"
      }
   }
}

provider "atlassian-operations" {
   cloud_id        = var.atlassian_cloud_id
   domain_name     = var.atlassian_domain_name
   email_address   = var.atlassian_email_address
   token           = var.atlassian_token
   org_admin_token = var.atlassian_org_admin_token
   product_type    = var.atlassian_product_type
}

data "atlassian-operations_user" "example" {
   email_address = "user1@example.com"
   organization_id = "XXXXXXXXXXXXXXX"   // only required for Compass
}

output "example" {
   value = "data.atlassian-operations_user.example"
}
   ```

   You'll also need a `variables.tf` file (see the root directory for the complete variable definitions).

Instead of providing values in the _provider_ block directly, you can use environment variables in two ways:

**Option 1: Using .env file (Recommended)**

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file and fill in your actual values:
   ```bash
   TF_VAR_atlassian_cloud_id=your_actual_cloud_id
   TF_VAR_atlassian_domain_name=your_domain.atlassian.net
   TF_VAR_atlassian_email_address=user@example.com
   TF_VAR_atlassian_token=your_api_token_here
   TF_VAR_atlassian_org_admin_token=your_org_admin_token
   TF_VAR_atlassian_product_type=jira-service-desk
   ```

3. Source the environment variables before running Terraform:
   ```bash
   source .env
   terraform plan
   terraform apply
   ```

**Option 2: Direct environment variables**

You can also set the following environment variables directly:

```bash
export ATLASSIAN_OPS_CLOUD_ID=YOUR_CLOUD_ID
export ATLASSIAN_OPS_DOMAIN_NAME=YOUR_DOMAIN
export ATLASSIAN_OPS_API_EMAIL_ADDRESS=YOUR_EMAIL_ADDRESS
export ATLASSIAN_OPS_API_TOKEN=YOUR_TOKEN
export ATLASSIAN_OPS_API_ORG_ADMIN_TOKEN=YOUR_ORGANIZATION_ADMIN_TOKEN
export ATLASSIAN_OPS_PRODUCT_TYPE=YOUR_ATLASSIAN_OPERATIONS_PRODUCT
```

**Note:** The `.env` file approach is recommended as it keeps your secrets out of version control and makes it easier to manage different environments.

#### 5.2. Enable Debugging

To enable debugging for the provider and make it connect to Delve before carrying on with the execution of the
instructions in the .tf file, you need to set the `debug` flag to `true`, via altering the `flag.BoolVar` statement in
the `main.tf` file:

```go
package main
import "flag"
// ...

func main() {
   var debug bool

   flag.BoolVar(&debug, "debug", true, "set to true to run the provider with support for debuggers like delve")
   flag.Parse()

   // Rest of the main.go file
}
```
This will make the provider executable pause the execution and wait for a debugger to connect before proceeding.

With the default configuration, the provider binary is compiled **without debug information**.
To include the necessary debug information within the library, you need to build the provider with the
-gcflags="all=-N -l" flag. Afterward, you can run and attach the process to the Delve debugger with the `dlv` command.

```bash
go build -gcflags="all=-N -l" .
dlv exec --accept-multiclient --continue --headless ./terraform_provider_jsm_ops -- -debug
```
_Most IDEs do building with debug flags and attaching to Delve debugger in the background automatically when the
debugger is run from within their UI._

When the provider executable is run with this configuration, it will output a message similar to the following:

```bash
API server listening at: 127.0.0.1:63446
debugserver-@(#)PROGRAM:LLDB  PROJECT:lldb-1600.0.36.3 for arm64.
Got a connection, launched process /Users/username/Library/Caches/JetBrains/GoLand2024.2/tmp/GoLand/___go_build_github_com_atlassian_terraform_provider_jsm_ops (pid = 47822).
{"@level":"debug","@message":"plugin address","@timestamp":"2024-10-02T00:03:48.057576+03:00","address":"/var/folders/5n/wcvl0l8d4nx15qz3jy9jn7wh0000gn/T/plugin3023012805","network":"unix"}
Provider started. To attach Terraform CLI, set the TF_REATTACH_PROVIDERS environment variable with the following:

        TF_REATTACH_PROVIDERS='{"registry.terraform.io/atlassian/atlassian-operations":{"Protocol":"grpc","ProtocolVersion":6,"Pid":47822,"Test":true,"Addr":{"Network":"unix","String":"/var/folders/5n/wcvl0l8d4nx15qz3jy9jn7wh0000gn/T/plugin3023012805"}}}'
```

Simply follow the instructions as they are prompted. Either set the `TF_REATTACH_PROVIDERS` environment variable in
your terminal, or prepend it to your every Terraform command.

* Set the environment variable:
```bash
export TF_REATTACH_PROVIDERS=<_PROMPTED_STRING_AT_THE_DEBUG_CONSOLE_>
```

* Run the Terraform commands directly:
```bash
TF_REATTACH_PROVIDERS=<_PROMPTED_STRING_AT_THE_DEBUG_CONSOLE_> terraform plan
TF_REATTACH_PROVIDERS=<_PROMPTED_STRING_AT_THE_DEBUG_CONSOLE_> terraform apply
```

More information on how to use Delve with Terraform can be found in the
[Terraform documentation](https://developer.hashicorp.com/terraform/plugin/debugging).

### 6. Running Acceptance Tests
To run the acceptance tests, you need to set the provider configuration environment variables (as described in the [Debugging](#51-create-a-simple-maintf-file) section) plus additional test-specific environment variables.

**Option 1: Using .env.test file (Recommended)**

1. Copy the test environment template:
   ```bash
   cp .env.test.example .env.test
   ```

2. Edit the `.env.test` file with your actual values (includes both provider config and test variables)

3. Source the environment and run tests:
   ```bash
   source .env.test
   cd internal/provider
   go test -count=1 -v
   ```

**Option 2: Direct environment variables**

Set all required environment variables directly:

```bash
# Provider configuration (same as debugging section)
export ATLASSIAN_OPS_CLOUD_ID=YOUR_CLOUD_ID
export ATLASSIAN_OPS_DOMAIN_NAME=YOUR_DOMAIN
export ATLASSIAN_OPS_API_EMAIL_ADDRESS=YOUR_EMAIL_ADDRESS
export ATLASSIAN_OPS_API_TOKEN=YOUR_TOKEN
export ATLASSIAN_OPS_API_ORG_ADMIN_TOKEN=YOUR_ORGANIZATION_ADMIN_TOKEN
export ATLASSIAN_OPS_PRODUCT_TYPE=YOUR_ATLASSIAN_OPERATIONS_PRODUCT

# Test-specific variables
export ATLASSIAN_ACCTEST_EMAIL_PRIMARY=USER_EMAIL
export ATLASSIAN_ACCTEST_EMAIL_SECONDARY=ANOTHER_USER_EMAIL
export ATLASSIAN_ACCTEST_ORGANIZATION_ID=ORGANIZATION_ID
export TF_ACC=1
```

Then run the tests:
```bash
cd internal/provider
go test -count=1 -v
```

Acceptance tests do not require a main.tf file to be present, as they are run directly from the test files.

**Keep in mind that running acceptance tests will work on your existing site, which can result in notification emails being sent and extra usage fees.**
