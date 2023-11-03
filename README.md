# kana_layout_score
薙刀式や新下駄など、拗音を1アクションで入力できるかな配列に対して、2モーラ連接統計を用いてそのスコアを計算します。

## 結果
`kana_layout_2mora_score.xlsx` にまとめてあります。

## 実行
ruby 処理系が必要になります。

```
$ ./analyze.sh
score = 6.62; total_score = 7534924.93, total_count = 1137532
score = 6.59; total_score = 7497278.61, total_count = 1137532
score = 6.76; total_score = 7693749.63, total_count = 1137532
```

```
---- naginata ----
1: word=てい, count=7484, total_count=7484
1: cost=4.86, score=36401.43, total_score=36401.43
10: word=うし, count=5059, total_count=56458
10: cost=5.16, score=26101.91, total_score=261482.09
100: word=され, count=1825, total_count=298769
100: cost=5.17, score=9435.25, total_score=1792069.22
500: word=りょく, count=558, total_count=681697
500: cost=6.27, score=3498.66, total_score=4309915.17
1000: word=がじ, count=266, total_count=870190
1000: cost=5.56, score=1478.22, total_score=5606326.48
1500: word=どか, count=158, total_count=973638
1500: cost=6.45, score=1019.8, total_score=6336292.72
2000: word=しゃい, count=96, total_count=1036020
2000: cost=5.72, score=548.65, total_score=6776194.4
2500: word=なぶ, count=60, total_count=1074299
2500: cost=7.44, score=446.4, total_score=7056664.87
3000: word=やわ, count=37, total_count=1097938
3000: cost=4.73, score=175.01, total_score=7231365.17
3500: word=びみ, count=24, total_count=1113028
3500: cost=8.53, score=204.8, total_score=7342419.38
4000: word=ぼか, count=15, total_count=1122704
4000: cost=6.79, score=101.92, total_score=7416061.23
4500: word=じゅっ, count=10, total_count=1128830
4500: cost=7.48, score=74.82, total_score=7464467.6
5000: word=ぽし, count=6, total_count=1132794
5000: cost=7.19, score=43.14, total_score=7496159.46
5500: word=こぜ, count=4, total_count=1135194
5500: cost=6.29, score=25.17, total_score=7515681.77
6000: word=ふぃか, count=2, total_count=1136616
6000: cost=7.15, score=14.29, total_score=7527524.09
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
500: word=りょく, count=558, total_count=681697
500: cost=5.9, score=3292.81, total_score=4231319.39
1000: word=がじ, count=266, total_count=870190
1000: cost=9.03, score=2401.98, total_score=5530454.62
1500: word=どか, count=158, total_count=973638
1500: cost=7.32, score=1155.85, total_score=6273344.57
2000: word=しゃい, count=96, total_count=1036020
2000: cost=6.9, score=662.4, total_score=6721391.41
2500: word=なぶ, count=60, total_count=1074299
2500: cost=8.17, score=490.2, total_score=7008572.56
3000: word=やわ, count=37, total_count=1097938
3000: cost=7.83, score=289.71, total_score=7188799.35
3500: word=びみ, count=24, total_count=1113028
3500: cost=7.43, score=178.34, total_score=7304154.32
4000: word=ぼか, count=15, total_count=1122704
4000: cost=6.72, score=100.73, total_score=7378877.87
4500: word=じゅっ, count=10, total_count=1128830
4500: cost=7.09, score=70.95, total_score=7427560.87
5000: word=ぽし, count=6, total_count=1132794
5000: cost=7.13, score=42.78, total_score=7459182.13
5500: word=こぜ, count=4, total_count=1135194
5500: cost=7.2, score=28.8, total_score=7478351.23
6000: word=ふぃか, count=2, total_count=1136616
6000: cost=6.56, score=13.11, total_score=7489852.6
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
500: word=りょく, count=558, total_count=681697
500: cost=11.77, score=6570.22, total_score=4276122.19
1000: word=がじ, count=266, total_count=870190
1000: cost=6.91, score=1837.0, total_score=5569470.73
1500: word=どか, count=158, total_count=973638
1500: cost=7.03, score=1110.74, total_score=6321072.01
2000: word=しゃい, count=96, total_count=1036020
2000: cost=10.47, score=1005.12, total_score=6801439.48
2500: word=なぶ, count=60, total_count=1074299
2500: cost=10.93, score=655.8, total_score=7117968.45
3000: word=やわ, count=37, total_count=1097938
3000: cost=8.4, score=310.77, total_score=7321955.36
3500: word=びみ, count=24, total_count=1113028
3500: cost=9.33, score=223.87, total_score=7453415.21
4000: word=ぼか, count=15, total_count=1122704
4000: cost=6.84, score=102.54, total_score=7543263.29
4500: word=じゅっ, count=10, total_count=1128830
4500: cost=10.83, score=108.3, total_score=7603622.91
5000: word=ぽし, count=6, total_count=1132794
5000: cost=7.17, score=43.0, total_score=7643824.79
5500: word=こぜ, count=4, total_count=1135194
5500: cost=8.09, score=32.38, total_score=7668689.63
6000: word=ふぃか, count=2, total_count=1136616
6000: cost=11.33, score=22.66, total_score=7684194.31
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


