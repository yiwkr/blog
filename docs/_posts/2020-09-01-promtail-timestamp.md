---
title: "Promtailで収集したログとタイムスタンプを一致させる"
excerpt: "Promtailで収集したログのタイムスタンプがログのタイムスタンプとずれているときの対処"
date: 2020-09-01 13:08:06 +0900
last_modified_at: 2020-09-22 13:39:48 +0900
categories: "Tech"
tags: ["Loki", "Promtail", "Linux"]
header:
  teaser: /assets/images/terminal-black.png
---

![header-image](assets/images/terminal-black.png)

Promtailはデフォルトの設定のままだとのログを収集した時刻をタイムスタンプとして扱います。
ログに出力されている時刻をタイムスタンプとして扱えるようにするには設定が必要です。

## Promtailの設定

Promtailのドキュメントに載っている[設定例][promtail-config-example]をベースにします。

```
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/log/positions.yaml

client:
  url: http://ip_or_hostname_where_Loki_run:3100/loki/api/v1/push

scrape_configs:
 - job_name: system
   pipeline_stages:
   static_configs:
   - targets:
      - localhost
     labels:
      job: varlogs
      host: yourhost
      __path__: /var/log/*.log
```

pipeline\_stagesを変更します。

```
   pipeline_stages:
   - match:
       selector: '{job=~".*"}'
       stages:
       - regex:
           expression: '^(?P<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}) .*$'
       - timestamp:
           source: time
           format: "2006-01-02 03:04:05.000"
           location: Asia/Tokyo
```

matchルールのregexでタイムスタンプを正規表現で指定します。
上記の例では`time`変数に格納するように指定しています。
これはあとでtimestampのsourceで指定します。

matchルールのtimestampでタイムスタンプを設定します。

sourceにはregexで設定した変数を指定します。

formatでタイムスタンプの形式を指定します。
事前定義されたフォーマットが使える場合はRFC1123、RFC3339Nanoなどの文字列も指定できますが自分で指定することもできます。

お好みでlocationにタイムゾーンを指定します。

Promtailを再起動すると反映されます。

[promtail-config-example]: https://github.com/grafana/loki/blob/v1.5.0/docs/clients/promtail/configuration.md#example-static-config-without-targets

