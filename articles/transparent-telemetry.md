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

Discussionsは賛否両論ですが、本記事執筆時点ではDiscussionsはLockされ、[proposalの投稿](https://github.com/golang/go/discussions/58409#discussion-4835204)には👍(162)よりも👎(518)のリアクションが多くついていたり、[「デフォルトでoff、もしくは初回利用時にon/offを選択できるようにすべき」](https://github.com/golang/go/discussions/58409#discussioncomment-4905912)といった意見が支持を集めている現状のようです。

本記事は、Go toolchainへのtelemetry導入のproposalの展望を理解するために、proposalと同じ2023年2月8日にRuss Coxにより投稿された[Transparent Telemetry](https://research.swtch.com/telemetry)の4本の記事（Discussionsを受けて追加された1本の追加記事含む）について概要をまとめます。^[この記事は和訳記事ではなく、個人的な解釈に基づいた概要のまとめです。誤りに気づいた場合はコメント下さい。]


# [Transparent Telemetry for Open-Source Projects](https://research.swtch.com/telemetry-intro)

ソフトウェアがどのように使われ、期待するパフォーマンスを発揮しているかを知るためのモダンな手法として、Russはtelemetryを上げています。その上で、それをオープンソース向けにした新たなデザインとして"Transparent Telemetry"を提案しています。

## [Why Telemetry?](https://research.swtch.com/telemetry-intro#why)

telemetry以外にソフトウェアのバグや使われ方の情報を知れる手段としてバグ報告とサーベイをあげ、それぞれでは不十分であることを解説し、telemetryの必要性を訴えています。

### バグ報告だけでは不十分

ユーザーがバグと判定し、その上で報告をされたものしか知ることができないが、ユーザーが気づけない事象について、telemetryでは統計的に不具合を認識することができるとして、具体例を上げています。

Go 1.14のリリースプロセスにおいて、Appleの署名ツールを使えるようmacOS用のGoディストリビューションのビルド方法を調整したが、それによってすべてのプリコンパイルされた`.a`ファイルが古いと判定される状態で提供されました。
その結果、`go`コマンドが初回実行時に標準ライブラリを再ビルドし、`cgo`を使う`net`パッケージを利用する際にXcodeが必要となってしまいました。
ユーザー目線では、XcodeがないmacOSの環境で`go`が`clang`を実行する際には、Xcodeをインストールするポップアップが表示されるが、ユーザーはそれが必要だと感じたか、`go`がXcodeを必要としてるとすら認識できなかった可能性があります。
結局このバグは3年以上誰も報告することなく、Go開発の中でたまたま発見されたそうです。

telemetryがあれば、1.14移行のバージョンのGoを使っているMacの環境についての、プリコンパイルされた標準ライブラリへのキャッシュミス率が100%であることが分かるため、すぐに気づくことができたのではないかと主張しています。

### サーベイだけでは不十分
