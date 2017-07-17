all:

test:
	mkdir -p tmp/
	ruby src/bitflyer_baibaihyo.rb sample/TradeHistory.csv > tmp/bitflyer.csv
	ruby src/zaif_baibaihyo.rb     sample/trade_log.csv    > tmp/zaif.csv
	(cd tmp; sh ../sample/merge.sh; ruby ../src/idouheikin.rb all_baibaihyo.csv)

clean:
	rm -rf tmp/
