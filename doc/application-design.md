# アプリケーション設計

## モジュール間の参照ルール
```
標準モジュール
外部モジュール
　↑
conf
　↑
lib/core
　↑
lib/util/*
　↑
lib/*
　↑
apps/subapp/conf
　↑
apps/subapp/lib/*
　↑
apps/subapp/models
　↑
apps/subapp/logics
　↑
apps/subapp/controllers
　↑
apps/subapp
　↑
apps
　↑
app
　↑
helpers/*
　↑
commands/*
　↑
env/*
　↑
boot/*
scripts/*
test/*
```


## 各モジュールの概念・役割
- `apps/`
  - サブアプリケーション群、汎用性の低い処理の影響範囲を明示的に狭めるために作った
  - サブアプリ間の参照ルール
    - 以下に書いた図の中で一段階高い層から、そのモジュールトップのみ参照できる
      - `index` -> `controllers` -> `logics` -> `models` -> `conf`
- `boot/`
  - 起動ファイル、mocha など他の起動ファイルもある
  - 外部との API を node コマンドに統一したかったので設置した
- `env/`
  - 環境別に実行が必要な、副作用を発生させる処理を定義する。値は返さない
    - 副作用が無いものは conf/_env に分離する


## ファイル名の `_` プレフィックス
- モジュール内の index からしか参照されないファイルは `_` を付けて定義する
- test も含めて、単体でアクセスされる可能性があるなら付けない


## 同階層内の動的参照
- 同階層内で参照したい場合は、動的参照にて行うこと
- 循環参照に対しては、「注意する」という対処
