module "pre-init-schematics" {
  source  = "./modules/pre-init"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "pre-init-cli" {
  source  = "./modules/pre-init/cli"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  KIT_SAPCAR_FILE = var.KIT_SAPCAR_FILE
  KIT_SWPM_FILE = var.KIT_SWPM_FILE
  KIT_SAPHOSTAGENT_FILE = var.KIT_SAPHOSTAGENT_FILE
  KIT_SAPEXE_FILE = var.KIT_SAPEXE_FILE
  KIT_SAPEXEDB_FILE = var.KIT_SAPEXEDB_FILE
  KIT_IGSEXE_FILE = var.KIT_IGSEXE_FILE
  KIT_IGSHELPER_FILE = var.KIT_IGSHELPER_FILE
  KIT_EXPORT_DIR = var.KIT_EXPORT_DIR
  KIT_ASE_FILE = var.KIT_ASE_FILE
}

module "precheck-ssh-exec" {
  source  = "./modules/precheck-ssh-exec"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  depends_on	= [ module.pre-init-schematics ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  HOSTNAME  = var.HOSTNAME
  SECURITY_GROUP = var.SECURITY_GROUP
}

module "vpc-subnet" {
  source  = "./modules/vpc/subnet"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE  = var.ZONE
  VPC = var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET  = var.SUBNET
}

module "volumes" {
  source		= "./modules/volumes"
  depends_on	= [ module.pre-init-schematics, module.pre-init-cli ]
  ZONE			= var.ZONE
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.HOSTNAME
  VOL1			= local.VOL1
  VOL2			= local.VOL2
  VOL3			= local.VOL3
  VOL4			= local.VOL4
  VOL5			= local.VOL5
}

module "vsi" {
  source		= "./modules/vsi"
  depends_on	= [ module.volumes , module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.HOSTNAME
  PROFILE		= var.PROFILE
  IMAGE			= var.IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUMES_LIST	= module.volumes.volumes_list
  SAP_SID		= var.SAP_SID
}

module "app-ansible-exec-schematics" {
  source  = "./modules/ansible-exec"
  depends_on	= [ module.vsi , local_file.ansible_inventory , local_file.tf_ansible_vars_generated_file ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP  = data.ibm_is_instance.vsi.primary_network_interface[0].primary_ip[0].address
  PLAYBOOK = "sap-abap-ase-syb-standard.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  
}

module "ansible-exec-cli" {
  source  = "./modules/ansible-exec/cli"
  depends_on	= [ module.vsi , local_file.ansible_inventory , local_file.tf_ansible_vars_generated_file , module.pre-init-cli ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  IP  = data.ibm_is_instance.vsi.primary_network_interface[0].primary_ip[0].address
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  SAP_MAIN_PASSWORD = var.SAP_MAIN_PASSWORD
  PLAYBOOK = "sap-abap-ase-syb-standard.yml"
}