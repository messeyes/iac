# terraform — anotações de estudo

anotações dos meus estudos sobre terraform, infra as code (iac) e provisionamento de recursos em provedores de cloud.

## o que é o terraform?

é uma ferramenta de infraestrutura como código (iac), desenvolvida pela hashicorp, que permite criar, configurar e gerenciar recursos de infraestrutura através de arquivos de configuração.

em vez de criar tudo manualmente pelo painel de uma plataforma de cloud, é só escrever arquivos `.tf` e utilizar o terraform para executar essas configurações.

com isso, conseguimos manter a infraestrutura versionada no git, reutilizar configurações e acompanhar as alterações feitas nos ambientes.

## providers

os providers são responsáveis por conectar o terraform a diferentes plataformas e serviços.

cada provider disponibiliza recursos e configurações específicas da plataforma que queremos utilizar.

durante meus estudos, trabalhei com três provedores:

- **aws:** amazon web services.
- **azure:** microsoft azure.
- **google:** google cloud platform (gcp).

o terraform funciona como a ferramenta que interpreta as configurações, enquanto os providers permitem que ele se comunique com as APIs das plataformas para criar e gerenciar os recursos.

## aws — amazon web services

a aws é a plataforma de cloud da amazon. oferece serviços de computação, armazenamento, banco de dados, redes, monitoramento e muito mais.

### configuração do provider

para utilizar a aws, primeiro é necessário declarar o provider no projeto.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

- `source`: indica de onde o terraform deve baixar o provider.
- `version`: define a versão utilizada.
- `region`: define a região da aws onde os recursos serão criados.

### autenticação

utilizei um usuário específico do iam para permitir que o terraform acessasse a minha conta aws.

comando para configurar as credenciais:

```bash
aws configure
```

esse comando solicita:

- aws access key id
- aws secret access key
- região padrão
- formato de saída

para verificar qual identidade está sendo utilizada:

```bash
aws sts get-caller-identity
```

as credenciais devem ser geradas no iam e nunca devem ser publicadas no github.

### criando um bucket s3

o s3 é um serviço de armazenamento de objetos da aws. pode ser utilizado para armazenar arquivos, imagens, documentos, backups e outros dados.

exemplo de configuração:

```hcl
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "mess-bucket-iac"

  tags = {
    Name = "mess-bucket-iac"
    Iac  = "True"
  }
}
```

nesse exemplo:

- `resource`: declara um recurso que o terraform irá gerenciar.
- `aws_s3_bucket`: tipo de recurso disponibilizado pelo provider da aws.
- `s3_bucket`: nome local utilizado para referenciar esse recurso.
- `bucket`: nome do bucket que será criado.

### como utilizaria em um projeto real?

em uma aplicação web, poderia utilizar o s3 para armazenar imagens de perfil, documentos enviados pelos usuários e arquivos estáticos.

também poderia integrar o bucket com outros serviços da aws, como o CloudFront, para distribuir arquivos com melhor desempenho.

## azure — microsoft azure

o azure é a plataforma de cloud da microsoft. assim como a aws, oferece serviços de computação, armazenamento, redes, bancos de dados e monitoramento.

durante meus estudos, utilizei o provider `azurerm`, disponibilizado pela hashicorp.

### configuração do provider

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.93.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
```

alguns pontos importantes:

- `azurerm`: provider utilizado para trabalhar com recursos do azure.
- `version`: define a versão do provider.
- `features`: configura comportamentos específicos do provider.
- `prevent_deletion_if_contains_resources`: impede que o terraform exclua um resource group que ainda contém recursos, conforme o comportamento configurado pelo provider.

### resource group

o resource group é um agrupamento lógico utilizado para organizar recursos dentro do azure.

por exemplo, posso criar um grupo para reunir todos os recursos relacionados ao ambiente de homologação de uma aplicação.

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "mess-hmg"
  location = "brazilsouth"

  tags = {
    Iac = "True"
  }
}
```

nesse exemplo:

- `azurerm_resource_group`: tipo de recurso do azure.
- `rg`: nome local do recurso.
- `name`: nome do resource group.
- `location`: região onde o recurso será criado.
- `tags`: informações utilizadas para identificar e organizar recursos.

### virtual network

