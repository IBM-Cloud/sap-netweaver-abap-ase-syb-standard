# Central SAP Netweaver and ASE DB Automated Deployment

## Description
This automation solution is designed for the deployment of [**Central SAP Netweaver on ASE DB**](https://cloud.ibm.com/docs/sap?topic=sap-intro-automate-nw-asesyb-terraform-ansible&interface=terraform) on a central instance. The SAP solution will be deployed on top of one of the following Operating Systems: **SUSE Linux Enterprise Server 15 SP 4 for SAP**, **SUSE Linux Enterprise Server 15 SP 3 for SAP**, **Red Hat Enterprise Linux 8.6 for SAP**, **Red Hat Enterprise Linux 8.4 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing [Deployment Server (BASTION Server) with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup).

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified. IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen.

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Prerequisites](#12-prerequisites)
- [1.3 VSI Configuration](#13-vsi-configuration)
- [1.4 VPC Configuration](#14-vpc-configuration)
- [1.5 Files description and structure](#15-files-description-and-structure)
- [1.6 Input variabiles](#16-input-variables)
- [2.1 Executing the deployment of **Standard SAP Netweaver and ASE installation** in GUI (Schematics)](#21-executing-the-deployment-of-standard-sap-netweaver-and-ase-installation-in-gui-schematics)
- [2.2 Executing the deployment of **Standard SAP Netweaver and ASE installation** in CLI](#22-executing-the-deployment-of-standard-sap-netweaver-and-ase-installation-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media
SAP Netweaver installation media used for this deployment is the default one for **SAP Netweaver 7.5 and SAP ASE 16** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- From the SAP Portal, download the SAP kits on the Deployment Server. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 1.3 VSI Configuration
The VSI OS images that are supported for this solution are the following:

For Netweaver primary application server
- ibm-redhat-8-6-amd64-sap-applications-4
- ibm-redhat-8-4-amd64-sap-applications-7
- ibm-sles-15-4-amd64-sap-applications-6
- ibm-sles-15-3-amd64-sap-applications-9

The VSI will be accessible via SSH, as root user, based on the SSH key and IBM Cloud SSH keys UUID provided.  
The following storage volumes are created during provisioning for DB and SAP APP VSI:

SAP Netweaver PAS VSI Disks:
- 1 x 32 GB disk with 10 IOPS / GB - DATA
- 1x 32 GB disk with 10 IOPS / GB - SWAP
- 1 x 64 GB disk with 10 IOPS / GB - DATA
- 1 x 128 GB disk with 10 IOPS / GB - DATA
- 1 x 256 GB disk with 10 IOPS / GB - DATA

In order to perform the deployment, either the CLI component or the GUI component (Schematics) of the automation solution can be used.

## 1.4 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

## 1.5 Files description and structure

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment of a VSI, in an EXISTING VPC, with Subnet and Security Group. The VSI is intended to be used for the data base instance and for the application instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Bash scripts used for the checking of the prerequisites required by SAP VSI deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the **Central SAP Netweaver and ASE DB** installation.
- Ansible scripts to configure SAP Netweaver primary application server and a ASE SYB node.
Please note that Ansible is started by Terraform and must be available on the same host.

 - `modules` - directory containing the Terraform modules.
 - `ansible`  - directory containing the SAP ansible playbooks.
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (VPC, Hostname, Private IP).
 - `integration*.tf & generate*.tf` files - contain the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI.
 - `versions.tf` - contains the minimum required versions for Terraform and IBM Cloud provider.
 - `sch.auto.tfvars` - contains programatic variables.

## 1.6 Input variables

**General input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
PRIVATE_SSH_KEY | id_rsa private key content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.  Required only for Schematics Deployments.
ID_RSA_FILE_PATH | The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_abap_ase-syb_std
SSH_KEYS | List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys should be created for the same region as the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input:<br /> [ "r010-57kfc315-f9e5-46bf-bf61-d89a24a9ce7a", "r010-3fcdkfe7-d4a7-41ce-8bb3-d96e636b2c7e" ]
BASTION_FLOATING_IP | The FLOATING IP of the Bastion Server. Required only for Schematics Deployments
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Supported locations for IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br />Sample value: eu-de-2.
VPC | The name of an EXISTING VPC where to deploy the solution. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet in the same VPC and same zone. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SECURITY_GROUP | The name of an EXISTING Security group for the same VPC. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
ATR_NAME | The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available [here](https://cloud.ibm.com/observe/activitytracker)

**VSI input parameters:**

Parameter | Description 
----------|-------------
HOSTNAME | The Hostname for the VSI. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
PROFILE | The instance profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
IMAGE | The OS image used for the VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
SAP_SID | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
SAP_ASCS_INSTANCE_NUMBER | The central ABAP service instance number. Technical identifier for internal processes of ASCS| <ul><li>Must follow the SAP rules for instance number naming. Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
SAP_CI_INSTANCE_NUMBER | The SAP central instance number. Technical identifier for internal processes of CI| <ul><li>Must follow the SAP rules for instance number naming. Consists of a two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
KIT_SAPCAR_FILE  | Path to sapcar binary | As downloaded from SAP Support Portal
KIT_SWPM_FILE | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXE_FILE | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPEXEDB_FILE | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSEXE_FILE | Path to IGS archive (SAR) | As downloaded from SAP Support Portal
KIT_IGSHELPER_FILE | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal
KIT_SAPHOSTAGENT_FILE | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
KIT_ASE_FILE | Path to SAP ASE DB archive (ZIP) | As downloaded from SAP Support Portal
KIT_EXPORT_DIR | Path to Netweaver Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path

 **Obs***: <br />

- The password for the SAP system will be asked interactively, in CLI, during `terraform plan` step and will not be available after the deployment.

Parameter | Description | Requirements
----------|-------------|-------------
SAP_MAIN_PASSWORD | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li></ul>

- Sensitive - The variable value is not displayed in your Schematics logs and it is hidden in the input field, also is not displayed in your tf files details after terrafrorm plan&apply commands for CLI Deployments<br />
- The following parameters must have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

## 2.1 Executing the deployment of **Standard SAP Netweaver and ASE installation** in GUI (Schematics)

### Steps to follow:

1.  Make sure you have the [required IBM Cloud IAM 
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.

4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the logs to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

    In the output of the Schematics Apply Plan the private IP address of the VSI host and the hostname will be displayed.

## 2.2 Executing the deployment of **Standard SAP Netweaver and ASE installation** in CLI

### IBM Cloud API Key
During the terraform planning phase, when the command 'terraform plan --out plan1' is executed, the IBM Cloud API Key will be interactivlly requested.
An IBM Cloud API key can be created [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The following parameters can be set in `input.auto.tfvars` file, as in the example bellow:

**Genaral input parameters**

```shell
##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

REGION = "eu-de"  
# The cloud region where to deploy the solution. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-1"    
# The cloud zone where to deploy the solution. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-1"

VPC = "ic4sap"
# The name of an EXISTING VPC where to deploy the solution. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# The name of an EXISTING Security group for the same VPC. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet" 
# The name of an EXISTING Subnet in the same VPC and same zone. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680372t3c", "r011-8f72v884-c17f-4500-af8f-d05500374t3c"]
# List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys should be created for the same region as the VSI. Can contain one or more IDs. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# id_rsa private key file path, in OpenSSH format, with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path on the BASTION Server (Deployment Server).
# Examples: "ansible/id_rsa_abap_ase-syb_std" , "~/.ssh/id_rsa_abap_ase-syb_std" , "/root/.ssh/id_rsa".

##########################################################
# Activity Tracker variables:
##########################################################

ATR_NAME = "atr-eu-de"
# The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tr"
```

**VSI input parameters**

```shell
##########################################################
# VSI variables:
##########################################################

HOSTNAME = "ic4sapsys"
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: "Hostnames of SAP ABAP Platform servers".
# Example: DB-HOSTNAME = "ic4sapsys"

PROFILE = "bx2-4x16"
# The instance profile used for the VSI. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211
# The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images

```

**SAP input parameters:**

```shell
##########################################################
# SAP system configuration
##########################################################

SAP_SID = "SY1"
# The SAP system ID. Identifies the entire SAP system

SAP_ASCS_INSTANCE_NUMBER = "01"
# The central ABAP service instance number. Technical identifier for internal processes of CI. Must follow the SAP rules for instance number naming.
# Example: SAP_ASCS_INSTANCE_NUMBER = "01"

SAP_CI_INSTANCE_NUMBER = "00"
# The SAP central instance number. Must follow the SAP rules for instance number naming.
# Example: SAP_CI_INSTANCE_NUMBER = "06"

##########################################################
# Kit Paths
##########################################################

KIT_SAPCAR_FILE = "/storage/NW75SYB/SAPCAR_1010-70006178.EXE"
KIT_SWPM_FILE =  "/storage/NW75SYB/SWPM10SP31_7-20009701.SAR"
KIT_SAPHOSTAGENT_FILE = "/storage/NW75SYB/SAPHOSTAGENT51_51-20009394.SAR"
KIT_SAPEXE_FILE = "/storage/NW75SYB/SAPEXE_900-80002573.SAR"
KIT_SAPEXEDB_FILE = "/storage/NW75SYB/SAPEXEDB_900-80002616.SAR"
KIT_IGSEXE_FILE = "/storage/NW75SYB/igsexe_13-80003187.sar"
KIT_IGSHELPER_FILE = "/storage/NW75SYB/igshelper_17-10010245.sar"
KIT_ASE_FILE = "/storage/NW75SYB/51055443_1.ZIP"
KIT_EXPORT_DIR = "/storage/NW75SYB/EXP"
```

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY'  and  'SAP_MAIN_PASSWORD'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY'  and  'SAP_MAIN_PASSWORD'.
```

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
- [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov)
