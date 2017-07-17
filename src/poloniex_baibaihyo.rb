## 売買表を作るスクリプト

#Usage: ruby poloniex_baibaihyo.rb tradeHistory.csv >! poloniex_baibaihyo.csv

require 'csv'
# require 'date'   # time を使った方がいいらしい
require 'time'
require 'pp'


def fill(x)
  if x.to_i <= 9
    "0#{x}"
  else
    x
  end
end

if ARGV[0].nil?
  puts "引数にファイルを指定して下さい"
  puts "Usage: ruby #{__FILE__} AAA.csv"
  exit
end

csv_data = CSV.read(ARGV[0], headers: true)

h = {}

puts "年月日時刻,取引所名,売却通貨量,売却通貨名,購入通貨量,購入通貨名,手数料,手数料の単位,注文id"
csv_data.each do |data|
  date = data["Date"]
  h["年月日時刻"] = Time.strptime("#{date} UTC", '%Y-%m-%d %H:%M:%S %z').getlocal

  if data["Type"] == "Sell"
    h["売却通貨量"] = data["Amount"]
    h["売却通貨名"] = data["Market"][0..2]
    h["購入通貨量"] = data["Base Total Less Fee"].to_f
    h["購入通貨名"] = data["Market"][-3..-1]
    h["手数料"] = 0.0 # data["Total"].to_f - data["Base Total Less Fee"].to_f  # 手数料を差し引いた額を売却量としている
    h["手数料の単位"] = data["Market"][-3..-1]
  elsif data["Type"] == "Buy"
    h["売却通貨量"] = data["Total"]
    h["売却通貨名"] = data["Market"][-3..-1]
    h["購入通貨量"] = data["Quote Total Less Fee"]
    h["購入通貨名"] = data["Market"][0..2]
    h["手数料"] = 0.0  # data["Amount"].to_f - data["Quote Total Less Fee"].to_f  # 手数料を差し引いた額を購入量としている
    h["手数料の単位"] = data["Market"][-3..-1]
  else
    puts "取引種別エラー: #{data["Type"]}"
    exit
  end
  h["注文id"] = data["Order Number"]

  puts "#{h["年月日時刻"]},poloniex,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
