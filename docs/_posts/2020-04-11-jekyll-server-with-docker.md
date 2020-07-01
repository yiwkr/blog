---
title: "Dockerで起動したJekyllサーバーでブログ記事をプレビュー"
excerpt: "DockerでJekyllのプレビュー環境を構築したときのメモです"
date: 2020-04-11 12:42:51 +0900
last_modified_at: 2020-07-02 00:13:33 +0900
categories: "Tech"
tags: ["Jekyll", "Docker", "Makefile"]
---

## はじめに

[Jekyll][jekyll]でブログサイトを作成するにあたってDockerでJekyllサーバーを起動して記事をプレビューできるようにしました。その時の構築メモです。

## 環境構築

### 環境

以下の環境で構築しました。

| 環境 | version |
| :---- | :---- |
| OS | CentOS Linux release 7.7.1908 (Core) |
| docker | Docker version 19.03.8, build afacb8b |

### フォルダ構成

まずフォルダ構成から決めました。

[Github Pages][github-pages]で公開することや、Dockerコンテナをコマンド実行ごとに廃棄することを考慮し、以下のようなフォルダ構成にしています。

```
.
├── .bundle/  # bundlerで利用するフォルダ。gemのインストール先
├── docs/     # Jekyllサイトの構成ファイルを配置
│   ├── 404.html
│   ├── about.md
│   ├── _config.yml
│   ├── Gemfile
│   ├── index.md
│   └── _posts/
└── Makefile  # コマンドを覚えられないのでMakefileに記載
```

- .bundleフォルダはgemのインストール先として使用

    コンテナは使い捨てにするので、毎回gemのインストールをしなくていいように.bundleフォルダをコンテナにマウントして再利用します。

- docsフォルダはJekyllサイトのフォルダ／ファイルの配置先として使用

    名前がdocsになっているのは[Github Pages][github-pages]で公開するときに都合がよかったためです。

- Makefileは関連するコンテナ操作を簡易化するために作成

### Dockerイメージ

[JekyllのDockerイメージ][jekyll-docker]が公開されているのでありがたく利用します。

前述のとおりこのJekyllサイトは[Github Pages][github-pages]で公開するつもりなのでバージョンは[Github Pagesで使用されるJekyllのバージョン][github-versions]に合わせます。2020/4/10時点では3.8.5です。

`docker pull`しておきます。

```
$ docker pull jekyll/jekyll:3.8.5
```

### Makefile

pullしておいたDockerイメージを使ってJekyllの操作をしていきますが、コマンドのオプションを覚えられないのでMakefileを作っておきます。

``` makefile
DOCKER ?= $(shell command -v docker 2> /dev/null)
JEKYLL_VERSION = 3.8.5
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)

.PHONY: bash
bash: ## open interactive shell (bash)
	docker run -it --rm \
		-v $$PWD/docs:/srv/jekyll \
		-v $$PWD/.bundle:/usr/local/bundle \
		$(DOCKER_IMAGE) \
		bash

.PHONY: serve
serve: ## jekyll serve
	docker run -it --rm \
		-v $$PWD/docs:/srv/jekyll \
		-v $$PWD/.bundle:/usr/local/bundle \
		-p 4000:4000 \
		$(DOCKER_IMAGE) \
		bundle exec jekyll serve \
			--host 0.0.0.0 \
			--trace \
			--draft \
			--livereload
```

これで`make bash`を実行するとbashでインタラクティブにコマンド操作ができます。

また、`make serve`を実行するとJekyllサーバーが起動します。

他にもビルド用の設定などを足しましたが説明は割愛します。最終的なMakefile全体は[gistに載せている][gist-makefile]のでそちらを参照してください。

### Jekyllサイトの作成

Jekyllサーバーの動作確認のためにJekyllサイトを作ってみます。

.bundle、docsフォルダを作ってからjekyll/jekyllイメージのコンテナを起動します。
コンテナ内でコマンドを実行したいので`make bash`を実行します。

```
$ mkdir {.bundle,docs}
$ make bash
```

docsフォルダをマウントした影響で所有者がローカルの所有者になっているため変更します。  
（コンテナ内の操作はプロンプトを`bash-5.0# `にして記載しています）

```
bash-5.0# chown jekyll:jekyll .
```

`jekyll new`を実行し新しいJekyllサイトを作成します。

```
bash-5.0# jekyll new .
```

コンテナから抜けます。

```
bash-5.0# exit
```

### Jekyllサーバーの起動

make serveでJekyllのサーバーを起動します。

```
$ make serve
```

ブラウザで`http://<DockerホストのIPアドレス>:4000/`にアクセスすると[Jekyllサイトの作成](#Jekyllサイトの作成)で作成したサイトをプレビューすることができます。


<!--
### コマンド一覧

コピペで動く（かもしれない）コマンド一覧です。
プロンプト部分（`$`、`bash-5.0#`）は取り除いてください。

```
$ mkdir jekyll-test
$ cd jekyll-test
$ curl -o Makefile https://gist.githubusercontent.com/yiwkr/0175f7a1b990f195db670694f28b83ba/raw/7aba4abcbd1b8c984fcb15fe4f96cd64528fd59c/Makefile
$ mkdir {.bundle,docs}
$ make bash
bash-5.0# chown jekyll:jekyll .
bash-5.0# jekyll new .
bash-5.0# exit
$ make serve
```
-->

## おわりに

Dockerで起動したJekyllサーバーでJekyllサイトをプレビューする環境を作ることができました。

気の向いたときに記事を書いていきたいと思います。


[jekyll]: https://jekyllrb.com/
[github-pages]: https://help.github.com/ja/github/working-with-github-pages
[github-versions]: https://pages.github.com/versions/
[jekyll-docker]: https://hub.docker.com/r/jekyll/jekyll/
[gist-makefile]: https://gist.github.com/yiwkr/0175f7a1b990f195db670694f28b83ba
