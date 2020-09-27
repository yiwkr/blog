---
title: "pythonの標準ライブラリでdictの差分を表示する"
excerpt: "標準ライブラリのpprintとdifflibを使ってdictの差分を表示してみました"
date: 2020-09-27 19:04:07 +0900
last_modified_at、: 2020-09-27 19:08:20 +0900
categories: "Tech"
tags: ["python", "diff", "dict", "json"]
---

## 背景

pythonのdictについて差分情報をログに出したかったので、できるだけ簡単に実現できる方法を調べました。使用しているpythonのバージョンは3.6です。

dictdifferを使った方法など、差分をpythonスクリプト上で扱う方法は検索したらすぐに出てきましたが、単純に差分を表示して目視で確認したい場合に見やすい出力方法が見つけられなかったのでメモしておきます。

下記のようにdictの差分を見やすく表示します。

```
  {'number': 1,
-  'tuple': ('aaa', 'bbb', 'ccc')}
?                     ^

+  'tuple': ('aaa', 'bdb', 'ccc')}
?                     ^

```

## 対象データ

対象のdictは、キーが文字列で、値はstr、int、float、list、tuple、dictのいずれかです。（キーが文字列以外のものや、値にset、function、その他オブジェクトが入っているものは今回対象にしていません）

例として以下のdict（before, after）の差分を表示してみます。パッと見ではどこに変更があるのかわかりません。

変更前

```python
before = {
    'number': 1,
    'tuple': ('aaa', 'bbb', 'ccc'),
    'None': None,
    'dict': {
        'list': [
            'A',
            {'B': [1, 2, 3]},
            ['C'],
            ('F', 'G'),
        ],
    },
}
```

変更後

```python
after = {
    'number': 1,
    'tuple': ('aaa', 'bdb', 'ccc'),
    'None': None,
    'dict': {
        'list': [
            'A',
            {'B': [1, 4, 3]},
            ['C', 'D'],
            ('F',),
        ],
    },
}
```

## 実装例

diff.py

```python
import difflib
from pprint import pformat


before = {
    'number': 1,
    'tuple': ('aaa', 'bbb', 'ccc'),
    'None': None,
    'dict': {
        'list': [
            'A',
            {'B': [1, 2, 3]},
            ['C'],
            ('F', 'G'),
        ],
    },
}

after = {
    'number': 1,
    'tuple': ('aaa', 'bdb', 'ccc'),
    'None': None,
    'dict': {
        'list': [
            'A',
            {'B': [1, 4, 3]},
            ['C', 'D'],
            ('F',),
        ],
    },
}


def to_string_lines(obj):
    # dictのオブジェクトを文字列に変換＆改行で分割したリストを返却
    return pformat(obj).split('\n')


def diff(obj1, obj2):
    # obj1、obj2を文字列のリストに変換
    lines1 = to_string_lines(obj1)
    lines2 = to_string_lines(obj2)

    # lines1、lines2を比較
    result = difflib.Differ().compare(lines1, lines2)

    # 比較結果を改行で結合して一つの文字列として返却
    return '\n'.join(result)


# 比較結果を表示
print(diff(before, after))
```

## 出力例

実装例の実行結果です。

```
  {'None': None,
-  'dict': {'list': ['A', {'B': [1, 2, 3]}, ['C'], ('F', 'G')]},
?                                   ^                   ----

+  'dict': {'list': ['A', {'B': [1, 4, 3]}, ['C', 'D'], ('F',)]},
?                                   ^           +++++

   'number': 1,
-  'tuple': ('aaa', 'bbb', 'ccc')}
?                     ^

+  'tuple': ('aaa', 'bdb', 'ccc')}
?                     ^

```

行頭に`-`がついている行は変更前の行です。  
行頭に`+`がついている行は変更後の行です。  
行頭に`?`がついている行は変更前にも変更後にも存在しない行です。部分的な変更について変更箇所が示されます。  
先頭に上記のいずれの文字もない行は変更がない行です。

実行結果を見ると、4箇所変更があったことがわかります。

1. `before['dict']['list'][1]['B'][1]`が`2`から`4`に変更
2. `after['dict']['list'][2][1]`に`'D'`が追加
3. `before['dict']['list'][3][1]`の`'G'`が削除
4. `before['tuple'][1]`が`'bbb'`から`'bdb'`に変更

