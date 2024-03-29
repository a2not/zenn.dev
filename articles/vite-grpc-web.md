---
title: "Viteでgrpc-webを使う時の注意"
emoji: "⛈️"
type: "tech"
topics: ["vite", "grpc", "grpc-web", "typescript", "javascript"]
published: false
---

# 結論

公式 (https://github.com/grpc/grpc-web) は使えるがおすすめしない。

# 代替

公式に頼れない時点でデファクトスタンダードは無いように思うので要件や好みに合わせて選択することになるが、個人的には[`connect-web`](https://www.npmjs.com/package/@connectrpc/connect-web)が使いやすく信頼できるように思う。

[`protobuf-ts`](https://github.com/timostamm/protobuf-ts) も悪く無さそう。

上記2つは少なくとも公式と同じWarningは出ないことを確認している^[[connect-web](https://github.com/a2not/vite-grpc-web/tree/connect-web), [protobuf-ts](https://github.com/a2not/vite-grpc-web/tree/protobuf-ts)各ブランチで確認]のと、ESMとして使えるのでパッケージ化などの回りくどいワークアラウンドを必要としないので少なくとも公式よりは良いと思う。

