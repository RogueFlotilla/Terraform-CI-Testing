output "variables" { 
  value = <<-EOF
            local.is_linux : ${local.is_linux}
            local.region : ${local.region}
            local.avl_zone : ${local.avl_zone}
            local.terraform_root : ${local.terraform_root}
            local.terraform_parent : ${local.terraform_parent}
            local.win_wsl_dir : ${local.win_wsl_dir}
            local.shared_files_location : ${local.shared_files_location}
            local.shared_config_profile : ${local.shared_config_profile}
            local.ssh_user : ${local.ssh_user}
            local.key_location : ${local.key_location}
            local.key_name : ${local.key_name}
            local.scripts : ${local.scripts}
            local.evilginx_domain_name : ${local.evilginx_domain_name}
            local.expc2var : ${local.expc2var}
            local.evilvar : ${local.evilvar}
            local.phishvar : ${local.phishvar}
            local.httpvar : ${local.httpvar}
            local.redvar : ${local.redvar}
            local.webvar : ${local.webvar}
            local.havvar : ${local.havvar}
            local.slivar : ${local.slivar}
            EOF
}