## 貸借に関して売買表を作るスクリプト

#Usage: ruby coincheck_borrow_baibaihyo.rb borrowing-histories.csv >! coincheck_borrow_baibaihyo.csv

require 'csv'
# require 'date'   # time を使った方がいいらしい
require 'time'
require 'pp'

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
  h["年月日時刻"] = Time.strptime("#{date}", '%Y-%m-%d %H:%M:%S %Z').getlocal

  h["売却通貨量"] = 0
  h["売却通貨名"] = "JPY"
  h["購入通貨量"] = 0
  h["購入通貨名"] = "BTC"
  h["手数料"] = data["AmountRepaid"].to_f - data["Amount"].to_f
  h["手数料の単位"] = data["Currency"]

  puts "#{h["年月日時刻"]},coincheck,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},"
end
