# Examples

This directory contains examples that are mostly used for documentation, but can also be run/tested manually via the Terraform CLI.

The document generation tool looks for files in the following locations by default. All other *.tf files besides the ones mentioned below are ignored by the documentation tool. This is useful for creating examples that can run and/or ar testable even if some parts are not relevant for the documentation.

* **provider/provider.tf** example file for the provider index page
* **data-sources/`full data source name`/data-source.tf** example file for the named data source page
* **resources/`full resource name`/resource.tf** example file for the named data source page

## Running Examples

To run any of these examples:

1. Navigate to the specific example directory (e.g., `cd examples/provider`)
2. Copy the environment template: `cp .env.example .env`
3. Edit the `.env` file with your actual Atlassian credentials
4. Source the environment variables: `source .env`
5. Initialize and run Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

**Note:** All examples use environment variables to keep sensitive credentials secure. Never commit actual credentials to version control.
