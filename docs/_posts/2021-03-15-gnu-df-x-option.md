---
title: "dfでtmpfsやoverlayを非表示にする"
excerpt: "dfコマンドで-xオプションを使うと実行結果からtmpfsやoverlayなどの不要なタイプの表示を減らせてすっきりします"
date: 2021-03-15 21:06:40 +0900
last_modified_at: 2021-03-15 21:09:03 +0900
categories: "Tech"
tags: ["df", "Linux", 'GNU', "docker"]
---

## タイプ指定で表示を制限する`-x`オプション

`-x`オプションでタイプを指定するとそのタイプは非表示にできます。

```bash
df -x tmpfs -x overlay
```

`-x`はGNU coreutilsに含まれるdfのオプションです。

.bashrcなどにaliasを書いておくとよさそうです。

```bash
alias df='df -x overlay -x tmpfs'
```

dockerホストでtmpfsやoverlayが多く表示され目的のものが見つけづらかったのですが、この設定をしたら表示がすっきりしました。

## 効果

CentOS 7.9.2009のdocker-ce (version 20.10.5)環境でdfコマンドを実行して比べてみます。

### Before

alias設定前

`/`の空き容量を確認したいだけなのに大量のtmpfsとoverlayで見づらいです。

```bash
$ df -hT
Filesystem                                     Type      Size  Used Avail Use% Mounted on
devtmpfs                                       devtmpfs  7.8G     0  7.8G   0% /dev
tmpfs                                          tmpfs     7.8G     0  7.8G   0% /dev/shm
tmpfs                                          tmpfs     7.8G  165M  7.7G   3% /run
tmpfs                                          tmpfs     7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/mapper/root                               xfs       103G   90G   14G  87% /
/dev/sda1                                      xfs      1014M  251M  764M  25% /boot
tmpfs                                          tmpfs     1.6G     0  1.6G   0% /run/user/1000
overlay                                        overlay   103G   90G   14G  87% /var/lib/docker/overlay/5805ee70035d8374aea0e9e9d9cc0891838dc81252802c8cf054ec733de9663a/merged
overlay                                        overlay   103G   90G   14G  87% /var/lib/docker/overlay/46f915ec8d1a2f3fdc55e7c872f2707d85d7c9b45bc0099e4db0c4de706b8003/merged
overlay                                        overlay   103G   90G   14G  87% /var/lib/docker/overlay/fe98a9d502346d6a4b6fae1b7c10b5b040b904506747c6dc7a3120d698df7d30/merged
overlay                                        overlay   103G   90G   14G  87% /var/lib/docker/overlay/4cc9da65443fd2d88c32da4d85c86617c1e515d3e8bfbd6d5f321f29a57e1ad4/merged
overlay                                        overlay   103G   90G   14G  87% /var/lib/docker/overlay/07a343ded4deb0eabb925842236e79507a7f823c1e0984582f205229bedfb3a8/merged
...
shm                                            tmpfs      64M     0   64M   0% /var/lib/docker/containers/ea6d7c077547efff76e579064f6a6dae8a30791f3570b7c36dad102626c85fa6/mounts/shm
shm                                            tmpfs      64M     0   64M   0% /var/lib/docker/containers/f828418e54cde43010b74070b2730498dd3d99f1e4f1020bf679a6d326f66ab4/mounts/shm
shm                                            tmpfs      64M     0   64M   0% /var/lib/docker/containers/d32e168185ef12aa2c54f6182264aa2cac8239290a0e857c49eb9cc7c7c2a134/mounts/shm
shm                                            tmpfs      64M     0   64M   0% /var/lib/docker/containers/d2512239371fdfa8c717276edee3c55351399685acc56162a28c41a3443e5499/mounts/shm
shm                                            tmpfs      64M     0   64M   0% /var/lib/docker/containers/cae62bb7a961c499695972a526c3e799835b5962ad3becae56ed896c6b7b4863/mounts/shm
...
```

### After

-xオプションを指定したらすっきりしました。

```bash
$ df -x overlay -x tmpfs -hT
Filesystem                                     Type      Size  Used Avail Use% Mounted on
devtmpfs                                       devtmpfs  7.8G     0  7.8G   0% /dev
/dev/mapper/root                               xfs       103G   90G   14G  87% /
/dev/sda1                                      xfs      1014M  251M  764M  25% /boot
```

aliasを設定しておくとオプションも省略できます。

```bash
$ df -hT
Filesystem                                     Type      Size  Used Avail Use% Mounted on
devtmpfs                                       devtmpfs  7.8G     0  7.8G   0% /dev
/dev/mapper/root                               xfs       103G   90G   14G  87% /
/dev/sda1                                      xfs      1014M  251M  764M  25% /boot
```

