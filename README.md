# Infra GCP em Terraform
## Objetivo
Este projeto tem como objetivo a criação de uma infraestrutura em código na Google Cloud Platform, atualmente o código constrói as seguintes funcionalidades:

 - **Pub/Sub**
   - **Schema** do tópico em Protocol Buffer
   - **Tópico** que recebe as mensagens (_terraform-topic_)
   - **Tópico** que recebe as mensagens **não** suportadas (_terraform-dead-message-topic_)
   - **Assinatura** que lê as mensagens do tópico (_terraform-topic_) escreve diretamente no **BigQuery** (_terraform-topic-sub_)
   - **Assinatura** que lê as mensagens do tópico de mensagens **não** suportadas (_terraform-dead-message-topic-sub_)
 - **BigQuery**
   - **Dataset** em que a tabela de streaming será criada
   - **Tabela** de streaming que terá os dados escritos a partir da assinatura
 - **Cloud Storage**
   - **Bucket do Pub/Sub**: onde ficarão armazenados os schemas do tópico e da tabela do BigQuery
   - Inserção do schema do tópico e da tabela do BigQuery

## Requerimentos
Para que o projeto possa funcionar é necessário que você possua os seguintes requisitos:

 - [Terraform](https://developer.hashicorp.com/terraform/downloads?product_intent=terraform) instalado em sua máquina
 - Uma conta de serviço com **acesso** de leitura e escrita (é recomendado que possua cargo de proprietário aos serviços a seguir) ao Pub/Sub, Cloud Storage e BigQuery 
 - Conhecimento prévio a sintaxe de protocol buffer e aos tipos de dados do BigQuery

## Variáveis
O arquivo _variables.tf_ no diretório do projeto possui as variáveis que são usadas no código principal, o que você precisará alterar será:
- O nome do **projeto**
O projeto será o ID que você irá encontrar na página principal do GCP. 

- O nome do arquivo das **credenciais de acesso**
Para conseguir o arquivo com essas credenciais, você irá precisar ir na página de IAM do GCP e criar uma **conta de serviço** para que o código do Terraform possa utilizar, após criar a conta será possível baixar as credenciais.
**Obs: coloque o arquivo na pasta raiz do projeto, não coloque em subpastas ou fora da pasta raiz.**

- O nome do arquivo com os schemas do tópico e da tabela do BigQuery
No projeto do Github está os schemas que foram utilizados, você pode utilizá-los para realizar testes e editar conforme desejar.

Todas as outras variáveis não precisam ser alteradas, a não ser que você deseje alterar o nome das funcionalidades.

## Schemas
### Schema do tópico
O schema do tópico foi pensado para segurança e rapidez em que os dados são processados, por exemplo, se um tópico não possui um schema para definir como as mensagens irão chegar, é certo que muitas mensagens ficarão retidas e presas na assinatura quando a mesma tentar escrever na tabela do BigQuery, ou então essas mensagens serão perdidas e descartadas pela assinatura quando ela não conseguir escrever os dados na tabela que possui um schema próprio.
### Schema da tabela
O schema da tabela é **obrigatório**, sem ele não é possível criar a tabela e é o que define a estrutura dos dados.

## O que precisa ser feito
Para que o projeto possa funcionar, tenha certeza que você possui todos os requisitos necessários, adicione nas variáveis o ID do projeto e nome do arquivo das credenciais, efetue um pull em sua máquina com o link do projeto e abra seu terminal ou shell. Após isso digite no seu terminal:

    terraform init
 
E em seguida:

    terraform apply

Com isso o código irá iniciar e você verá o passo a passo do terraform ao criar as funcionalidades, primeiro ele irá passar pelo processo de validação dos serviços e irá lhe pedir a confirmação para criá-los em seu projeto na nuvem, digite '_yes_' quando for pedido e aguarde, ele irá criar todos os serviços e você poderá testar sem maiores problemas.

Para destruir os serviços que você criou, basta digitar no seu terminal:

    terraform destroy
Isso fará com que todos os serviços criados a partir do terraform sejam destruídos, não é obrigatório que você os destrua se assim desejar fazer manutenções ou modificações, você pode apenas digitar _terraform apply_ novamente para que as modificações sejam aplicadas.

## Testes
Você pode realizar o teste de escrita no BigQuery com uma mensagem de testes pronta, basta ir no serviço do Pub/Sub e abrir o tópico criado com o terraform, após isso abra a sessão de 'mensagens' e clique em 'publicar mensagem' na etapa 1 e insira esta mensagem e clique em publicar:
 
>{  
"user_id": "fccc421bbbdb5ca03c6af6938afd887b75b5d249030fa6ed73969fde787ed234",  
"ip": "7.41.69.57",  
"action": "acessou-perfil",  
"brand": "Jesus",  
"traits": {  
"name": "Emanuel Cavalcanti",  
"email": "rochamatheus@gmail.com",  
"birthday": "1994-03-28",  
"created_at": "2022-01-12 00:23:03",  
"phone": "+55 61 4239 3689",  
"user_id": "fccc421bbbdb5ca03c6af6938afd887b75b5d249030fa6ed73969fde787ed234",  
"timezone": "America/Santiago",  
"gender": "M",  
"info": {  
"brand": "Jesus",  
"department": "Diretoria",  
"role": "Engenheiro elétrico",  
"permissions": [  
"Viewer"  
]  
}  
},  
"properties": {  
"post_action": null,  
"post_id": null,  
"post_name": null,  
"post_type": null,  
"post_description": null,  
"post_url": null,  
"post_owner": null,  
"post_status": null  
},  
"browser": {  
"version": "null",  
"value": "Opera/8.38.(Windows 95; bo-CN) Presto/2.9.178 Version/10.00"  
},  
"device": {  
"type": "Windows",  
"token": "iPhone; CPU iPhone OS 4_2_1 like Mac OS X",  
"enabled": false  
},  
"request": {  
"value": "OPTIONS",  
"timestamp": "2023-08-21 02:33:06"  
},  
"timestamp": "2023-05-05 20:14:08",  
"ingestion_at": "2023-07-07 20:07:47"  
}

Após isso verifique na sua tabela do BigQuery se a linha com os dados em questão foram criadas.