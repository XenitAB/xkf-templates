# xkf-templates

Terraform template files to be used by XKF instances. An XKF instance is a highly opinionated Kubernetes platform running
in either Azure (AKS) or AWS (EKS) and is using the Xenit Terraform modules in [terraform-modules](https://github.com/XenitAB/terraform-modules).
An XKF instance is made up he following major parts:

* Governance - Azure AD related resources for authentication and authorization
* Core - Core infrastructure such as network related resources
* AKS/EKS - The Kubernetes kluster including platform components
* HUB - Resources related to CI/CD

The Terraform source files (*.tf) in this repository are generic and and can be used "as is" in an XKF instance. There is
however one exception: `tenant.tf`. The `tenant.tf` files are intended to contain instance specific configuration that potentially
can't be configured as variable values but using other Terraform constructs such as data sources. All other instance specific
configuration is done by setting values to variables in `*.tfvars` files.

## Repository structure

The top level folders `azure`and `aws` contain the template files per cloud provider and also the structure that shall be used
at the top level of the XKF instance repositories. Each top level folder also contain the `.ci` and `.github` sub
folders and are only relevant if Azure Devops or Github is being used as XKF instance repository. When creating a new XKF
instance, copy the entire content of either `azure` or `aws` into the top level of the repository and modify the `tenant.tf` and
`*.tfvars` according to your setup.

## Upgrade

This repository also contain support for automatic upgrade to new template versions for:

* Github - By using a Github Action
* Azure Devops - By using a Azure Devops pipieline

The automatic update runs as a CI job in the instance repository and continuously checks for new releases of
`xkf-templates`. The CI job code is located either in the `.ci` or `.github` folder. When a new release is found, the CI job:

* Clones the `xkf-templates` repository and uses the latest release tag
* Updates only the generic code of the instance repository in a new branch
* Creates a PR for that branch

The generic code is:

* The Terraform source files (*.tf) except for the files named `tenant.tf`
* The `Makefile`
* The content of the `.ci` or `.github` folder depending on if Azure Devops or Github being is used.

The upgrade will not modify the `tenant.tf` and `*.tfvars` files.
