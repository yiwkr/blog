---
title: "Alpine LinuxのwgetでJenkinsのジョブを実行する"
excerpt: ""
date: 2020-06-29 22:50:13 +0900
categories: "Tech"
tags: ["Alpine Linux", "Docker", "wget", "Jenkins"]
---

## 結論

Alpine LinuxのwgetでJenkinsのジョブを実行するには、下記のようにURLにユーザー名とAPIトークンを含めます。

```
wget -O- https://USER:API_TOKEN@jenkins.example.com/JOB_NAME/token=JOB_TOKEN
```

## はじめに

Jenkinsで"ビルド・トリガ"の"リモートからビルド"を設定してAlpine Linux(3.12.0)からcurlで実行しようとしましたが、Alpine Linuxにはcurlコマンドがデフォルトでは入っていませんでした。

curlが入っていない代わりにwgetがデフォルトで入っていましたが、Alpine Linuxのwgetはgnu wgetに比べてオプションが少なく、オプションでユーザー名・APIトークンを指定できないようです。

ユーザー名・APIトークンをURLに含めることでAlpine LinuxからもJenkinsのジョブを実行できたのでメモを残しておきます。

## curlの場合

curlだと下記のように`--user`オプションがありユーザー名（`USER`）とAPIトークン（`API_TOKEN`）を指定することでジョブを実行できます。

```
curl --user USER:API_TOKEN https://jenkins.example.com/JOB_NAME/token=JOB_TOKEN
```

## gnu wgetの場合

gnu wgetの場合はcurlと同様にオプション指定でいけそうです。  
（`-O`は出力先を指定するオプションです。`-`を指定すると標準出力に出力されます）

```
wget -O - --user=USER --password=API_TOKEN https://jenkins.example.com/JOB_NAME/token=JOB_TOKEN
```

## Alpine Linuxのwgetの場合

Alpine Linuxのwgetには`--user`、`--password`オプションがないのでユーザー名・APIトークンをURLに含めて実行します。

```
wget -O - https://USER:API_TOKEN@jenkins.example.com/JOB_NAME/token=JOB_TOKEN
```

以上です。
