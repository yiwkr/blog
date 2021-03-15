---
title: "bootstrap-vueでEnterを押すかフォーカスが外れたときに入力確定する入力フィールドを作った"
excerpt: "Enterを押すかフォーカスが外れたときに入力が確定する入力フィールドをvueのコンポーネントとして作ってみました"
date: 2020-04-20 12:30:00 +0900
last_modified_at: 2021-03-15 21:19:09 +0900
categories: "Tech"
tags: ["Web", "Vue.js", "BootstrapVue"]
---

## はじめに

勉強がてら簡単なWebアプリをvue+bootstrap-vueで作ってみていますが、そのなかでbootstrap-vueにはない機能をもったコンポーネントが必要になったので作ってみました。

## 概要

### 作ったもの

フォーカスした状態でEnterキーを押すかフォーカスが外れると入力が確定する入力フィールドを作りました。[v-model][v-model]が使えます。

### バージョン

使用したライブラリのバージョンは以下です。

| ライブラリ | バージョン |
| :---- | :---- |
| vue | 2.6.11 |
| bootstrap-vue | 2.11.0 |

## 詳細

### ポイント

実装のポイントは以下の3点です。

- v-model対応  
    valueプロパティで値を受け取ってフォーカスが外れたときにinputイベントを発火
- Enterキー対応  
    keyupイベントとイベント装飾子.nativeを使ってEnterキーが押されたときにフォーカスを外す
- 変更検知  
    b-form-inputのinputイベントを使ってフォーカス後最初の入力前の値を保持して変更検知

ひとつずつ見ていきます。

### 各ポイントの説明

#### v-model対応

自作コンポーネントでv-modelに対応する場合、デフォルトの設定ではvalueプロパティで値を受け取ってinputイベントを発火する必要があります。（どのプロパティとイベントを使うかは[コンポーネントの設定で変更できる][custom-v-model]ようです）

今回作成したコンポーネントでは、valueプロパティを定義し、b-form-inputの`formatter`属性に指定したlazyFormatterの中でinputイベントを発火することでこの要件を満たしています。

lazyFormatterはフォーカスが外れたときに実行してほしいので`b-form-input`に`lazy-formatter`も指定します。

``` vue
<template>
  <b-form-input
    (略)
    :formatter="lazyFormatter"
    lazy-formatter
    (略)
  ></b-form-input>
</template>
<script>
(略)
  props: {
    id: { type: String, required: true },
    value: { type: String, required: true }
  },
  (略)
  methods: {
    /**
     * フォーカスが外れたときに呼び出されるメソッド
     * 値が変更されている場合はinputイベントを発火
     * （本来は値を整形するために使用するがここでは値の確定（変更通知）に利用）
     */
    lazyFormatter (value) {
      // 以下の場合は値が更新されているのでinputイベントを発火する
      if (this.oldValue !== null && this.oldValue !== value) {
        this.$emit('input', value)
      }

      // oldValueをリセットする
      this.oldValue = null

      return value
    },
(略)
</script>
```

`formatter`は本来ユーザーが入力した値を整形するために使うもので通常はユーザーが一文字入力するごとに`formatter`で指定した関数が実行されますが、`lazy-formatter`を指定することでフォーカスが外れたときのみ実行されるようになります。


#### Enterキー対応

Enterキーが入力されたときにフォーカスを外す処理を入れたいのですが、b-form-inputには
キー入力に関するイベントが定義されていません。そのため.nativeイベント装飾子を使って
b-form-inputのルート要素（input）のイベントにハンドラを設定します。

ただし、これだけだと日本語入力の確定でEnterキーを押した場合にもフォーカスが外れてしまうため、
compositionstartイベントを使って日本語入力開始を検出し、日本語入力中かどうかを判定をします。

``` vue
<template>
  <b-form-input
    (略)
    @keyup.enter.native="keyupEnter"
    @compositionstart="composing=true"
    (略)
  ></b-form-input>
</template>

<script>
  (略)
  data () {
    return {
      // 日本語入力中か判定するために使用
      // 日本語入力中: true、日本語入力中ではない: false
      composing: false,
      (略)
    }
  },
  computed: {
    refName () {
      return `blur-input-${this.id}`
    }
  },
  methods: {
    (略)
    /**
     * Enterキーが押されたときに呼び出されるメソッド
     * Enterキーが押されたときにフォーカスを外す
     * ただし、日本語入力の確定ではフォーカスを外さない
     */
    keyupEnter () {
      if (!this.composing) {
        // 日本語入力中でなければフォーカスを外す
        this.$refs[this.refName].blur()
      } else {
        // 日本語入力中にEnterキーが押された場合はcomposingフラグをfalseにする
        this.composing = false
      }
    },
(略)
</script>
```

