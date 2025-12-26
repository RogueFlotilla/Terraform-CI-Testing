[server]
${c2_server_private_ip} ansible_user=ubuntu

[client]
${c2_client_private_ip} ansible_user=ubuntu

[all:vars]
havoc_repo='https://github.com/HavocFramework/Havoc.git'
havoc_install_dir='/home/ubuntu/Havoc'
golang_version='1.18'
python_version='3.10'
havoc_port='40056'
server_public_ip='${c2_server_private_ip}'
server_private_ip='${c2_client_private_ip}'