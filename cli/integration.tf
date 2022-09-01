# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_generated_file" {
  content = <<-DOC
---
#Ansible vars_file containing variable values passed from Terraform.
#Generated by "terraform plan&apply" command.

#SAP system configuration
sap_sid: "${var.sap_sid}"
sap_ci_instance_number: "${var.sap_ci_instance_number}"
sap_ascs_instance_number: "${var.sap_ascs_instance_number}"
sap_main_password: "${var.sap_main_password}"

#Kits paths
kit_sapcar_file: "${var.kit_sapcar_file}"
kit_swpm_file: "${var.kit_swpm_file}"
kit_saphotagent_file: "${var.kit_saphotagent_file}"
kit_sapexe_file: "${var.kit_sapexe_file}"
kit_sapexedb_file: "${var.kit_sapexedb_file}"
kit_igsexe_file: "${var.kit_igsexe_file}"
kit_igshelper_file: "${var.kit_igshelper_file}"
kit_export_dir: "${var.kit_export_dir}"
kit_ase_file: "${var.kit_ase_file}"
...
    DOC
  filename = "ansible/sapnwase-vars.yml"
}