a virtual network (vnet) permite criar uma rede privada dentro do azure, possibilitando a comunicação entre recursos e o controle de tráfego de rede.

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "mess-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Iac = "True"
  }
}
```

alguns detalhes:

- `resource_group_name`: utiliza o nome do resource group criado anteriormente.
- `location`: utiliza a mesma região do resource group.
- `address_space`: define o espaço de endereçamento IP da rede.

uma coisa importante que aprendi aqui é que podemos referenciar atributos de outros recursos diretamente.

por exemplo:

```hcl
azurerm_resource_group.rg.name
```

isso evita repetir valores e permite que o terraform identifique dependências entre os recursos.

### como utilizaria em um projeto real?

em uma aplicação corporativa, poderia utilizar o azure para criar toda a infraestrutura de homologação e produção.

o resource group ajudaria a organizar os recursos de cada ambiente, enquanto a virtual network permitiria separar e controlar a comunicação entre servidores, bancos de dados e outros serviços.

também poderia utilizar serviços como Azure Virtual Machines, Azure Database e Azure App Service para hospedar a aplicação.

## gcp — google cloud platform

o google cloud platform é a plataforma de cloud do google. disponibiliza serviços de computação, armazenamento, redes, bancos de dados, inteligência artificial e análise de dados.

durante meus estudos, utilizei o provider `google`.

### configuração do provider

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.17.0"
    }
  }
}

provider "google" {
  project = "crafty-stock-415315"
  region  = "us-central1"
}
```

alguns detalhes:

- `google`: provider utilizado para trabalhar com recursos do gcp.
- `version`: define a versão do provider.
- `project`: identifica o projeto dentro do google cloud.
- `region`: define a região padrão para os recursos que utilizam essa configuração.

a autenticação pode ser feita utilizando uma conta de serviço ou credenciais do google cloud.

para desenvolvimento local, também é possível utilizar o comando:

```bash
gcloud auth application-default login
```

esse comando configura as credenciais padrão de aplicação utilizadas por ferramentas como o terraform.

### compute engine

o compute engine é o serviço do google cloud utilizado para criar e gerenciar máquinas virtuais.

no exemplo abaixo, estou declarando uma máquina virtual com o nome `mess-vm`.

```hcl
resource "google_compute_instance" "vm" {
  name         = "mess-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}
```

alguns detalhes:

- `google_compute_instance`: tipo de recurso utilizado para criar uma máquina virtual.
- `machine_type`: define o tipo de máquina e seus recursos computacionais.
- `zone`: define a zona onde a máquina será criada.
- `boot_disk`: configura o disco utilizado para inicializar a máquina.
- `image`: define o sistema operacional da máquina virtual.
- `network_interface`: configura a interface de rede da máquina.

### como utilizaria em um projeto real?

poderia utilizar o compute engine para hospedar uma aplicação backend, configurar uma máquina virtual com linux e instalar os serviços necessários para executar a aplicação.

também poderia integrar a máquina virtual com outros serviços do gcp, como Cloud SQL para banco de dados e Cloud Storage para armazenamento de arquivos.

## comandos do terraform

alguns comandos que utilizei durante os estudos:

### inicializar o projeto

```bash
terraform init
```

inicializa o diretório de trabalho, baixa os providers necessários e prepara o ambiente.

### validar a configuração

```bash
terraform validate
```

verifica se os arquivos de configuração estão sintaticamente corretos e se a configuração é válida.

### visualizar o plano

```bash
terraform plan
```

mostra quais alterações o terraform pretende realizar na infraestrutura, sem aplicá-las.

### aplicar alterações

```bash
terraform apply
```

executa as alterações propostas pelo terraform.

antes de confirmar, é importante revisar o plano para entender quais recursos serão criados, alterados ou removidos.

### destruir recursos

```bash
terraform destroy
```

remove os recursos gerenciados pelo terraform.

é importante ter cuidado com esse comando, principalmente quando estamos trabalhando com ambientes reais.

## terraform state

o state é responsável por armazenar informações sobre os recursos que o terraform gerencia.

ele permite que o terraform compare a configuração declarada nos arquivos `.tf` com o estado conhecido da infraestrutura.

alguns comandos:

```bash
terraform state list
```

lista os recursos registrados no state.

```bash
terraform state show <recurso>
```

mostra os detalhes de um recurso específico.

o state é importante para o funcionamento do terraform e deve ser tratado com cuidado, pois pode conter informações sensíveis.

em projetos reais, é comum utilizar um backend remoto para armazenar o state, permitindo que várias pessoas trabalhem com a mesma infraestrutura de forma controlada.

## workspaces

os workspaces permitem manter estados diferentes para uma mesma configuração.

durante o estudo, utilizei o workspace `staging`.

comandos:

```bash
terraform workspace list
```

lista os workspaces existentes.

