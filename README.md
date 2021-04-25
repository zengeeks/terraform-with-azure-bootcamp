# Terraform with Microsoft Azure boot camp

Terraform を利用して Microsoft Azure のリソースを管理するためのトレーニング教材です。

- Terraform の基礎
- Azure Provider の利用
  - 初期設定
  - サンプル

## Terraform の基礎

### Terraform について

HashiCorp 社が提供する [Terraform](https://www.terraform.io/) は、Microsoft Azure などのクラウドプラットフォームや様々なインフラストラクチャのリソースを、コードで管理できるツールです。

必要なインフラストラクチャの構造を、 _HCL_ (_Hashicorp Configure Language_) と呼ばれる記法でコードとして書き起こし、そのコードをもとにリソースを管理します。Terraform は、管理対象のリソースの状態を取得し、コードとの差分を算出し反映することができるため、冪等性の担保に優れています。また、インフラストラクチャの構造をコードとして管理できるため、変更時のレビューや再現が容易になります。

実行には、Terraform CLI が利用できるほか、HashiCorp 社がホストするプラットフォーム [Terraform Cloud](https://www.terraform.io/cloud) も利用可能です。また、GitHub Actions や Azure Piipelines などの CI/CD パイプラインでもサポートされています。 

### ファイル構成

Terraform 言語は、 `.tf` の拡張子のファイルに記述します。エンコーディングは `UTF-8` です。改行は `LF` または `CRLF` どちらもサポートされていますが、Terraform のフォーマッターは `LF` に変換します。

Terrform では、単一の `.tf` ファイルで記述することも可能ですが、モジュールを作成する際の推奨構成に倣うと見通しがよいでしょう。

```bash: ドキュメントより抜粋
$ tree minimal-module/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
```

| ファイル | 説明 |
|----|----|
| (`README.md`) | 必要であれば |
| `main.tf` | エントリーポイントとなる `.tf` ファイル |
| `variables.tf`| 入力（引数）を定義する |
| `outputs.tf`| 出力を定義する |
| `modules/` | 内包するモジュール群 |
| (`LICENSE`) | パブリックに公開する場合はライセンスを定義する |

ファイル名に規定はありませんが、`_` で区切るスネークケースが多いようです。

詳しくは [Standard Module Structure - Terraform by HashiCorp](https://www.terraform.io/docs/language/modules/develop/structure.html) をご参照ください。

### Terraform の記法

Terraform のスクリプトは、 `HCL` で記述します。（ `json` でも記述できますが一般的ではありません）

下記のように `{}` で囲われたブロックの中に `provider` や `resource` を定義します。

- コメントは `#` がデフォルト（`//` や `/* */` も利用可能）
- [三項演算子](https://www.terraform.io/docs/language/expressions/conditionals.html) や [for 繰り返し処理](https://www.terraform.io/docs/language/expressions/for.html) ができる
- 変数などの命名に明確な規則はありませんが、 `_` で区切るスネークケースが多い（ Azure のリソース名は `-` で区切るケバブケースが多いので注意）

```hcl:sample
# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Japan East"
}
```

| よく使うキーワード | 解説 |
|----|----|
| `variable` | 入力させる変数（引数）を定義する。 `var.` で参照する。 |
| `output` | 出力を定義する |
| `locals` | ローカル変数を定義する。 `local.` で参照する。 |
| `resource` | リソースを定義する。 `resource` に続いて記述するリソースタイプを用いて参照する。 |
| `data` | データソース（参照）を定義する。 `data.` で参照する。 |
| `module` | モジュールを読み込む。 `module.` で参照する。 |

`variable`, `locals` は同一モジュール内で参照可能です。内包するモジュールと値の受け渡しをするには、 `variable` や `outputs` を利用します。

また、Terraform は便利なビルトイン関数を多数提供しています。数値や文字列を操作する関数をはじめ、ネットワークのCIDRを算出する関数など非常に便利に利用することができます。

詳しくは下記をご参照ください。

- [Get Started - Azure | Terraform - HashiCorp Learn](https://learn.hashicorp.com/collections/terraform/azure-get-started)
- [Overview - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/index.html)
- [Syntax - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/syntax/configuration.html)
- [Expressions - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/expressions/index.html)
- [Functions - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/functions/index.html)

### 便利な機能

| キーワード | 解説 |
|----|----|
| Dependency Lock File | プロバイダやモジュールのインストール状態を保持するファイル（ `.terraform.lock.hcl` ） |
| `state` | Terraform で構築したリソースの状態を保持する。ローカル、または任意のバックエンドに保持できる |

詳しくは下記のドキュメントをご参照ください。

### プロバイダ

各種クラウドのほかにも便利なプロバイダが提供されています。

| プロバイダの例 | 解説 |
|----|----|
| [http](https://registry.terraform.io/providers/hashicorp/http/latest) | HTTP GET リクエストを行うことができる |
| [github](https://registry.terraform.io/providers/integrations/github/latest) | GitHub の API を利用できる |

詳しくは、[Browse Providers | Terraform Registry](https://registry.terraform.io/browse/providers) をご参照ください。

### Terraform CLI

インストールについては [Install Terraform | Terraform - HashiCorp Learn](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started) をご参照ください。

| よく利用するコマンド | 解説 |
|----|----|
| `terraform init` | 主に、プロバイダの読み込みを行う |
| `terraform plan` | 対象のリソースの状態を取得し、更新差分を算出する |
| `terraform apply` | 更新を反映する（デプロイする） |
| `terraform destroy` | 対象のリソースを破棄する | 
| `terraform fmt` | インデントや改行などをフォーマットする |

Terraform CLI は、Azure Cloud Shell にもインストールされており、それを利用することも可能です。

### エディタ

ほとんどのエディタで記述可能ですが、[Visual Studio Code](https://code.visualstudio.com/) がおすすめです。[HashiCorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) エクステンションを利用することで、 [Terraform Language Server (terraform-ls)](https://github.com/hashicorp/terraform-ls) を導入し、保存時のフォーマットや入力補完を行うことができます。（Terraform CLI がインストールされている前提です）

## Azure Provider の利用

Terraform で Microsoft Azure を扱うには、下記の2点を準備する必要があります。

- 認証
- プロバイダの設定

### 認証

- If you run terraform locally, it's simple to use [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) authentication.
- When running Terraform non-interactively such as CI/CD pipeline, you should use a Service Principal or Managed Identities.
  - If the environment that running Terraform is on Azure like VM, you can choose Managed Identities
  - In others, you can use Service Principal authentication with a certificate or client secret

#### 手元の環境で手動で terraform を実行する場合

手元の環境で手動で terraform を実行する場合は、 Azure CLI が手軽に利用できます。

| 方法 | 説明 |
|----|----|
| [Azure CLI を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) | 手元の環境で、手動で terraform を実行する場合にはおすすめ。 |

#### CI/CD のような非インタラクティブな環境で実行する場合

| 方法 | 説明 |
|----|----|
| [証明書による Service Principal を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_certificate) | 証明書による認証で発行した Service Principal を利用する |
| [Client Secret による Service Principal を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) | Service Principal 発行時に生成される Client Secret を指定し利用する |
| [Managed Identity を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity) | Manage Identities は Azure の機能で、インフラストラクチャ側の構成でリソース間の認証を済ませることができる |

### プロバイダの設定

Then, configure Azure Provider in `.tf` file.

```hcl
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.56.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
```

`backend` の `azurerm` を利用すると、[Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction) に `state` を保持することができます。詳しくは、下記をご参照ください。

- [Backend Type: azurerm - Terraform by HashiCorp](https://www.terraform.io/docs/language/settings/backends/azurerm.html)

### サンプル

```bash
RESOURCE_GROUP_NAME="rg-playground20210425"
LOCATION="japaneast"
APP_IDENTIFIER="comfort-music"

az login
# Create a resource group for working space, if need
# az group create --location $LOCATION --name $RESOURCE_GROUP_NAME

cd terraform
terraform init

terraform plan

terraform plan \
  -var resource_group_name=$RESOURCE_GROUP_NAME \
  -var app_identifier=$APP_IDENTIFIER

terraform apply

terraform apply \
  -var resource_group_name=$RESOURCE_GROUP_NAME \
  -var app_identifier=$APP_IDENTIFIER

terraform destroy

terraform destroy \
  -var resource_group_name=$RESOURCE_GROUP_NAME \
  -var app_identifier=$APP_IDENTIFIER
```

- Azure Functions + Cosmos DB
- Azure Functions + Cosmos DB with VNet
