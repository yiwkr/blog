---
title: "mmctl v5.24をビルドする"
excerpt: "mmctlのビルドするまでにつまづいた箇所の記録です"
date: 2020-07-02 00:03:27 +0900
last_modified_at: 2020-07-19 12:33:28 +0900
categories: "Tech"
tags: ["Mattermost", "mmctl"]
header:
  teaser: /assets/images/terminal-black.png
---

## mmctlはMattermostサーバーとバージョンが合わないと警告がでる

[mmctl](https://docs.mattermost.com/administration/mmctl-cli-tool.html)というMattermostのCLIツールがあるようです。まだベータ版です。

[mmctlのgithubリポジトリ](https://github.com/mattermost/mmctl)のREADMEに従ってインストールするとその時点の最新バージョンがインストールされます。

```
$ go get -u github.com/mattermost/mmctl
$ $GOPATH/bin/mmctl version
mmctl v5.26.0 -- dev mode
```

2020/7/1時点ではMattermostの最新リリースは5.24.2なので、以下のようなWARNINGがでます。

```
$ mmctl team list
WARNING: server version 5.24.0.5.24.2.d8e517e57b1d75bc129f93d43885dd4b.false doesn't match mmctl version 5.26.0
```

**2020/7/19 追記**  
リリースページがあることを見落としていました。[ドキュメント](https://docs.mattermost.com/administration/mmctl-cli-tool.html#installing-mmctl)にちゃんとリリースページへのリンクがありました。
mmctlコマンドを使うだけであれば、リリースページから該当バージョンのバイナリをダウンロードするとよいですね。
<https://github.com/mattermost/mmctl/releases>

## mmctl v5.24をビルドする

githubからクローンして`v5.24`タグからブランチを切ります。

```
$ git clone https://github.com/mattermost/mmctl.git
$ cd mmctl
$ git checkout -b v5.24 v5.24
```

`make build`を実行してビルドします。

```
$ make build
```

以下のエラーがでました。

```
golangci-lint is not installed. Please see https://github.com/golangci/golangci-lint#install for installation instructions.
make: *** [govet] Error 1
```

golangci-lintが必要なようです。

表示されたURLのドキュメントに従ってインストールします。

```
$ curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.27.0
```

再度`make build`します。

以下のエラーがでました。

```
mattermost-govet is not installed. Please install it executing "GO111MODULE=off go get -u github.com/mattermost/mattermost-govet"
make: *** [govet] Error 1
```

mattermost-govetが必要とのこと。

表示されたメッセージに従ってインストールして再ビルドします。

```
$ GO111MODULE=off go get -u github.com/mattermost/mattermost-govet
$ make build
```

なにか引っかかりました。

```
commands/channel_test.go:2436:31: S1039: unnecessary use of fmt.Sprintf (gosimple)
                s.Require().EqualError(err, fmt.Sprintf("individual users must not be specified in conjunction with the --all-users flag"))
                                            ^
make: *** [govet] Error 1
```

fmt.Sprintfは必要ないといっているようです。

`commands/channel_test.go`を修正します。

```
$ vi commands/channel_test.go
$ git diff
diff --git a/commands/channel_test.go b/commands/channel_test.go
index a0b1e93..905e3c0 100644
--- a/commands/channel_test.go
+++ b/commands/channel_test.go
@@ -2433,7 +2433,7 @@ func (s *MmctlUnitTestSuite) TestRemoveChannelUsersCmd() {
                args := []string{argsTeamChannel, userEmail}

                err := removeChannelUsersCmdF(s.client, cmd, args)
-               s.Require().EqualError(err, fmt.Sprintf("individual users must not be specified in conjunction with the --all-users flag"))
+               s.Require().EqualError(err, "individual users must not be specified in conjunction with the --all-users flag")
        })

        s.Run("should remove all users from channel", func() {
```

もう一度ビルドするとようやく通りました。

リポジトリのルートディレクトリ直下に実行ファイルができています。

```
$ ./mmctl version
mmctl v5.24.0 -- 2aba70fdf7ba551b0c21019abd7da33f844ea61e
```

無事にmmctl v5.24をビルドできました。

## 各環境向けにビルドする

`make package`で各環境向けにビルドできるようです。

こちらはbuildディレクトリに出力されます。

```
$ make package
$ ls build/
darwin_amd64.tar  darwin_amd64.tar.md5.txt  linux_amd64.tar  linux_amd64.tar.md5.txt  windows_amd64.zip  windows_amd64.zip.md5.txt
```

