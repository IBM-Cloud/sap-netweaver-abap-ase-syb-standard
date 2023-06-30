##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

REGION = ""  
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Region.
# Example: REGION = "eu-de"

ZONE = ""    
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Edit the variable value with your deployment Zone.
# Example: ZONE = "eu-de-1"

VPC = ""
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = ""
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = ""
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "" 
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [""]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# Input your existing id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_abap_ase-syb_std" , "~/.ssh/id_rsa_abap_ase-syb_std" , "/root/.ssh/id_rsa".


##########################################################
# VSI variables:
##########################################################

HOSTNAME = ""
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: DB-HOSTNAME = "ic4sapsys"

PROFILE = "bx2-4x16"
# The DB VSI profile. Supported profiles for DB VSI: bx2-4x16. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui

IMAGE = "ibm-redhat-8-6-amd64-sap-applications-2"
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images

##########################################################
# SAP system configuration
##########################################################

sap_sid = "NWD"
# SAP System ID

sap_ascs_instance_number = "01"
# The central ABAP service instance number. Should follow the SAP rules for instance number naming.
# Example: sap_ascs_instance_number = "01"

sap_ci_instance_number = "00"
# The SAP central instance number. Should follow the SAP rules for instance number naming.
# Example: sap_ci_instance_number = "06"

##########################################################
# Kit Paths
##########################################################

kit_sapcar_file = "/storage/NW75SYB/SAPCAR_1010-70006178.EXE"
kit_swpm_file =  "/storage/NW75SYB/SWPM10SP31_7-20009701.SAR"
kit_saphotagent_file = "/storage/NW75SYB/SAPHOSTAGENT51_51-20009394.SAR"
kit_sapexe_file = "/storage/NW75SYB/SAPEXE_900-80002573.SAR"
kit_sapexedb_file = "/storage/NW75SYB/SAPEXEDB_900-80002616.SAR"
kit_igsexe_file = "/storage/NW75SYB/igsexe_13-80003187.sar"
kit_igshelper_file = "/storage/NW75SYB/igshelper_17-10010245.sar"
kit_ase_file = "/storage/NW75SYB/51055443_1.ZIP"
kit_export_dir = "/storage/NW75SYB/EXP"
