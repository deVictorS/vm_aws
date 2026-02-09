#./desligar_vm.sh (desligar)
#!/bin/bash

cd ../terraform

echo "Desligando VM. . ."

#muda para stopped sem destruir o recurso
terraform apply -var="status_da_vm=stopped" -auto-approve

echo "Instância desligada com sucesso!"