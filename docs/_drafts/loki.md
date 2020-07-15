---
title: "LokiとPromtailでOpenStackのログを収集してGrafanaで見る"
excerpt: "LokiとPromtailでOpenStackのログ収集してGrafanaで見る"
date: 2020-07-11 19:08:44 +0900
last_modified_at: 2020-07-15 21:43:10 +0900
categories: "Tech"
tags: ["Loki", "Grafana", "Docker", "Docker Compose", "Linux"]
---

会社の開発環境にあるOpenStack環境のログをGrafanaで見れるようにしてみました。
これまでは各サーバにsshで乗り込んでログを見ていたのがブラウザ一つでGrafanaから見れるようになりました。

構築した環境のイメージは以下のとおりです。

[[イメージ]]

OpenStack環境はプライベートなネットワークに構築されています。
会社で普段使いしている端末からは直接アクセスできません。

両方のネットワークにつながった踏台サーバにDockerとDocker Composeを入れて、そこでLokiとGrafanaを動かします。
（DockerとDocker Composeのインストールは割愛します。[Dockerのドキュメント](https://docs.docker.com/engine/install/)を見てインストールしました）

ログ収集対象のサーバではPromtailを動かします。

## LokiとGrafanaのインストール

インストール方法はgithubのREADMEを見れば良いようです。

https://github.com/grafana/loki#getting-started

Docker Composeでインストールするので、Installing LokiのInstalling through Docker or Docker Composeを見ます。

https://github.com/grafana/loki/blob/v1.5.0/docs/installation/docker.md#install-with-docker-compose

まずはDockerをインストールしたサーバ上でLokiとGrafanaをインストールします。

ディレクトリ作成

```
$ mkdir loki
$ cd loki/
```

ドキュメントではwgetを使っていますが、踏台サーバには入っていなかったのでcurlを使いました。

```
$ curl -L -o docker-compose.yaml https://raw.githubusercontent.com/grafana/loki/v1.5.0/production/docker-compose.yaml
```

中身はこんな感じです。

```
version: "3"

networks:
  loki:

services:
  loki:
    image: grafana/loki:1.5.0
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - loki

#  promtail:
#    image: grafana/promtail:1.5.0
#    volumes:
#      - /var/log:/var/log
#    command: -config.file=/etc/promtail/docker-config.yaml
#    networks:
#      - loki

  grafana:
    image: grafana/grafana:master
    ports:
      - "3000:3000"
    networks:
      - loki
```

promtailは別サーバで動かすので、promtailの設定箇所はコメントアウトしました。

立ち上げます。

```
$ docker-compose up -d
```

grafanaにログインします。初期ユーザ／パスワードはadmin／adminです。

[[ログイン]]

[[データソース]]

## promtailのインストール

OpenStackの各コンポにpromtailのバイナリを配置して、systemdで自動起動するようにします。

githubのLokiのリリースページからバイナリを落としてきます。

systemdの設定ファイルを置きます。

/etc/promtail/config.yaml

/usr/local/bin/promtail -config.file="/etc/promtail/config.yaml"


```
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://<踏台サーバのIPアドレス>:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  pipeline_stages:
  - match:
      regex:
        expression: '^(?P<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (?P<process>\d+) (?P<level>\S+) (?P<content>.*)$'
      timestamp:
        source: timestamp
        format: '2006-01-02 03:04:05.000'
        location: Asia/Tokyo
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/log/*log
```


