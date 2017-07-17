cat bitflyer.csv zaif.csv | sort -u > all_baibaihyo.csv
gsed -i '1i年月日時刻,取引所名,売却通貨量,売却通貨名,購入通貨量,購入通貨名,手数料,手数料の単位,注文id' all_baibaihyo.csv
gsed -i '$d' all_baibaihyo.csv
