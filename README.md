# Terraform with Microsoft Azure boot camp

Terraform を利用して Microsoft Azure のリソースを管理するためのトレーニング教材です。

- Terraform の基礎
- Azure Provider の利用
  - 初期設定
  - サンプル

## Terraform の基礎
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

Terraform のスクリプトは、 `HCL` (_Hashicorp Configure Language_) で記述します。（ `json` でも記述できますが一般的ではありません）

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

詳しくは下記をご参照ください。

- [Syntax - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/syntax/configuration.html)
- [Expressions - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/expressions/index.html)

### 用語解説

| 用語 | 解説 |
|----|----|
| `input variables` | 入力（引数） |
| `outputs` | 出力 |
| `local variables` | ローカル変数 |
| `resource` and `data` | リソースとデータソース（参照） |
| `functions`| ビルトイン関数 |
| `modules` | モジュール |
| `providers` | プロバイダ |

`input variables`, `local variables` は同一モジュール内で参照可能です。内包するモジュールと値の受け渡しをするには、 `input variables` や `outputs` を利用します。

詳しくは下記のドキュメントをご参照ください。

- [Get Started - Azure | Terraform - HashiCorp Learn](https://learn.hashicorp.com/collections/terraform/azure-get-started)
- [Overview - Configuration Language - Terraform by HashiCorp](https://www.terraform.io/docs/language/index.html)

### プロバイダ

各種クラウドのほかにも便利なプロバイダが提供されています。

| プロバイダの例 | 解説 |
|----|----|
| [http](https://registry.terraform.io/providers/hashicorp/http/latest) | HTTP GET リクエストを行うことができる |
| [github](https://registry.terraform.io/providers/integrations/github/latest) | GitHub の API を利用できる |

詳しくは、[Browse Providers | Terraform Registry](https://registry.terraform.io/browse/providers) をご参照ください。

### Terraform CLI

| よく利用するコマンド | 解説 |
|----|----|

### エディタ

ほとんどのエディタで記述可能ですが、[Visual Studio Code](https://code.visualstudio.com/) がおすすめです。[HashiCorp Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) エクステンションを利用することで、 [Terraform Language Server (terraform-ls)](https://github.com/hashicorp/terraform-ls) を導入し、保存時のフォーマットや入力補完を行うことができます。
