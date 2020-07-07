#大陽線(大陰線)全返し後,数日間ポジション保有
#銘柄毎の繰り返し処理のために関数化
require 'csv'
require './module/analysis_tool'
require './module/convenient_tool'

# 関数に代入した銘柄コードの銘柄の大陽線(大陰線)返しの期待値を返すメソッド
def holding_days_after_gapup(stock_code)
    # 選択されたCSVデータをtable型のデータに変換
    # data_name = "CSV/N225/#{stock_code}_2011_2019.CSV"
    data_name = "CSV/N225_all_time/#{stock_code}.CSV"
    table =  CSV.table(data_name)
    count = table.count #検証期間合計日数

    #初期値の設定
    trades = [] #トレード日のトレード結果の配列。配列はトレード日,購入価格、売却価格のハッシュ。
    total_profit = 0  #期間内トータル損益
    total_profit_rate =  0 #期間内トータル損益(割合ベース)
    total_profit_buy = 0 #買いエントリー合計損益
    total_profit_sell = 0 #売りエントリー合計損益
    total_profit_win_buy =  0 #買いエントリーの勝ち額の総和
    total_profit_lose_buy =  0 #買いエントリーの負け額の総和
    total_profit_win_sell =  0 #売りエントリーの勝ち額の総和
    total_profit_lose_sell =  0 #売りエントリーの負け額の総和
    max_return_buy = 0 #買いエントリーの最大勝ち額
    max_return_sell = 0 #売りエントリーの最大勝ち額
    max_loss_buy = 0 #買いエントリーの最大負け額
    max_loss_sell = 0 #売りエントリーの最大負け額
    count_all =  0 #期間内のトレード合計日数
    count_buy = 0 #期間内の買いエントリーの合計日数
    count_sell = 0#期間内の売りエントリーの合計日数
    count_buy_win = 0 #期間内の買いエントリーの勝ち日数
    count_sell_win =  0 #期間内の売りエントリーの勝ち日数
    trade_list =  [] #トレード日のohlcリスト

    #検証する初期条件の設定(ユーザー入力値)
    rate =  0.1
    days_in_holding = 1


    #繰り返し処理
    (count-(days_in_holding-1)-1).times do |i|
        data_today = table[i+1]
        data_yesterday = table[i]
        #ストップ高張り付きは買えないので除外
        next if stop_price?(data_today)
        close_price_yesterday = data_yesterday[:close]
        #前日陽線と陰線の場合で条件分岐
        if gap_down_for_rate?(data_today, data_yesterday,rate)
            # ギャップダウン時は売りエントリー
            data_for_position_closed_day = table[i+days_in_holding]
            #トレード損益
            trade_profit = data_today[:open] - data_for_position_closed_day[:close]

            if trade_profit > 0
                count_sell_win+=1
                total_profit_win_sell += trade_profit
            else 
                total_profit_lose_sell += trade_profit
            end
            max_return_sell = trade_profit if max_return_sell < trade_profit
            max_loss_sell = trade_profit if trade_profit < max_loss_sell 
            trade_profit_rate = trade_profit/data_today[:open].to_f*100
            total_profit_sell+=trade_profit
            count_sell += 1
            count_all +=1
            total_profit += trade_profit
            total_profit_rate += trade_profit_rate
            
            trade = {date: Date.parse(data_today[:date]),type: "sell", entry_price: data_today[:open], exit_price: data_for_position_closed_day[:close]}
            trades.push trade
        elsif gap_up_for_rate?(data_today, data_yesterday,rate)
            # ギャップアップ時は買いエントリー
            data_for_position_closed_day = table[i+days_in_holding]
            trade_profit = data_for_position_closed_day[:close] - data_today[:open]

            if trade_profit > 0
                count_buy_win+=1
                total_profit_win_buy += trade_profit
            else 
                total_profit_lose_buy += trade_profit
            end
            
            max_return_buy = trade_profit if max_return_buy < trade_profit
            max_loss_buy = trade_profit if trade_profit < max_loss_buy 
            trade_profit_rate = trade_profit/data_today[:open].to_f*100
            total_profit_buy+=trade_profit
            count_buy += 1
            count_all +=1
            total_profit += trade_profit
            total_profit_rate += trade_profit_rate
            
            trade = {date: Date.parse(data_today[:date]),type: "buy", entry_price: data_today[:open], exit_price: data_for_position_closed_day[:close]}
            trades.push trade
            
        end
        
    end

    # これまでのカウンティングから買いエントリー、売りエントリーそれぞれの合計負け回数を定義
    count_buy_lose =  count_buy-count_buy_win
    count_sell_lose =  count_sell-count_sell_win

    result = {
        profit: total_profit,
        profit_rate: total_profit_rate,
        profit_buy: total_profit_buy,
        profit_sell: total_profit_sell,
        profit_win_buy: total_profit_win_buy,
        profit_lose_buy: total_profit_lose_buy,
        profit_win_sell: total_profit_win_sell,
        profit_lose_sell: total_profit_lose_sell,
        max_return_buy: max_return_buy,
        max_return_sell: max_return_sell,
        max_loss_buy: max_loss_buy,
        max_loss_sell: max_loss_sell,
        count_all: count_all,
        count_buy: count_buy,
        count_sell: count_sell,
        count_buy_win: count_buy_win,
        count_sell_win: count_sell_win
    }

    trades_result = {code: stock_code, trades: trades, result: result}

    return trades_result
    
    
end


