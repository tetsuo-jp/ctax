## 売買表を作るスクリプト

#Usage: ruby zaif_baibaihyo.rb trade_log.csv >! zaif_baibaihyo.csv

require 'csv'
# require 'date'   # time を使った方がいいらしい
require 'time'
require 'pp'

if ARGV[0].nil?
  puts "引数にファイルを指定して下さい"
  puts "Usage: ruby #{__FILE__} trade_log_2017.csv"
  exit
end

csv_data = CSV.read(ARGV[0], headers: true)

h = {}

puts "年月日時刻,取引所名,売却通貨量,売却通貨名,購入通貨量,購入通貨名,手数料,手数料の単位,注文id"
csv_data.each do |data|
  date = data["日時"]
  timezone = "+09:00"
  h["年月日刻時"] = Time.strptime("#{date} #{timezone}", '%Y-%m-%d %H:%M:%S.%N %z')

  if data["取引種別"] == "売り"
    /^(\w*)_(\w*)$/.match(data["マーケット"])
    h["売却通貨量"] = data["数量"]
    h["売却通貨名"] = $1.upcase # BTC
    h["購入通貨量"] = data["価格"].to_f * data["数量"].to_f
    h["購入通貨名"] = $2.upcase # JPY
  elsif data["取引種別"] == "買い"
    /^(\w*)_(\w*)$/.match(data["マーケット"])
    h["売却通貨量"] = data["価格"].to_f * data["数量"].to_f
    h["売却通貨名"] = $2.upcase
    h["購入通貨量"] = data["数量"]
    h["購入通貨名"] = $1.upcase
  elsif data["取引種別"] == "自己"
    # 飛ばします
  else
    puts "エラー: #{data["取引種別"]}"
    exit
  end

  h["手数料"] = data["取引手数料"]
  h["手数料の単位"] = "JPY"

  puts "#{h["年月日刻時"]},Zaif,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]}"
end
