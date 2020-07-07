# 大陽線(大陰線)全返し
require './holding_days_after_full_returned.rb'
require './holding_days_after_gapup.rb'


#./CSV/N225ディレクトリ内にあるファイル一覧を取得
# stock_codes = get_csv_data('./CSV/N225')[0]
stock_codes = get_csv_data('./CSV/N225_all_time')[0]
# stock_files = get_csv_data('./CSV/N225')[1]
stock_files = get_csv_data('./CSV/N225_all_time')[1]

#スタート時の資産の設定(単位：万年)
initial_assets = 100
#初期値の設定
total_profit = 0 #期間内トータル損益
total_profit_rate = 0 #期間内トータル損益(割合ベース)
total_profit_buy = 0 #買いエントリー合計損益
total_profit_rate_buy = 0 #買いエントリー合計損益
total_profit_sell = 0 #売りエントリー合計損益
total_profit_rate_sell = 0 #売りエントリー合計損益
total_profit_win_buy = 0 #買いエントリーの勝ち額の総和
total_profit_rate_win_buy = 0 #買いエントリーの勝ち額の総和
total_profit_lose_buy = 0 #買いエントリーの負け額の総和
total_profit_rate_lose_buy = 0 #買いエントリーの負け額の総和
total_profit_win_sell = 0 #売りエントリーの勝ち額の総和
total_profit_rate_win_sell = 0 #売りエントリーの勝ち額の総和
total_profit_lose_sell = 0 #売りエントリーの負け額の総和
total_profit_rate_lose_sell = 0 #売りエントリーの負け額の総和
max_return_buy = 0 #買いエントリーの最大勝ち額
max_return_sell = 0 #売りエントリーの最大勝ち額
max_loss_buy = 0 #買いエントリーの最大負け額
max_loss_sell = 0 #売りエントリーの最大負け額
total_count_all =  0 #期間内のトレード合計日数
total_count_buy = 0 #期間内の買いエントリーの合計日数
total_count_sell = 0#期間内の売りエントリーの合計日数
total_count_buy_win = 0 #期間内の買いエントリーの勝ち日数
total_count_sell_win = 0 #期間内の売りエントリーの勝ち日数

# trade_list =  [] #トレード日のohlcリスト
selected_codes = []# 検証したい銘柄のコードを保持する配列
data_result = {} #検証結果データを保持するハッシュ
trade_data = [] #全トレードの取引結果を代入する用の変数


#銘柄リストの中から検証したい銘柄を選択し、変数に代入
selected_codes = select_codes(stock_codes)


#選択された銘柄に対して手法実行ファイルを呼び出し、繰り返し処理
#methodオブジェクトによって手法メソッドをラップする(これによって関数を他の関数の引数として扱うことができるようになる)
# selected_method =  method(:holding_days_after_full_returned)
selected_method =  method(:holding_days_after_full_returned)
#銘柄ごとのトレード検証結果を銘柄コードをkeyにしたハッシュとして取得し、変数に格納
data_result = validation_for_selected_codes(selected_method, selected_codes)
puts data_result

#変数trade_dataに日付別,銘柄別の銘柄収支を格納
selected_codes.each do |code|
    #選択された全ての銘柄の結果を合算して変数に格納
    total_profit += data_result[code][:result][:profit]
    total_profit_rate += data_result[code][:result][:profit_rate]
    total_profit_buy += data_result[code][:result][:profit_buy]
    total_profit_rate_buy += data_result[code][:result][:profit_rate_buy]
    total_profit_sell += data_result[code][:result][:profit_sell]
    total_profit_rate_sell += data_result[code][:result][:profit_rate_sell]
    total_profit_win_buy += data_result[code][:result][:profit_win_buy]
    total_profit_rate_win_buy += data_result[code][:result][:profit_rate_win_buy]
    total_profit_lose_buy += data_result[code][:result][:profit_lose_buy]
    total_profit_rate_lose_buy += data_result[code][:result][:profit_rate_lose_buy]
    total_profit_win_sell += data_result[code][:result][:profit_win_sell]
    total_profit_rate_win_sell += data_result[code][:result][:profit_rate_win_sell]
    total_profit_lose_sell += data_result[code][:result][:profit_lose_sell]
    total_profit_rate_lose_sell += data_result[code][:result][:profit_rate_lose_sell]
    max_return_buy += data_result[code][:result][:max_return_buy]
    max_return_sell += data_result[code][:result][:max_return_sell]
    max_loss_buy += data_result[code][:result][:max_loss_buy]
    max_loss_sell += data_result[code][:result][:max_loss_sell]
    total_count_all += data_result[code][:result][:count_all]
    total_count_buy += data_result[code][:result][:count_buy]
    total_count_sell += data_result[code][:result][:count_sell]
    total_count_buy_win += data_result[code][:result][:count_buy_win]
    total_count_sell_win += data_result[code][:result][:count_sell_win]
