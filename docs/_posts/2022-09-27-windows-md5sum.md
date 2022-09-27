---
title: "Windowsでのmd5sumの確認方法"
excerpt: "Windowsでmd5sumの値を確認する方法のメモ"
date: 2022-09-27 23:57:40 +0900
last_modified_at: 2022-09-27 23:57:40 +0900
categories: "Tech"
tags: ["certutil", "Windows", 'md5sum']
header:
  teaser: /assets/images/terminal-black.png
---

Windowsでmd5sumの値を確認するには`certutil`を使用します。

```
certutil -hashfile <ファイルパス> MD5
```

実行例

```
> certutil -hashfile .\installer-0.0.1-en-US.msi MD5
MD5 ハッシュ (対象 .\installer-0.0.1-en-US.msi):
e07baf042879f8b5e28ca564082a3901
CertUtil: -hashfile コマンドは正常に完了しました。
```
