## 売買表を作るスクリプト

#Usage: ruby bittrex_baibaihyo.rb fullOrders_tmp.csv >! bittrex_baibaihyo_2017.csv

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
  date = data["Closed"]
  timezone = "+09:00"
  h["年月日時刻"] = Time.strptime("#{date} UTC", '%e/%d/%Y %I:%M:%S %p %z').getlocal

  /(\w+)\-(\w+)/.match(data["Exchange"])
  from = $1
  to = $2

  if data["Type"] == "LIMIT_SELL"
    h["売却通貨量"] = data["Quantity"].to_f
    h["売却通貨名"] = from
    h["購入通貨量"] = data["Limit"].to_f
    h["購入通貨名"] = to
    h["手数料"] = data["CommissionPaid"]
    h["手数料の単位"] = to
  elsif data["Type"] == "LIMIT_BUY"
    h["売却通貨量"] = data["Quantity"].to_f
    h["売却通貨名"] = to
    h["購入通貨量"] = data["Limit"].to_f
    h["購入通貨名"] = from
    h["手数料"] = data["CommissionPaid"]
    h["手数料の単位"] = from
  else
    puts "取引種別エラー: #{data["Type"]}"
    exit
  end

  puts "#{h["年月日時刻"]},bitflyer,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
