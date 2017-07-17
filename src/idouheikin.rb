# 移動平均法で利益を計算をする

# Usage: ruby idouheikin.rb all_baibaihyo.csv

require 'csv'
# require 'date'   # time を使った方がいいらしい
require 'time'
require 'pp'
require 'bigdecimal'

if ARGV[0].nil?
  puts "引数にファイルを指定して下さい"
  puts "Usage: ruby #{__FILE__} AAA.csv"
  exit
end

csv_data = CSV.read(ARGV[0], headers: true)

# 年初の残高と購入単価
z =
{"JPY_FEE"=>0,
 "JPY"=>{"数量"=>0.0, "単価"=>1.0},
 "BTC"=>
  {"数量"=>0.5,
   "単価"=>100000.0,
   "最小数量"=>0.5},
 "ETH"=>{"数量"=>0.0, "単価"=>0.0},
 "MONA"=>{"数量"=>0.0, "単価"=>0.0},
 "DAO"=>{"数量"=>0.0, "単価"=>0.0},
 "XEM"=>{"数量"=>0.0, "単価"=>0.0},
 "XRP"=>{"数量"=>0.0, "単価"=>0.0},
 "REP"=>{"数量"=>0.0, "単価"=>0.0},
 "LTC"=>{"数量"=>0.0, "単価"=>0.0},
 "XCP"=>{"数量"=>0.0, "単価"=>0.0},
}
profit = 0

csv_data.each do |d|
  unless z.key?(d["購入通貨名"])
    puts "#{d["購入通貨名"]} という通貨は実装されていません．(0)"
    pp d
    exit
  end
  unless z.key?(d["購入通貨名"])
    puts "#{d["購入通貨名"]} という通貨は実装されていません(1)．"
    pp d
    exit
  end
  unless z.key?(d["売却通貨名"])
    puts "#{d["売却通貨名"]} という通貨は実装されていません(2)．"
    pp d
    exit
  end
  if z[d["購入通貨名"]]["単価"] < -0.000001
    puts "購入単価が負なので，異常です．"
    exit
  end

  if d["購入通貨名"] == "JPY" && d["売却通貨名"] == "BTC"
    diff = d["購入通貨量"].to_f - z[d["売却通貨名"]]["単価"] * d["売却通貨量"].to_f # 例. BTCを売却してJPYを得る場合は，JPYの売却通貨量 - BTCの単価 * 数量
    profit += diff
  end
  konyu_cur_amount = [z[d["購入通貨名"]]["数量"],0].max
  z[d["購入通貨名"]]["単価"] = (z[d["購入通貨名"]]["単価"] * konyu_cur_amount + d["売却通貨量"].to_f * z[d["売却通貨名"]]["単価"]) / (konyu_cur_amount + d["購入通貨量"].to_f)
  if d["購入通貨量"].to_f < 0 || d["売却通貨量"].to_f < 0
    puts "負の通貨量です"
    exit
  end
  z[d["購入通貨名"]]["数量"] += d["購入通貨量"].to_f
  z[d["売却通貨名"]]["数量"] -= d["売却通貨量"].to_f

  z["BTC"]["最小数量"] = [z["BTC"]["最小数量"],z["BTC"]["数量"]].min # 最小BTC数量の更新
  # puts "#{d["年月日時刻"]}, 1BTC=#{z["BTC"]["単価"]}, 量=#{z["BTC"]["数量"]}, 最小数量=#{z["BTC"]["最小数量"]}"

  z["JPY"]["単価"] = 1.0        # JPYの単価は常に1になる

  # 手数料の計算
  if d["手数料の単位"] == "JPY"
    z["JPY_FEE"] -= d["手数料"].to_f
  elsif d["手数料の単位"] == "USD"
    z["USD_FEE"] -= d["手数料"].to_f
  else
    # puts d["手数料の単位"]
    z[d["手数料の単位"]]["数量"] -= d["手数料"].to_f
  end

  if z["BTC"]["単価"] > 400_0000 || z["BTC"]["単価"] < 0
    puts "異常なBTCの単価です: #{z["BTC"]["単価"]}"
    exit
  end
end

pp z
puts "利益: #{profit}"
