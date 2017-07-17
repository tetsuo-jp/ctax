## 売買表を作るスクリプト

#Usage: ruby kraken_baibaihyo.rb history.csv >! kraken_baibaihyo.csv

require 'csv'
# require 'date'   # time を使った方がいいらしい
require 'time'
require 'pp'

def get_cur_name(name)
  curs = {
    "XXBT" => "BTC",
    "ZEUR" => "EUR",
    "ZJPY" => "JPY",
    "XETH" => "ETH",
    "XDAO" => "DAO",
    "XREP" => "REP",
    "XLTC" => "LTC",
  }
  unless curs.key?(name)
    puts "通貨名のエラー: #{name}"
    exit
  end
  return curs[name]
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
  date = data["time"]
  h["年月日刻時"] = Time.strptime("#{date}", '%Y-%m-%d %H:%M:%S.%N').getlocal

  if data["type"] == "sell"
    h["売却通貨量"] = data["vol"]
    h["売却通貨名"] = get_cur_name(data["pair"][0..3])
    h["購入通貨量"] = data["cost"]
    h["購入通貨名"] = get_cur_name(data["pair"][4..7])
    h["手数料"] = data["fee"]
    h["手数料の単位"] = get_cur_name(data["pair"][4..7])
  elsif data["type"] == "buy"
    h["売却通貨量"] = data["cost"]
    h["売却通貨名"] = get_cur_name(data["pair"][4..7])
    h["購入通貨量"] = data["vol"]
    h["購入通貨名"] = get_cur_name(data["pair"][0..3])
    h["手数料"] = data["fee"]
    h["手数料の単位"] = get_cur_name(data["pair"][4..7])
  else
    puts "取引種別エラー: #{data["取引種別"]}"
    exit
  end

  h["注文id"] = data["txid"]

  puts "#{h["年月日刻時"]},Kraken,#{h["売却通貨量"]},#{h["売却通貨名"]},#{h["購入通貨量"]},#{h["購入通貨名"]},#{h["手数料"]},#{h["手数料の単位"]},#{h["注文id"]}"
end
