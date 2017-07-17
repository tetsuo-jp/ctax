## 売買表を作るスクリプト

#Usage: ruby quoine_baibaihyo.rb history.csv >! quoine_baibaihyo.csv

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
  date = data["Date"]
  h["年月日刻時"] = Time.strptime("#{date}", '%Y-%m-%d %H:%M:%S %Z').getlocal

  if data["Type"] == "Sold"
    h["売却通貨量"] = data["Qty"]
    h["売却通貨名"] = data["Crypto"]
    h["購入通貨量"] = data["Amount"]
    h["購入通貨名"] = data["Currency"]
  elsif data["Type"] == "Bought"
    h["売却通貨量"] = data["Amount"]
    h["売却通貨名"] = data["Currency"]
    h["購入通貨量"] = data["Qty"]
    h["購入通貨名"] = data["Crypto"]
  elsif data["Type"] == ""      # 空文字列は自己売買を表しているものと思われるので、とばす
    next
  else
    puts "エラー: #{data["取引種別"]}"
    exit
  end

  h["手数料"] = data["Fee"]
  h["手数料の単位"] = "JPY"
  h["注文id"] = data["Execution Id"]

  puts "#{h["年月日刻時"]},Quoine,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
