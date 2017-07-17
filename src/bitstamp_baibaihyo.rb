## 売買表を作るスクリプト

#Usage: ruby bitstamp_baibaihyo.rb history.csv >! bitstamp_baibaihyo.csv

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
  if data["Type"] == "Deposit" || data["Type"] == "Withdrawal"
    next
  end
  date = data["Datetime"]
  timezone = "UTC"
  h["年月日時刻"] = Time.strptime("#{date} #{timezone}", '%b. %d, %Y, %I:%M %p %Z').getlocal

  if data["Sub Type"] == "Sell"
    h["売却通貨量"] = data["Amount"][0..-5]
    h["売却通貨名"] = data["Amount"][-3..-1] # BTC
    h["購入通貨量"] = data["Value"][0..-5]
    h["購入通貨名"] = data["Value"][-3..-1] # USD
    if data["Fee"].nil?
      h["手数料"] = 0
      h["手数料の単位"] = "USD"
    else
      h["手数料"] = data["Fee"][0..-5]
      h["手数料の単位"] = data["Fee"][-3..-1]
    end
  elsif data["Sub Type"] == "Buy"
    h["売却通貨量"] = data["Value"][0..-5]
    h["売却通貨名"] = data["Value"][-3..-1] # USD
    h["購入通貨量"] = data["Amount"][0..-5]
    h["購入通貨名"] = data["Amount"][-3..-1] # BTC
    if data["Fee"].nil?
      h["手数料"] = 0
      h["手数料の単位"] = "USD"
    else
      h["手数料"] = data["Fee"][0..-5]
      h["手数料の単位"] = data["Fee"][-3..-1]
    end
  else
    puts "取引種別エラー: #{data["Sub Type"]}"
    exit
  end

  puts "#{h["年月日時刻"]},bitstamp,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
