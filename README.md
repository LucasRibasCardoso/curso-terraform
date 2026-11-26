# AWS Network Infrastructure with Terraform

Infraestrutura base de rede na AWS provisionada com Terraform, seguindo boas práticas de modularização, isolamento de state remoto e validação automatizada com `pre-commit`.

## Arquitetura

O projeto provisiona uma VPC Multi-AZ na AWS com separação de camadas pública e privada:

- **VPC** com suporte e hostnames DNS habilitados
- **Subnets Públicas** (1 por AZ, com IP público automático e rota para Internet Gateway)
- **Subnets Privadas** (1 por AZ, com rota de saída via NAT Gateway dedicado na respectiva AZ)
- **Internet Gateway (IGW)**
- **Elastic IPs + NAT Gateways** (1 por AZ para alta disponibilidade)
- **Route Tables** (1 pública compartilhada e 1 privada por AZ) e respectivas associações

## Estrutura do Projeto

```text
.
├── .gitignore
├── .pre-commit-config.yaml         # Hooks de formatação e validação
├── bootstrap/                      # Projeto para configurar o backend s3 remoto
│   ├── provider.tf
│   └── s3.tf
└── infra/                          # Módulo raiz da infraestrutura
    ├── modules.tf                  # Orquestração dos módulos
    ├── provider.tf                 # Provider AWS, default_tags e backend S3
    ├── variables.tf                # Variáveis de entrada do ambiente
    └── modules/
        └── network/                # Módulo reutilizável de rede
            ├── igw.tf
            ├── ngw.tf
            ├── output.tf
            ├── route-table.tf
            ├── subnet.tf
            ├── variables.tf
            └── vpc.tf
```

## Boas Práticas Aplicadas

- **Bootstrap isolado (`bootstrap/`)**: o bucket S3 que armazena o `terraform.tfstate` é gerenciado separadamente com versionamento, criptografia `AES256`, bloqueio de acesso público e `lifecycle { prevent_destroy = true }`.
- **State remoto com Lock nativo**: configurado via `backend "s3"` com `encrypt = true` e `use_lockfile = true`.
- **Provisionamento dinâmico**: uso de `for_each` e `cidrsubnet()` para calcular os blocos CIDR sem sobreposição e facilitar a expansão para novas Availability Zones.
- **Versionamento travado**: `.terraform.lock.hcl` versionado no Git para garantir consistência do provider.
- **Qualidade de código**: `pre-commit-terraform` executando `terraform_fmt` e `terraform_validate` antes de cada commit.

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.17.0`
- [AWS CLI](https://aws.amazon.com/cli/) configurada com credenciais válidas
- [pre-commit](https://pre-commit.com/) *(opcional, para rodar os hooks locais)*

## Como Executar

### 1. Criar o bucket do Terraform State (`bootstrap/`)

Execute apenas uma vez para provisionar o bucket S3 do backend remoto:

```bash
cd bootstrap
terraform init
terraform apply
```

### 2. Configurar as variáveis (`infra/terraform.tfvars`)

Crie o arquivo `infra/terraform.tfvars` (ignorado pelo `.gitignore`) com os valores do ambiente:

```hcl
project_name = "curso-terraform"
region       = "us-east-1"
cidr_block   = "10.0.0.0/16"

availability_zones = {
  az_1a = {
    az     = "us-east-1a"
    netnum = 0
  }
  az_1b = {
    az     = "us-east-1b"
    netnum = 1
  }
}
```

### 3. Provisionar a rede (`infra/`)

```bash
cd ../infra
terraform init
terraform plan
terraform apply
```

## Limpeza (Evitar Custos)

> **Atenção:** NAT Gateways possuem cobrança por hora na AWS. Ao finalizar seus testes, destrua os recursos da camada `infra/`:

```bash
cd infra
terraform destroy
```

*(O bucket em `bootstrap/` pode ser mantido, pois possui custo irrisório quando armazena apenas o state vazio e está protegido por `prevent_destroy = true`.)*
