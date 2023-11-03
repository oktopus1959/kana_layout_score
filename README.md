# kana_layout_score
薙刀式や新下駄など、拗音を1アクションで入力できるかな配列に対して、2モーラ連接統計を用いてそのスコアを計算します。

## 結果
`kana_layout_2mora_score.xlsx` にまとめてあります。

## 
## 実行
ruby 処理系が必要になります。

```
$ ./analyze.sh
score = 6.62; total_score = 7534924.93, total_count = 1137532
score = 6.59; total_score = 7497278.61, total_count = 1137532
score = 6.76; total_score = 7693749.63, total_count = 1137532
```

```
$ ./extract_milestone.sh
---- naginata ----
1: word=てい, count=7484, total_count=7484
1: cost=4.86, score=36401.43, total_score=36401.43
10: word=うし, count=5059, total_count=56458
10: cost=5.16, score=26101.91, total_score=261482.09
100: word=され, count=1825, total_count=298769
100: cost=5.17, score=9435.25, total_score=1792069.22
・・・
6500: word=そゆ, count=1, total_count=1137438
6500: cost=8.49, score=8.49, total_score=7534220.99
score = 6.62; total_score = 7534924.93, total_count = 1137532
---- singeta ----
1: word=てい, count=7484, total_count=7484
1: cost=3.8, score=28439.2, total_score=28439.2
10: word=うし, count=5059, total_count=56458
10: cost=3.93, score=19881.87, total_score=283544.75
100: word=され, count=1825, total_count=298769
100: cost=7.83, score=14289.75, total_score=1721228.26
・・・
6500: word=そゆ, count=1, total_count=1137438
6500: cost=9.13, score=9.13, total_score=7496514.63
score = 6.59; total_score = 7497278.61, total_count = 1137532
---- noniiruto ----
1: word=てい, count=7484, total_count=7484
1: cost=4.49, score=33617.38, total_score=33617.38
10: word=うし, count=5059, total_count=56458
10: cost=5.7, score=28838.83, total_score=314451.3
100: word=され, count=1825, total_count=298769
100: cost=7.0, score=12775.0, total_score=1769157.05
・・・
6500: word=そゆ, count=1, total_count=1137438
6500: cost=8.4, score=8.4, total_score=7692845.59
score = 6.76; total_score = 7693749.63, total_count = 1137532
```

## カスタマイズ
### 別の2モーラ統計ファイルを使う
`analyze_bimora_time.rb` で 'MoraFile` にファイル名を設定する。

### 大岡氏のオリジナルの時間統計を用いる
`analyze_bimora_time.rb` で '$doLeftHandAdust = false` と設定する。

### 時間統計テーブルを出力する
`analyze_bimora_time.rb` で '$timeTableDump = true` と設定する。

## スコア算出方法
`cost(A, B)` を、2連接時間表におけるキーAからキーBへの打鍵時間とする。
たとえば、`cost('Q', S') =  9.17` である。（大岡氏による2連接900種打鍵時間表より）

このとき、第1モーラが (A, B) という同時打鍵列、第2打鍵が (X, Y, Z) という同時打鍵列ならば
`score = max(cost(A, X), cost(A, Y), cost(A, Z), cost(B, X), cost(B, Y), cost(B, Z)) + TRIPLE_SHIFT_PENALTY` となる。

## ペナルティ
- 同時打鍵から単打に移行 = 1.0 (`UNSHIFT_PENALTY`)
  ただし、ワンショットコンボから単打への移行では、ロールオーバーしても同時打鍵と判定されることはないので、同時打鍵解除のためのペナルティは不要。
- 単打２連接が同時打鍵と重複 = 2.0 (`DECOMBO_PENALTY`)
- ２キー同時打鍵 = 2.0 (`SHIFT_PENALTY`)
- SandS 同時打鍵 = 3.0 (`SANDS_PENALTY`)
- 先押し後離し = 4.0 (`FPLR_PENALTY`)
- ３キー同時打鍵 = 5.0 (`TRIPLE_SHIFT_PENALTY`)

ペナルティは、打鍵状態が変わる際の「間」であると考えている。そのため、コスト (`cost`) に対して加算している。

なお、文字キーから文字キーへの遷移コストの平均は `6.16` である。
