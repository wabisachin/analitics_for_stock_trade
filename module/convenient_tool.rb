# 分析ツール以外の一般的な便利な機能をまとめたツール

def get_csv_data(directory)
    stock_files=[]
    stock_codes =[]
    Dir.foreach(directory) do |file|
        next if file == '.' or file == '..'
        stock_files.push file
    end
    stock_files.each do |file|
        stock_code = file.slice(0..3)
        stock_codes.push stock_code
    end
    #配列[0]に銘柄コードを,配列[1]にファイル名を返す
    return [stock_codes,stock_files]
end

#引数に渡した銘柄リストの中から検証したい銘柄を選択させるメソッド
def select_codes(stock_list)
    # 戻り値として返す為のリスト型の変数を定義
    selected_codes = []
    puts "[銘柄リスト]"
    print stock_list
    puts ""
    # 銘柄選択の繰り返し処理
    while true do
        puts "検証したい銘柄をリストから選択してください(全ての銘柄を選択する場合は『all』。選択を終了する場合は『q』)"
        selected_code = gets.chomp
        break if selected_code == "q"
        
        if selected_code ==  "all"
            selected_codes = stock_list
            break
        end
    
        unless stock_list.include?(selected_code)
            puts "[エラー]一致する銘柄がありません。正しい銘柄コードを入力してください"
            next
        end
        
        selected_codes.push(selected_code)
    end

    return selected_codes
end

#選択された銘柄それぞれに対して手法の検証をし、戻り値として銘柄名、銘柄別の全取引、全取引から算出した検証結果をハッシュ型で返すメソッド(※methodは関数をラップしたmethodオブジェクト)
def validation_for_selected_codes(method, selected_codes)
    data_result = {}
    selected_codes.each do |code|
        result = method.call(code)
        data_result[code] = result
    end 

    return data_result
end

#選択された銘柄全てに対して日付別でトレード結果を返すメソッド
def validation_for_date(method,selected_codes)
    # 日別,銘柄別のエントリー価格、決済価格、売買種別を格納する為のリストを定義
    trade_data = []

    data_result =  validation_for_selected_codes(method, selected_codes)
    selected_codes.each do |code|
        #全トレードの収支を変数に格納。この変数を使って資産推移データを作成。
        trades =  data_result[code][:trades]
        trades.each do |trade|
            # 日毎の銘柄データに銘柄コードを追加
            trade[:code] = code
            trade_data.push trade
        end
        #トレード結果を日付順でsort
        trade_data.sort!{|x,y| x[:date] <=> y[:date]}
    end
    #trade_dataに羅列されたリストを日付をキーにしたハッシュに変換
    result_group_by_date = trade_data.group_by{|v| v[:date]}
    return result_group_by_date
end

#その手法を実行した場合の日別利益シミュレーション
def daily_profit_for_method(method, selected_codes, assets, max_count)#assetsは一銘柄に投入する資金。総資産ではないことに注意
    daily_profit = {}
    daily_trades =  validation_for_date(method, selected_codes)
    daily_trades.each do |date, trades|
        #日別の合計損益
        daily_total_profit = 0
        #その日のエントリー銘柄数
        count = trades.count
        #一日の最大保有銘柄数
        max_count = max_count
        #その日のトレード収益
        trades.each do |trade|
            lot = assets*100/trade[:entry_price]
            if trade[:type] == "buy"
                profit = (trade[:exit_price]- trade[:entry_price])*lot/100.to_f #単位：万円なので100で割る
            else
                profit = (trade[:entry_price] - trade[:exit_price])*lot/100.to_f
            end
            daily_total_profit += profit
        end
    
        if count >= max_count
            profit_ave =  daily_total_profit/count.to_f
            daily_total_profit = profit_ave*max_count
        end
        daily_profit[date] = {count: count, total_profit: daily_total_profit}
    end

    return daily_profit
end

#その手法を実行した場合の資産シミュレーション(単利)
def simulation_for_assets(method, selected_codes, initial_assets, distribution)#distributionは一銘柄に投入する資金の割合。
    # 資産推移
    transition_for_assets = []
    max_count = distribution
    assets = initial_assets/distribution
    daily_profit = daily_profit_for_method(method, selected_codes, assets, max_count)
    daily_profit.each do |date,result|
        initial_assets += result[:total_profit]
        transition_for_assets.push [date, initial_assets]
    end

    return transition_for_assets
end
#その手法を実行した場合の資産シミュレーション(複利)