end
#選択された銘柄に対して日付別の全取引結果を取得して変数に代入
data_group_by_days = validation_for_date(selected_method, selected_codes)

# data_group_by_days.each do |v|
#     puts v
# end

#勝ちトレード負けトレードに選別する処理
win_list = []
lose_list = []

data_group_by_days.each do |k,v|
    v.each do |trade|
        type = trade[:type]
        entry_price =  trade[:entry_price]
        exit_price =  trade[:exit_price]
        if type ==  "buy"
            profit =  exit_price - entry_price
        else type ==  "sell"
            profit = entry_price - exit_price
        end

        if profit >= 0
            win_list.push trade
        else 
            lose_list.push trade
        end
    end
end
puts "[勝ちトレード]"
puts win_list
puts "[負けトレード]"
puts lose_list

#初期資産の設定
assets = initial_assets
max_count = 3
# daily_score =  daily_profit_for_method(selected_method, selected_codes, assets, max_count)
# puts daily_score

# 初期資金に対するシミュレーション結果
simulation = simulation_for_assets(selected_method, selected_codes, 300, 1)
puts simulation


total_count_buy_lose = total_count_buy- total_count_buy_win
total_count_sell_lose = total_count_sell- total_count_sell_win

puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<全期間エントリーのデータ集計結果>"
puts "エントリー日数: #{total_count_all}日"
puts "期間合計損益: #{total_profit}円"
puts "期間合計損益(割合ベース): #{total_profit_rate}%"
puts "１トレードあたりの平均獲得値幅: #{total_profit/total_count_all}円"
puts "割合ベースの１トレードあたりの平均値幅: #{total_profit_rate/total_count_all}%"
puts "１トレードの平均勝率: #{(total_count_buy_win+total_count_sell_win)/total_count_all.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{(total_profit_win_buy+total_profit_win_sell)/(total_count_buy_win+total_count_sell_win)}"
puts "１トレードあたりの平均勝ち値幅(割合ベース): #{(total_profit_rate_win_buy+total_profit_rate_win_sell)/(total_count_buy_win+total_count_sell_win)}%"
puts "１トレードあたりの平均負け値幅: #{(total_profit_lose_buy+total_profit_lose_sell)/(total_count_buy_lose+total_count_sell_lose)}"
puts "１トレードあたりの平均負け値幅(割合ベース)): #{(total_profit_rate_lose_buy+total_profit_rate_lose_sell)/(total_count_buy_lose+total_count_sell_lose)}%"
# puts "割合ベースの期間合計損益: #{total_profit_rate}%"
# puts "割合ベースの１トレードあたりの平均値幅: #{total_profit_rate/total_count_all}%"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<買いエントリーの内訳>"
puts "エントリ-日数: #{total_count_buy}日"
puts "期間合計損益: #{total_profit_buy}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit_buy/total_count_buy}円"
puts "１トレードあたりの平均獲得値幅(割合べーす): #{total_profit_rate_buy/total_count_buy}%"
puts "１トレードの平均勝率: #{total_count_buy_win/total_count_buy.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{total_profit_win_buy/total_count_buy_win}"
puts "１トレードあたりの平均勝ち値幅(割合ベース): #{total_profit_rate_win_buy/total_count_buy_win}%"
puts "１トレードあたりの平均負け値幅: #{total_profit_lose_buy/(total_count_buy_lose)}"
puts "１トレードあたりの平均負け値幅(割合ベース): #{total_profit_rate_lose_buy/(total_count_buy_lose)}%"
puts "最大利益幅: #{max_return_buy}円"
puts "最大損失幅: #{max_loss_buy}円"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<売りエントリーの内訳>"
puts "エントリー日数: #{total_count_sell}日"
puts "期間合計損益: #{total_profit_sell}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit_sell/total_count_sell}円"
puts "１トレードあたりの平均獲得値幅(割合ベース): #{total_profit_rate_sell/total_count_sell}%"
puts "１トレードの平均勝率: #{total_count_sell_win/total_count_sell.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{total_profit_win_sell/total_count_sell_win}"
puts "１トレードあたりの平均勝ち値幅(割合ベーす): #{total_profit_rate_win_sell/total_count_sell_win}%"
puts "１トレードあたりの平均負け値幅: #{total_profit_lose_sell/(total_count_sell_lose)}"
puts "１トレードあたりの平均負け値幅(割合ベース): #{total_profit_rate_lose_sell/(total_count_sell_lose)}%"
puts "最大利益幅: #{max_return_sell}円"
puts "最大損失幅: #{max_loss_sell}円"