## 解説

### pprint.pformatでdictを見やすい文字列に変換

実装例の下記の部分でdictを見やすい文字列に変換しています。（この関数ではついでに、次の処理で使いやすいように改行で分割するところまで実施しています）

```python
def to_string_lines(obj):
    # dictのオブジェクトを文字列に変換＆改行で分割したリストを返却
    return pformat(obj).split('\n')
```

標準ライブラリの[pprint][pprint]のpformatを使って、適度に改行をはさんで見やすい文字列に変換します。

```python
$ python -i diff.py
(略)
>>> print(pformat(before))
{'None': None,
 'dict': {'list': ['A', {'B': [1, 2, 3]}, ['C'], ('F', 'G')]},
 'number': 1,
 'tuple': ('aaa', 'bbb', 'ccc')}
```

ポイントは、このときdictのキーバリューがキー順でソートされることです。これによって、行ごとに差分を取るだけでdictの差分が正しく取れます。

jsonライブラリを使ってもよいですが、pprintのほうがコンパクトに表示されるのでpprintを採用しました。

jsonライブラリの場合

```python
>>> import json
>>> print(json.dumps(before, indent=2, sort_keys=True, ensure_ascii=False))
{
  "None": null,
  "dict": {
    "list": [
      "A",
      {
        "B": [
          1,
          2,
          3
        ]
      },
      [
        "C"
      ],
      [
        "F",
        "G"
      ]
    ]
  },
  "number": 1,
  "tuple": [
    "aaa",
    "bbb",
    "ccc"
  ]
}
```

### difflibを使って差分表示

実装例の下記の部分で差分をとっています。

```python
def diff(obj1, obj2):
    # obj1、obj2を文字列のリストに変換
    lines1 = to_string_lines(obj1)
    lines2 = to_string_lines(obj2)

    # lines1、lines2を比較
    result = Differ().compare(lines1, lines2)

    # 比較結果を改行で結合して一つの文字列として返却
    return '\n'.join(result)
```

標準ライブラリの[difflib][difflib]を使っています。

to_string_lines()でdictを文字列のリストに変換してから、difflib.Differオブジェクトのcompareメソッドで比較しています。

difflibでは他にも、unified形式やcontext形式で差分表示することができるようなので、見やすい形式で表示するとよさそうです。

#### unified形式の例

```python
>>> result = difflib.unified_diff(
...     to_string_lines(before), to_string_lines(after),
...     fromfile='before', tofile='after')
>>> print('\n'.join(result))
--- before

+++ after

@@ -1,4 +1,4 @@

 {'None': None,
- 'dict': {'list': ['A', {'B': [1, 2, 3]}, ['C'], ('F', 'G')]},
+ 'dict': {'list': ['A', {'B': [1, 4, 3]}, ['C', 'D'], ('F',)]},
  'number': 1,
- 'tuple': ('aaa', 'bbb', 'ccc')}
+ 'tuple': ('aaa', 'bdb', 'ccc')}
```

#### context形式の例

```python
>>> result = difflib.context_diff(
...     to_string_lines(before), to_string_lines(after),
...     fromfile='before', tofile='after')
>>> print('\n'.join(result))
*** before

--- after

***************

*** 1,4 ****

  {'None': None,
!  'dict': {'list': ['A', {'B': [1, 2, 3]}, ['C'], ('F', 'G')]},
   'number': 1,
!  'tuple': ('aaa', 'bbb', 'ccc')}
--- 1,4 ----

  {'None': None,
!  'dict': {'list': ['A', {'B': [1, 4, 3]}, ['C', 'D'], ('F',)]},
   'number': 1,
!  'tuple': ('aaa', 'bdb', 'ccc')}
```

## まとめ

標準ライブラリのpprintとdifflibを使って簡単にdictの差分表示ができました。標準ライブラリだけで簡単にこのような処理が実装できるのはpythonの強みですね。

## 参考

1. [difflib --- 差分の計算を助ける — Python 3.6.12 ドキュメント][pprint]
2. [pprint --- データ出力の整然化 — Python 3.6.12 ドキュメント][difflib]

[pprint]: https://docs.python.org/ja/3.6/library/pprint.html
[difflib]: https://docs.python.org/ja/3.6/library/difflib.html
