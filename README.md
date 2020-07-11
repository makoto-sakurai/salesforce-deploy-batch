# Salesforce デプロイスクリプト

## 使い方
### Apexテスト指定なし
`sfdep.ps1 -from dev -to product`
### Apexテストを指定
`sfdep.ps1 -from dev -to product -tests SomeTest`
### Apexテストを複数指定
`sfdep.ps1 -from dev -to product -tests SomeTest1,SomeTest2`
### package.xmlを指定
`sfdep.ps1 -from dev -to product -p C:\release\YYYYMMDD\NNN\package.xml`  
__注意__ `-p` オプションを使用しない時は `sfdep.ps1` と同じディレクトリに `package.xml` が必要です

## 前提条件
1. Salesforce CLIがインストールされていること  
   ダウンロードは[こちら](https://developer.salesforce.com/ja/tools/sfdxcli)から

2. 取得元とリリース先の組織にSalesforce CLIで認証が完了していること
3. package.xmlが生成済みであること  
   package.xmlの生成はvscodeの拡張機能「[Salesforce Package.xml Generator Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=VignaeshRamA.sfdx-package-xml-generator)」がおすすめ


### Salesforce CLIで認証 の方法
#### 具体例(本番)

`sfdx force:auth:web:login --setalias product --instanceurl https://login.salesforce.com`

##### 説明
コマンドを実行するとSalesforceログイン画面がWebブラウザで開くのでログインしてOAuthを行う
成功したら下記のようなメッセージが表示される

> Successfully authorized xxxx@xxxxx.xxxx with org ID XXXXXXXXXXXXXX
> You may now close the browser

`--setalias product` で接続先の名前を設定しているこの設定値、この例だと`product`は`sfdep.ps1`の`-to`パラメータの引数として渡します  
本番環境の時は`--instanceurl https://login.salesforce.com`です。  
ドメインが切られている時はそのドメインにしないといけません。

#### 具体例(Sandbox)

`sfdx force:auth:web:login --setalias dev --instanceurl https://test.salesforce.com`

##### 説明
この例だと`dev`は`sfdep.ps1`の`-from`パラメータの引数として渡します  
Sandboxの時は`--instanceurl https://test.salesforce.com`です。

## 実行時に生成されるファイル

### `retrieve_result.json`

- `package.xml`で指定したメタデータを`-from`で指定した組織から取得した結果です。
- 具体的には`sfdx force:mdapi:retrieve --json`の出力結果です  
※上記のコマンドからは一部パラメータを省略して記載しています

### `unpackaged.zip`

- `package.xml`で指定したメタデータを`-from`で指定した組織から取得したメタデータです。
- 具体的には`sfdx force:mdapi:retrieve --json`で取得しています  
※上記のコマンドからは一部パラメータを省略して記載しています

### `deploy_check_result.json`

- `-to`で指定した組織に`-tests`で指定したテストと検証を実施した結果です。
- 具体的には`sfdx force:mdapi:deploy --json -f unpackaged.zip --checkonly`の出力結果です  
※上記のコマンドからは一部パラメータを省略して記載しています


### `deploy_result.json`

- `-to`で指定した組織に`-tests`で指定したテストとリリースを実施した結果です。
- 具体的には`sfdx force:mdapi:deploy --json -f unpackaged.zip`の出力結果です  
※上記のコマンドからは一部パラメータを省略して記載しています
