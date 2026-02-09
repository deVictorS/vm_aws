echo "Iniciando provisionamento com Ansible. . ."

cd ../terraform

IP_VM=$(terraform output -raw ip_publico | tr -d '\r\n')

#executa Ansible apontando para o IP e chave da VM
ansible-playbook -i "$IP_VM," -u ubuntu --private-key ../keys/aws_estudo \
    --ssh-common-args='-o StrictHostKeyChecking=no' \
    ../ansible/playbook.yml

echo "Provisionamento concluído!"