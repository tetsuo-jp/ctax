## 売買表を作るスクリプト

#Usage: ruby btcbox_baibaihyo.rb trade_list.csv >! btcbox_baibaihyo.csv

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
  date = data["約定日時"]
  /(\d+)-(\d+)-(\d+) (\d+):(\d+)/.match(date)
  date2 = "#{$1}-#{fill($2)}-#{fill($3)} #{fill($4)}:#{fill($5)}"
  h["年月日時刻"] = Time.strptime("#{date2}", '%Y-%m-%d %k:%M').getlocal

  if data["買／売"] == "売却"
    h["売却通貨量"] = data["約定数量"]
    h["売却通貨名"] = "BTC"
    h["購入通貨量"] = data["約定金額"]
    h["購入通貨名"] = "JPY"
    h["手数料"] = data["手数料"]
    h["手数料の単位"] = "JPY"
  elsif data["買／売"] == "購入"
    h["売却通貨量"] = data["約定金額"]
    h["売却通貨名"] = "JPY"
    h["購入通貨量"] = data["約定数量"]
    h["購入通貨名"] = "BTC"
    if data["手数料"] == "0 BTC" || data["手数料"] == "0"
      h["手数料"] = "0"
      h["手数料の単位"] = "BTC"
    else
      puts "手数料のエラー: _#{h["手数料"]}_"
    end
  else
    puts "取引種別エラー: #{data["買／売"]}"
    exit
  end


  puts "#{h["年月日時刻"]},btcbox,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