```bash
terraform workspace show
```

mostra o workspace atual.

```bash
terraform workspace new staging
```

cria um novo workspace.

```bash
terraform workspace select staging
```

seleciona um workspace existente.

também podemos utilizar o workspace dentro dos arquivos `.tf`:

```hcl
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "mess-bucket-iac-${terraform.workspace}"
}
```

assim, o nome do bucket pode variar de acordo com o workspace selecionado.

## recursos e data sources

### resource

o `resource` é utilizado para criar e gerenciar recursos da infraestrutura.

exemplo:

```hcl
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "meu-bucket-iac"
}
```

### data

o `data` é utilizado para consultar informações de recursos que já existem.

exemplo:

```hcl
data "aws_s3_bucket" "existing_bucket" {
  bucket = "meu-bucket-iac"
}
```

a principal diferença:

- `resource`: cria e gerencia um recurso.
- `data`: consulta informações de um recurso existente.

não é necessário declarar um data source para consultar um recurso que já está sendo gerenciado pelo próprio módulo. nesse caso, podemos utilizar diretamente a referência ao resource.

## 8. módulos

os módulos permitem organizar configurações e reutilizar partes da infraestrutura.

durante meus estudos, comecei a separar a configuração do s3 em um módulo próprio.

uma estrutura possível:

```text
.
├── main.tf
├── outputs.tf
├── variables.tf
└── modules/
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

### chamando um módulo

no `main.tf` da raiz:

```hcl
module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = "meu-bucket-iac"
}
```

o atributo `source` indica onde está localizado o módulo.

### outputs

os outputs permitem expor informações de recursos para que possam ser utilizadas fora do módulo.

dentro de `modules/s3/outputs.tf`:

```hcl
output "bucket_domain_name" {
  value = aws_s3_bucket.s3_bucket.bucket_domain_name
}
```

na raiz do projeto:

```hcl
output "bucket_domain_name" {
  value = module.s3.bucket_domain_name
}
```

cada módulo possui seu próprio escopo. por isso, um recurso declarado na raiz não pode ser referenciado diretamente dentro de `modules/s3`, e vice-versa.

## problemas encontrados durante os estudos

### credenciais inválidas

ao executar `terraform plan`, encontrei um erro relacionado às credenciais da aws.

o problema aconteceu porque foram informados valores incorretos nas credenciais.

aprendi que é necessário gerar access keys para um usuário do iam e configurar essas chaves utilizando `aws configure`.

### bucket já existente

durante o `terraform apply`, encontrei o erro `BucketAlreadyOwnedByYou`.

isso aconteceu porque o bucket que eu estava tentando criar já existia na minha conta aws.

aprendi que o terraform precisa ter conhecimento do estado dos recursos que gerencia. quando um recurso já existe, é necessário avaliar se ele deve ser importado para o state ou se a configuração deve utilizar outro nome.

### referência inválida em módulos

ao trabalhar com módulos, encontrei erros de referência relacionados a recursos e data sources.

aprendi que:

- strings precisam estar entre aspas.
- recursos precisam estar declarados no módulo em que são referenciados.
- cada módulo possui seu próprio escopo.
- outputs devem apontar para recursos ou valores realmente declarados naquele módulo.

## como utilizaria terraform em um projeto real?

pensando em uma aplicação backend com frontend, banco de dados e armazenamento de arquivos, poderia utilizar o terraform para provisionar toda a infraestrutura necessária.

por exemplo:

| necessidade | aws | azure | gcp |
|---|---|---|---|
| máquina virtual | EC2 | Virtual Machines | Compute Engine |
| armazenamento de arquivos | S3 | Blob Storage | Cloud Storage |
| banco de dados gerenciado | RDS | Azure Database | Cloud SQL |
| rede privada | VPC | Virtual Network | VPC Network |
| monitoramento | CloudWatch | Azure Monitor | Cloud Monitoring |

em um projeto real, o fluxo seria mais ou menos assim:

1. escrever os arquivos `.tf` declarando os recursos necessários.
2. configurar o provider e a autenticação da plataforma escolhida.
3. executar `terraform init` para inicializar o projeto.
4. executar `terraform validate` para validar a configuração.
5. executar `terraform plan` para revisar as alterações.
6. executar `terraform apply` para provisionar a infraestrutura.
7. acompanhar e versionar as alterações realizadas.

também seria importante separar ambientes de desenvolvimento, homologação e produção, utilizar um backend remoto para o state, controlar permissões e integrar o terraform ao pipeline de CI/CD.

