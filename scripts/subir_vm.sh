#./subir_vm.sh (ligar ou reconectar)

#!/bin/bash

cd ../terraform

echo "Ligando a VM e limpando cache de IP..."
terraform apply -var="status_da_vm=running" -auto-approve

echo "Sincronizando novo IP com a AWS..."
terraform refresh -var="status_da_vm=running"

#captura o IP removendo qualquer resquício de texto ou aspas
IP_VM=$(terraform output -raw ip_publico | tr -d '\r\n')

while [ -z "$IP_VM" ] || [ "$IP_VM" == "null" ] || [ "$IP_VM" == "" ]; do
    echo "IP novo ainda não disponível... tentando novamente"
    sleep 3
    terraform refresh -var="status_da_vm=running" > /dev/null
    IP_VM=$(terraform output ip_publico | sed 's/.*= *//;s/"//g;s/ //g' | tr -d '\r\n')
done

echo "Novo IP Detectado: $IP_VM"

echo "Aguardando o servidor aceitar conexões..."
#loop até o SSH responder

echo "DEBUG: Testando se vejo a chave: $(ls ../keys/aws_estudo)"
echo "DEBUG: Testando se o IP existe: [$IP_VM]"
echo "DEBUG: Comando completo: ssh -i ../keys/aws_estudo ubuntu@$IP_VM"

until ssh -i ../keys/aws_estudo \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o ConnectTimeout=2 \
    -o IdentitiesOnly=yes \
    ubuntu@$IP_VM "exit" > /dev/null 2>&1
do
    echo "SSH ainda recusado... tentando em 5s"
    sleep 5
done

echo "Conectado com sucesso!"

# Comando de conexão final - Adicionei o IdentitiesOnly para evitar erros de agente
ssh -i ../keys/aws_estudo \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o IdentitiesOnly=yes \
    ubuntu@$IP_VM

# O script pausa aqui até você sair da VM (comando exit)
echo ""
read -p "Deseja desligar a VM agora? (s/n): " -n 1 RESPOSTA
echo ""

if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
    echo "Desligando a instância..."
    terraform apply -var="status_da_vm=stopped" -auto-approve
else
    echo "VM mantida em execução!"
fi