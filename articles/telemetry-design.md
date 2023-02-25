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

例えば`NewStack("missing-std-import", 5)`は

```
missing-std-import
cmd/compile/internal/types2.(*Checker).importPackage+39
cmd/compile/internal/types2.(*Checker).collectObjects+54
cmd/compile/internal/types2.(*Checker).checkFiles+18
cmd/compile/internal/types2.(*Checker).Files+0
cmd/compile/internal/types2.(*Config).Check+2
```

















# [Configuration](https://research.swtch.com/telemetry-design#configuration)











# [Reporting](https://research.swtch.com/telemetry-design#reporting)



















# [Publishing](https://research.swtch.com/telemetry-design#publishing)

毎日、24時間分のデータをアップロードサーバーが公開し、グラフの設定に基づいてグラフの更新なども行います。

加えて、過去24時間分のデータを、7つの異なる曜日始まりの週次データセットに分けてアップロードします。2023-01-18に公開されるファイルの例は以下です。（ここはあまり良く分からなかったです。）

```
week-2023-01-04-uploaded-2023-01-17.v1.reports
week-2023-01-05-uploaded-2023-01-17.v1.reports
week-2023-01-06-uploaded-2023-01-17.v1.reports
week-2023-01-07-uploaded-2023-01-17.v1.reports
week-2023-01-08-uploaded-2023-01-17.v1.reports
week-2023-01-09-uploaded-2023-01-17.v1.reports
week-2023-01-10-uploaded-2023-01-17.v1.reports
```

サンプリングによって収集するデータのサイズを少なく保つことができたり、ツールチェーンのインストール数の増加に伴って増加することのないようにコントロールすることができます。
検討している設計では、50kBのレポートと、週に16,000件のレポートにサンプルをコントロールする予定で、各週のデータはトータルで800MBに収まる計算になります。
Brotli圧縮をかけることで最低でもサイズを10分の1に抑えることができるため、週毎に最大で80MB、一年でも最大4GBに収める見込みになっているようです。


# [Opt-Out](https://research.swtch.com/telemetry-design#opt-out)

(※ 2023-02-24追記で、デフォルトoffとなるopt-inへの変更を表明しています。このセクションは提案初期の思想を残すために書き換えなく残しているようです。)

Transparent Telemetryがデフォルトで利用されるべき理由を2点述べています。
1つは、大多数の人はデフォルトの設定を変更することはないため、デフォルトでtelemetryの収集がされない場合、収集されるサンプルの中でGoやTelemetryのシステムに詳しいユーザーからによるものの割合が増えることでバイアスが生じる危険性があるためです。
もう1つの理由として、onに設定するチェックボックスの存在が、必要以上のデータを集める正当化になってしまうことを懸念しています。
デフォルトでonとして、サンプルの取得を一部に限定することで、Goを利用するシステムが増えるほど個別のシステムにかかるプライバシーコストが逓減するのではないかという考えもあるそうです。

デフォルトの設定を変更し、データのサンプリングを防ぎたい場合、`go env -w GOTELEMETRY=off`などのコマンドで`GOTELEMETRY=off`を設定することでOpt-outすることができます。

Go1.21でリリースされる予定のProposal [#57179](https://github.com/golang/go/issues/57179)によって、`$GOROOT/go.env`を利用したツールチェーンごとの設定を読み込むことができるので、例えばあるLinuxディストリビューションが無条件でGoのtelemetryを無効にしたい場合は、Goツールチェーンとともに`GOTELEMETRY=off`を含んだgo.envを配布することもできます。

好ましくないOpt-outの例として、ユーザーがOpt-outできる状況になる前から情報を収集するtelemetryがあるようです。
その開発者向けツールでは、インストール中にtelemetryのチェックボックスがオンの状態で現れ、ユーザーはチェックを外すことでOpt-outできるのですが、そのチェックボックスが現れるまでにインストール数やOpt-out率を計測できるような情報だけでなく、Opt-outしたシステムのIPアドレスやMACアドレスなども収集されていたそうです。
このシステムの場合、一切のtelemetryによる情報収集を無効にするために、特定の値を環境変数に設定した状態でコマンドラインからインストーラーを実行する必要があったようです。
このようなOpt-outの思想に反するtelemetryのシステムにはRussは強く反対しています。

この点については、Goに導入を検討されているTransparent telemetryではOpt-outするまでの1週間の猶予期間は一切情報収集をされず、収集設定のダウンロードなども行われないようにする方針のようです。
