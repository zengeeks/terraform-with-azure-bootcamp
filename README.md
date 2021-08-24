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

#### 生成されるファイル

Terraform の実行の過程で生成されるファイルについて紹介します。

| ファイル名 | 解説 |
|----|----|
| `.terraform.lock.hcl` | Dependency Lock File. プロバイダやモジュールのインストール状態を保持するファイル。コードと併せてバージョン管理に含めると、Terraform の実行環境を複数人で共有できる。 |
| `terraform.tfstate`  | Terraform CLI で構築したリソースの状態（ `state` ）を保持するファイル。Terraform CLI の規定では、`state` を実行したローカル環境にファイルで保存する。複数人で対象のリソースを扱いたい場合は、プロバイダの `backend` を利用し、この `state` を共有して管理できる。 |

詳しくは下記をご参照ください。

- [Dependency Lock File (.terraform.lock.hcl) - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/dependency-lock.html)
- [State - Terraform by HashiCorp](https://www.terraform.io/docs/language/state/index.html)
- [Backend Overview - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/settings/backends/index.html)

### Terraform の記法

Terraform のコードは、 `HCL` で記述します。（ `json` でも記述できますが一般的ではありません）

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

### プロバイダ

各種クラウドプラットフォームへリソースをデプロイするには、プロバイダをインストールする必要があります。また、プラットフォームだけではなく様々な便利なプロバイダが提供されています。

| プロバイダの例 | 解説 |
|----|----|
| [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | Microsoft Azure のリソースを扱うことができる |
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

- Azure の認証
- プロバイダの設定

### Azure の認証

Azure へリソースをデプロイするには認証が必要です。いくつかの方法があるので、用途に応じて使い分けましょう。 

- Terraform を手元の環境で実行する場合は、[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) による認証が手軽です。
- CI/CD パイプラインなどの非インタラクティブな環境で Terraform を実行する場合は、 Service Principal か Managed Identities を利用してください。
  - 実行環境が Azure 上にある場合（Azure VM など）、Managed Identities を利用することができます
  - 上記以外は、Service Principal を用いて、証明書またはクライアントシークレットによる認証を利用できます

| 方法 | 説明 |
|----|----|
| [Azure CLI を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) | 手元の環境で手動で terraform を実行する場合にはおすすめ |
| [証明書による Service Principal を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_certificate) | 証明書による認証で発行した Service Principal を利用する |
| [Client Secret による Service Principal を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret) | Service Principal 発行時に生成される Client Secret を指定し利用する |
| [Managed Identity を利用する](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity) | Manage Identities は Azure の機能で、インフラストラクチャ側の構成でリソース間の認証を済ませることができる |

### プロバイダの設定

プロバイダの設定は、通常、エントリーポイントとなる `main.tf` に記述します。 Azure Provider は下記のように記述します。

```hcl
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0.0"
    }
  }

  # Configure backend, if need
  # backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # If you want to configure authentication settings on a file instead of environment variables, write down here
  # subscription_id = "00000000-0000-0000-0000-000000000000"
  # ...
}
```

`backend` の `azurerm` を利用すると、[Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction) に `state` を保持することができます。詳しくは、下記をご参照ください。

- [Docs overview | hashicorp/azurerm | Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Backend Type: azurerm - Terraform by HashiCorp](https://www.terraform.io/docs/language/settings/backends/azurerm.html)

## サンプル

下記を参考に、Terraform によるリソースのデプロイを体験してみましょう。

サンプルコードでは、下記の構成のモジュールを用意しています。

- Azure Functions + Cosmos DB
- Azure Functions + Cosmos DB （VNetあり）

#### bashの場合

```bash
RESOURCE_GROUP_NAME="<デプロイするリソース グループ名>"
LOCATION="japaneast"
APP_IDENTIFIER="<一意の識別用文字列>"

az login
# Create a resource group for working space, if need
# az group create --location $LOCATION --name $RESOURCE_GROUP_NAME

cd terraform
terraform init

terraform plan \
  -var resource_group_name=$RESOURCE_GROUP_NAME \
  -var app_identifier=$APP_IDENTIFIER

terraform apply \
  -var resource_group_name=$RESOURCE_GROUP_NAME \
  -var app_identifier=$APP_IDENTIFIER

terraform destroy \
  -var resource_group_name=$RESOURCE_GROUP_NAME \
  -var app_identifier=$APP_IDENTIFIER
```

```powershell
$RESOURCE_GROUP_NAME="<デプロイするリソース グループ名>"
$LOCATION="japaneast"
$APP_IDENTIFIER="<一意の識別用文字列>"

az login
# Create a resource group for working space, if need
# az group create --location $LOCATION --name $RESOURCE_GROUP_NAME

cd terraform
terraform init

terraform plan `
  -var resource_group_name=$RESOURCE_GROUP_NAME `
  -var app_identifier=$APP_IDENTIFIER

terraform apply `
  -var resource_group_name=$RESOURCE_GROUP_NAME `
  -var app_identifier=$APP_IDENTIFIER

terraform destroy `
  -var resource_group_name=$RESOURCE_GROUP_NAME `
  -var app_identifier=$APP_IDENTIFIER
```

`-var` に指定しているのは `variables.tf` で指定した引数です。引数の渡し方はいくつか方法が複数あります。

- 指定ぜずにコマンドを実行し、インタラクティブに指定する
- コマンドの `-var` を利用して直接渡す
- `.tfvars` という拡張子を持つファイルから読み込む