#### 変更検知

入力した値に変更がない場合は無駄なinputイベントを発火しないようにするため、入力変更前の値をoldValueに保持して変更を検知します。

``` vue
<template>
  <b-form-input
    (略)
    :value="value"
    (略)
    @input="saveOldValue"
    (略)
  ></b-form-input>
</template>

<script>
export default {
  (略)
  props: {
  (略)
    value: { type: String, required: true }
  },
  data () {
      (略)
      // 変更検知のために使用
      // フォーカス後最初に文字入力されてからフォーカスが外れるまで: 入力前の文字列
      // 上記以外: null
      oldValue: null
    }
  },
  (略)
  methods: {
    /**
     * フォーカスが外れたときに呼び出されるメソッド
     * 値が変更されている場合はinputイベントを発火
     * （本来は値を整形するために使用するがここでは値の確定（変更通知）に利用）
     */
    lazyFormatter (value) {
      // 以下の場合は値が更新されているのでinputイベントを発火する
      if (this.oldValue !== null && this.oldValue !== value) {
        this.$emit('input', value)
      }

      // oldValueをリセットする
      this.oldValue = null

      return value
    },
    (略)
    /**
     * フォーカスされてから初めて入力されたときのvalueを保存
     * oldValueにはフォーカスが外れたときにnullを代入されていること
     */
    saveOldValue () {
      if (this.oldValue === null) {
        this.oldValue = this.value
      }
    }
  }
}
</script>
```

### コンポーネント実装全体

ここまでの内容をすべてまとめたコードを以下に記載します。

BlurInput.vue

``` vue
<template>
  <b-form-input
    :id="id"
    :ref="refName"
    :value="value"
    :formatter="lazyFormatter"
    lazy-formatter
    @input="saveOldValue"
    @keyup.enter.native="keyupEnter"
    @compositionstart="composing=true"
  ></b-form-input>
</template>

<script>
export default {
  name: 'blur-input',
  props: {
    id: { type: String, required: true },
    value: { type: String, required: true }
  },
  data () {
    return {
      // 日本語入力中か判定するために使用
      // 日本語入力中: true、日本語入力中ではない: false
      composing: false,
      // 変更検知のために使用
      // フォーカス後最初に文字入力されてからフォーカスが外れるまで: 入力前の文字列
      // 上記以外: null
      oldValue: null
    }
  },
  computed: {
    refName () {
      return `blur-input-${this.id}`
    }
  },
  methods: {
    /**
     * フォーカスが外れたときに呼び出されるメソッド
     * 値が変更されている場合はinputイベントを発火
     * （本来は値を整形するために使用するがここでは値の確定（変更通知）に利用）
     */
    lazyFormatter (value) {
      // 以下の場合は値が更新されているのでinputイベントを発火する
      if (this.oldValue !== null && this.oldValue !== value) {
        this.$emit('input', value)
      }

      // oldValueをリセットする
      this.oldValue = null

      return value
    },
    /**
     * Enterキーが押されたときに呼び出されるメソッド
     * Enterキーが押されたときにフォーカスを外す
     * ただし、日本語入力の確定ではフォーカスを外さない
     */
    keyupEnter () {
      if (!this.composing) {
        // 日本語入力中でなければフォーカスを外す
        this.$refs[this.refName].blur()
      } else {
        // 日本語入力中にEnterキーが押された場合はcomposingフラグをfalseにする
        this.composing = false
      }
    },
    /**
     * フォーカスされてから初めて入力されたときのvalueを保存
     * oldValueにはフォーカスが外れたときにnullを代入されていること
     */
    saveOldValue () {
      if (this.oldValue === null) {
        this.oldValue = this.value
      }
    }
  }
}
</script>
```

## おわりに

bootstrap-vueのformatter、lazy-formatterの機能などを使って、Enterを押したときかフォーカスが外れたときに入力が確定する入力フィールドを作ることができました。また、vueコンポーネントのv-modelの対応方法も確認できました。

vue+bootstrapにはまだいろんな機能があるのでいろいろ使いながら学習してきたいと思います。

[v-model]: https://jp.vuejs.org/v2/guide/forms.html
[custom-v-model]: https://jp.vuejs.org/v2/guide/components-custom-events.html#v-model-%E3%82%92%E4%BD%BF%E3%81%A3%E3%81%9F%E3%82%B3%E3%83%B3%E3%83%9D%E3%83%BC%E3%83%8D%E3%83%B3%E3%83%88%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA
[formatter]: https://bootstrap-vue.js.org/docs/components/form-input
