## 売買表を作るスクリプト

#Usage: ruby coincheck_baibaihyo.rb history.csv >! coincheck_baibaihyo.csv

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
  h["年月日時刻"] = Time.strptime("#{date} JST", '%Y-%m-%d %H:%M:%S %z').getlocal

  if data["Type"] == "sell"
    if data["BTC"][0] != "-"
      puts "先頭がマイナスではありません．#{data["BTC"]}"
      exit
    end
    h["売却通貨量"] = data["BTC"][1..-1]
    h["売却通貨名"] = "BTC"
    h["購入通貨量"] = data["JPY"]
    h["購入通貨名"] = "JPY"
  elsif data["Type"] == "buy"
    if data["JPY"][0] != "-"
      puts "先頭がマイナスではありません．#{data["JPY"]}"
      exit
    end
    h["売却通貨量"] = data["JPY"][1..-1]
    h["売却通貨名"] = "JPY"
    h["購入通貨量"] = data["BTC"]
    h["購入通貨名"] = "BTC"
  else
    puts "取引種別エラー: #{data["Type"]}"
    exit
  end

  h["手数料"] = data["Fee"]
  h["手数料の単位"] = "JPY"

  puts "#{h["年月日時刻"]},coincheck,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
