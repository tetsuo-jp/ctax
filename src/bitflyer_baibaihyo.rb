## 売買表を作るスクリプト

#Usage: ruby bitflyer_baibaihyo.rb TradeHistory.csv >! bitflyer_baibaihyo.csv

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
  date = data[0]  # data["取引日時"] ではなぜか巧くいかない
  timezone = "+09:00"
  h["年月日時刻"] = Time.strptime("#{date}  #{timezone}", '%Y/%m/%d %H:%M:%S %z')

  next if ["入コイン","出コイン","手数料","出金","入金","証拠金引出","証拠金預入","受取","定期預入","定期払戻"].include?(data["取引種別"])

  if data["通貨"] != "BTC/JPY"
    puts "通貨エラー: #{data["通貨"]}, #{data["取引種別"]}"
    exit
  end

  if data["取引種別"] == "売り"
    h["売却通貨量"] = - data["BTC"].to_f
    h["売却通貨名"] = "BTC"
    h["購入通貨量"] = - data["BTC"].to_f * data["価格"].to_f
    h["購入通貨名"] = "JPY"
    h["手数料"] = data["手数料 (BTC)"]
    h["手数料の単位"] = "BTC"
  elsif data["取引種別"] == "買い"
    h["売却通貨量"] = data["BTC"].to_f * data["価格"].to_f
    h["売却通貨名"] = "JPY"
    h["購入通貨量"] = data["BTC"]
    h["購入通貨名"] = "BTC"
    h["手数料"] = data["手数料 (BTC)"]
    h["手数料の単位"] = "BTC"
  else
    puts "取引種別エラー: #{data["取引種別"]}"
    exit
  end

  puts "#{h["年月日時刻"]},bitflyer,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
