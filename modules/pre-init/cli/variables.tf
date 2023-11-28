variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "KIT_SAPCAR_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPCAR_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "KIT_SWPM_FILE"
    validation {
    condition = fileexists("${var.KIT_SWPM_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "KIT_SAPHOSTAGENT_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPHOSTAGENT_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "KIT_SAPEXE_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPEXE_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "KIT_SAPEXEDB_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPEXEDB_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "KIT_IGSEXE_FILE"
    validation {
    condition = fileexists("${var.KIT_IGSEXE_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "KIT_IGSHELPER_FILE"
    validation {
    condition = fileexists("${var.KIT_IGSHELPER_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_ASE_FILE" {
	type		= string
	description = "KIT_ASE_FILE"
    validation {
    condition = fileexists("${var.KIT_ASE_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "KIT_EXPORT_DIR" {
	type		= string
	description = "KIT_EXPORT_DIR"
}
