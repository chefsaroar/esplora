#!/bin/bash
set -e

source="$1"
dest="$2"

curl -s $source/mempool/txids | jq -r .[] | sort - > tx_ids_src.txt
curl -s $dest/mempool/txids | jq -r .[] | sort - > tx_ids_dest.txt

wc -l tx_ids_src.txt
wc -l tx_ids_dest.txt

comm -23 tx_ids_src.txt tx_ids_dest.txt > tx_ids_res.txt

wc -l tx_ids_res.txt

shuf tx_ids_res.txt > tx_ids_rnd.txt

cat tx_ids_rnd.txt | while read txid; do
  echo pushing $txid
  curl -s $dest/tx -d @- & <<TXHEX
$(curl -s $source/tx/$txid/hex)
TXHEX
  pids[${i}]=$!
  echo
done

for pid in ${pids[*]}; do
  wait $pid
done

echo "All done"
