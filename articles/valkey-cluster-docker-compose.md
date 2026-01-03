---
title: "docker composeでValkey clusterを立てる"
emoji: "💻"
type: "tech"
topics: ["valkey", "docker", "dockercompose"]
published: true
---

ローカルでValkey clusterに対してテストをしたい時に。

この用途ではコンテナ分けるまでもないと思うので1台でクラスタを組む。コンテナ分ける場合も同様の注意に従えば問題ない。

# 結論

## `--cluster-announce-hostname` を設定

ホスト名指定でコンテナ間の通信が可能

## IPアドレス固定 (データ永続化する場合)

dump.rdbやクラスタ設定ファイルを永続化する場合、IPアドレスを固定しないとcompose up時アドレス割当が変更された場合にクラスタ間で通信断になるので注意。

`--cluster-announce-hostname` でホスト名指定していても、valkeyがIPアドレス解決してからクラスタ設定を保存するので、再起動時のIPアドレスの変更に動的に対応できない。

## サンプル

```yaml
services:
  valkey-cluster:
    image: valkey/valkey:8.0
    entrypoint:
      - /bin/sh
      - -c
      - |
        for port in 7001 7002 7003; do
          mkdir -p /data/node_$${port}
          valkey-server \
            --port $${port} \
            --cluster-enabled yes \
            --save "10 1" \
            --dir /data/node_$${port} \
            --cluster-config-file $${port}.conf \
            --cluster-announce-hostname valkey-cluster &
        done

        # クラスタが構築済みか確認 (2回目以降の起動時は、7001.confなどのクラスタ設定ファイルから自動でクラスタ復旧される)
        while ! valkey-cli -h valkey-cluster -p 7001 CLUSTER INFO 2>/dev/null | grep -q "cluster_state:ok"; do
          # クラスタ組まれていない場合、クラスタ作成を試みる
          valkey-cli --cluster create valkey-cluster:7001 valkey-cluster:7002 valkey-cluster:7003 --cluster-yes
          sleep 1
        done
        wait
    ports:
      - 7001-7003:7001-7003
    # NOTE: IPアドレス割当が変更されるとクラスタ復旧できなくなるのでIPアドレス固定
    networks:
      default:
        ipv4_address: 172.18.0.10
    healthcheck:
      test: ["CMD-SHELL", "valkey-cli -h valkey-cluster -p 7001 CLUSTER INFO | grep -q 'cluster_state:ok'"]
      interval: 1s
      timeout: 20s
      retries: 10
      start_period: 10s
    volumes:
      - valkey-data:/data

networks:
  default:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/24
          gateway: 172.18.0.1

volumes:
  valkey-data:
```


# 参考

- https://github.com/valkey-io/valkey-go/blob/05f746de793ffe435ba165f0feaae3141592d334/docker-compose.yml#L66-L80
- https://github.com/a2not/docker-compose-valkey-cluster-minimal
