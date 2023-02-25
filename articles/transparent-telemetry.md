---
title: "Transparent Telemetryの概要"
emoji: "🌌"
type: "tech"
topics: ["go", "oss", "proposal"]
published: false
---

# 背景

Goのtoolchainにtelemetryを導入することで、`go`, `gopls`, `govulncheck`などのコマンドラインツールの使われ方についての情報を収集し、オープンソースであるGo言語の開発に活用しようというproposalがあります。
[telemetry in the Go toolchain #58409](https://github.com/golang/go/discussions/58409) 

本記事執筆時点ではDiscussionsはLockされ、[proposalの投稿](https://github.com/golang/go/discussions/58409#discussion-4835204)には👍(162)よりも👎(518)のリアクションが多くついていたり、導入に関しては賛否両論といった現状のようです。

本記事は、Go toolchainへのtelemetry導入のproposalの展望を理解するために、proposalと同じ2023年2月8日にRuss Coxにより投稿された[Transparent Telemetry](https://research.swtch.com/telemetry)^["[Transparent Telemetry](https://research.swtch.com/telemetry)" © Russ Cox [Licensed under CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)]の4本の記事（Discussionsを受けて追加された1本の追加記事含む）について概要をまとめます。^[この記事は完全な和訳記事ではなく、個人的な解釈に基づいたまとめです。（結果的にほとんど和訳になってますが、省略や表現の変更などがあります。）誤りに気づいた場合はコメント下さい。]

# [Transparent Telemetry for Open-Source Projects](https://research.swtch.com/telemetry-intro)

ソフトウェアがどのように使われ、期待するパフォーマンスを発揮しているかを知るためのモダンな手法として、Russはtelemetryを上げています。その上で、それをオープンソース向けにした新たなデザインとして"Transparent Telemetry"を提案しています。

## [Why Telemetry?](https://research.swtch.com/telemetry-intro#why)

telemetry以外にソフトウェアのバグや使われ方の情報を知れる手段としてバグ報告とサーベイをあげ、それぞれでは不十分であることを解説し、telemetryの必要性を訴えています。

### バグ報告だけでは不十分

バグ報告では、ユーザーがバグと判定しその上で報告をされたものしか知ることができないが、ユーザーが気づけない事象についてtelemetryでは統計的に不具合を認識することができるとして、過去のGo開発からの具体例を上げています。

Go 1.14のリリースプロセスにおいて、Appleの署名ツールを使えるようmacOS用のGoディストリビューションのビルド方法を調整したが、それによってすべてのプリコンパイルされた`.a`ファイルが古いと判定される状態で提供されました。
その結果、`go`コマンドが初回実行時に標準ライブラリを再ビルドし、`cgo`を使う`net`パッケージを利用する際にXcodeが必要となってしまいました。
ユーザー目線では、XcodeがないmacOSの環境で`go`が`clang`を実行する際には、Xcodeをインストールするポップアップが表示されるが、ユーザーはそれが必要だと感じたか、`go`がXcodeを必要としてるとすら認識できなかった可能性があります。
結局このバグは3年以上誰も報告することなく、Go開発の中でたまたま発見されたそうです。

telemetryがあれば、1.14移行のバージョンのGoを使っているMacの環境についてプリコンパイルされた標準ライブラリへのキャッシュミス率が100%であることが分かるため、すぐに気づくことができたのではないかと主張しています。

### サーベイだけでは不十分

サーベイではユーザーがGoをどんな目的で使いたいかなどを理解できたが、これはあくまで少ないサンプルであり、特に使われる頻度の少ない機能についての情報を集めるためには、精度を高めるためにさらに大きなサンプルを必要とする問題があります。

Goでの使われる頻度の少ない機能への変更例として、[Go1.13のNative Client (`GOOS=nacl`)のサポート終了](https://go.dev/doc/go1.13#ports)や、[Go1.15の32bit Intel CPUでのSSE2命令セットをサポートしない浮動小数点ハードウェア(`GO386=387`)のサポート終了](https://go.dev/doc/go1.15#386)が挙げられていますが、いずれも影響範囲の規模感について概ね予測通りの結果であったようです。

しかし失敗例として、Go1.18の`-buildmode=shared`の削除についてドラフトに組み込んだが、Go1.18 ベータ1のリリース時点で「まだ使ってるから消さないで」とのフィードバックがあり、[削除を諦めた](https://github.com/golang/go/issues/47788)という過去もあったようです。

メンテナンスコストを軽減するために検討されているものとして、モダンなアトミック命令のないARMv5 (`GOARM=5`)サポート終了などもあります。最近で言えばGo1.20でmacOS High Sierraのサポートを終了することも検討されたが、ユーザーから[保留してほしいとの意見](https://github.com/golang/go/issues/57125#issuecomment-1416277589)が上がったようです。

telemetryも完璧なものではないですが、使わない機能や問題のある機能についてメンテナンスを続けるよりは、大きなサンプルのユーザーへのサーベイをする必要なく、統計的に利用状況を確認できるtelemetryを導入する必要性はあるのかもしれません。

## [Why Telemetry For Open Source?](https://research.swtch.com/telemetry-intro#why-open-source)

telemetryと聞くと、パーソナルな部分までジロジロ見られてしまうというようなネガティブなイメージを直感で持たれる方も少なくないのでは無いでしょうか。

キーボードによる入力の一つ一つまでを収集されるというのは誇張かもしれないが、あながち間違いでもないと感じるのも以下の現実に起きている例から納得できます。

- [Kindleがページ送りのすべてを収集してる](https://www.theverge.com/2020/1/31/21117217/amazon-kindle-tracking-page-turn-taps-e-reader-privacy-policy-security-whispersync)
- [VS Codeのtelemetryログ](https://www.roboleary.net/tools/2022/04/20/vscode-telemetry.html)
- [.NETのtelemetryイベント](https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry)

そのようなイメージもあるのか、オープンソースのソフトウェアプロジェクトでは主に2つの理由からtelemetryを避ける傾向にあります。1つはユーザーに対する大きなプライバシーコストの懸念、もう一つはtelemetryの性質上集めた情報に対するアクセスを制限する必要があり、オープンソースであるプロジェクトの方向性に反するものとなるためです。

telemetryを導入しない（何もしない）方が簡単ですが、それによって先に述べた、「使われていない機能に関するメンテナンス」や「ユーザー体験を損なう、バグや不具合などを含んだリリース」に対して時間を無駄に割いてしまうデメリットを被ります。

Russは「侵略的なまでのtelemetryによるトラッキング」と「telemetryを導入せず何もしない」は誤った二分法であり、オープンソースを傷つけていると主張しています。こういった情報収集やそれによるGo言語開発の優先順位付けを行えないことが、メンテナの燃え尽きにつながるのではないかということです。

Eric Raymondは「十分目玉に晒されていれば、すべてのバグは浅い」と言い、説明として十分なベータテスターと開発者仲間があれば、ほとんどの問題は認識され解決されるとしました。
しかしそれは、1997年までは正しかったかもしれないが、現代のオープンソースソフトウェアはそれを開発したりどのように動くのかについて詳しくない人を含む多くの人々から使われるようになり、それでも発見できない先述のmacOSのGoのキャッシュのバグの例からも、目玉はスケールしないことがわかります。

オープンソースソフトウェアのための、必要最低限のユーザーアクティビティの収集から開発を効率化させられる、新しいtelemetryのデザインを考える必要があるでしょう。

## [Transparent Telemetry](https://research.swtch.com/telemetry-intro#design)



# 最後に

すべて一つの記事にまとめようと考えていましたが、具体例など興味深く丁寧にまとめていたら長くなりそうなので、記事ごとに分割して公開していく予定です。

