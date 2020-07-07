# analitics_for_stock_trade

## 各ファイルの説明

CSVディレクトリ: 各銘柄の日足のcsvデータ
moduleディレクトリ: 検証の為に使用する関数をまとめたもの
execute.rb: 各手法を検証する為の実行ファイル
それ以外のファイル：　各手法のロジックを記述したロジック記述ファイル。

## データ検証方法

・execute.rbが実行ファイルとなっているので、ターミナルにて実行(ruby execute.rb)すると各取引手法の期待値が得られます。（処理に数十秒ほどお時間かかってしまうかもしれません。)
・検証するロジックを変更したい場合はexecute.rbファイルの１行目にて検証したいロジックをrequireした後に、52行目に記述された関数を書き換えていただく必要があります。

※手法の概要

・どのロジックも取引前日までの連続したローソク足の形状から当日の売買に優位性があるか調べるものになります。
