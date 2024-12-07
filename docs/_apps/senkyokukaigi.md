---
title: "SenkyokuKaigi"
toc: true
toc_sticky: true
header:
  teaser: /assets/images/apps/senkyokukaigi/icon-256x256.png
---

![SenkyokuKaigi-icon](../../assets/images/apps/senkyokukaigi/icon-32x32.png)
選曲会議の投票結果を表示・記録するためのWindowsアプリです。

## ダウンロード

下記のリンクからダウンロードしてください。

<a href="../../assets/downloads/SenkyokuKaigi_0.0.1_x64_en-US.msi" class="btn btn--success">Download SenkyokuKaigi_0.0.1_x64_en-US.msi</a>  
最終更新日: 2022年9月27日

md5sum: `b1e383d2dcf88da605acd1a3c887c40a`  
(参考: [Windowsでのmd5sumの確認方法](../../2022-09-27-windows-md5sum))

## 詳細

### 説明

選曲会議とは、ここでは楽器の演奏団体が演奏会の演奏曲目を決定する会議のことを指します。
選曲会議ではしばしば、複数の人が提案した曲の組み合わせの中からどの組み合わせを演奏会で演奏するか決めるために投票が行われます。
本アプリでは投票方法として優先順位付投票（Instant Runoff Voting）[^instant-runoff-voting]を採用することで公平な選曲を目指します。
投票結果をファイルに保存することで会議の記録としても利用でき、開票作業が自動化されることで誤り防止にもなります。

### 画面

#### 基本情報と候補

会議データには基本情報と投票対象の候補を設定できます。

![senkyokukaigi-01](../../assets/images/apps/senkyokukaigi/senkyokukaigi_01.png)

#### 投票の記録

投票対象の候補に対してだれがどの順番で評価したかを投票結果として残せます。

![senkyokukaigi-02](../../assets/images/apps/senkyokukaigi/senkyokukaigi_02.png)

#### 結果表示

投票結果に基づいて、開票結果を表示します。最終結果のほか、各段階での開票結果も表示されます。

![senkyokukaigi-03](../../assets/images/apps/senkyokukaigi/senkyokukaigi_03.png)

#### 会議データの保存

会議データは保存して、あとから開くことができます。

![senkyokukaigi-04](../../assets/images/apps/senkyokukaigi/senkyokukaigi_04.png)

### 更新履歴

|年月日|バージョン|更新内容|
|:--|:--|:--|
|2022.9.27|0.0.1|アプリを公開|

[^instant-runoff-voting]: Wikipediaの[優先順位付投票制](https://ja.wikipedia.org/wiki/%E5%84%AA%E5%85%88%E9%A0%86%E4%BD%8D%E4%BB%98%E6%8A%95%E7%A5%A8%E5%88%B6)（外部サイト）を参照ください。

