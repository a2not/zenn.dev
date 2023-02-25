---
title: "The Design of Transparent Telemetryを読む"
emoji: "🌌"
type: "tech"
topics: ["go", "oss", "proposal"]
published: false
---

[目次ページはこちら](https://zenn.dev/a2not/articles/telemetry-index)

[The Design of Transparent Telemetry](https://research.swtch.com/telemetry-design)^["[Transparent Telemetry](https://research.swtch.com/telemetry)" © Russ Cox [Licensed under CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)]

Transparent Telemetryのデザインについて、5つの要素に分けて説明しています。

- Counting: Goツールチェーンがカウンタの値(メトリクス)を週毎にローカルファイルとして保存する。
- Configuration: Go公式サイトでのレビューを含むパブリックな意思決定プロセスによって定められる、新たなグラフやメトリクスに対するtelemetryの設定。収集される情報や、サンプルレートを決める情報源となる。
- Reporting: 週に一度、自動化されたメトリクスの報告プログラムが、現行の収集設定(`collection configuration`)をダウンロードするかどうか、及びその週のサンプルとしてデータを送信するかを決める。
- Publishing: 情報を集めたサーバーは、日毎に集まった情報をまとめて圧縮し、表やグラフなどのサマリーと合わせて公開する。
- Opt-out: デフォルトでtelemetryを使うため、設定によるシンプルで十分なopt-outを提供する。(2023-02-24の追記で、デフォルトでtelemetryの利用をoffにし、設定により利用を明示することでtelemetryの収集を行うopt-inの方式に変更すると書かれています。)

# [Counting](https://research.swtch.com/telemetry-design#counting)

Goのツールチェーンのプログラムが、下記のようなシンプルなAPIを利用してカウンタの値をローカルファイルに保存します。

```go
package counter

func New(name string) *Counter
func (c *Counter) Inc()

func NewStack(name string, frames int) *Stack
func (s *Stack) Inc()
```

`Counter`を使う例として、例えば`go build`コマンド実行時のビルドのキャッシュミス率を収集したい場合、コマンド実行ごとにキャッシュミス率を計測し、指数的な感覚(例えば、0%, <0.1%, <0.2%, <0.5%, <1%, <2%, <5%, <10%, <20%, <50%, <100%)で分けたヒストグラムのうちで当てはまる階級のカウンタの値に1を加算します。これを一週間続けることで、その週のその環境でのキャッシュミス率の分布を表すデータレコードを作成します。

`Stack`カウンタも同様で、加えて記録するフレームの最大値をコンストラクタに渡します。各フレームはimportパス、関数名、関数の先頭からの相対的な行番号で表現されます。(`cmd/compile/internal/base.Errorf+10`といったように)

例えば`NewStack("missing-std-import", 5)`

```
missing-std-import
cmd/compile/internal/types2.(*Checker).importPackage+39
cmd/compile/internal/types2.(*Checker).collectObjects+54
cmd/compile/internal/types2.(*Checker).checkFiles+18
cmd/compile/internal/types2.(*Checker).Files+0
cmd/compile/internal/types2.(*Config).Check+2
```

