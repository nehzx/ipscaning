#!/bin/bash

processing_results() {
	result=$(sed 's/.*0.00$//g' result.csv | sed '/^[  ]*$/d' | sed -n '2,100p')
	for item in ${result[*]}; do
		arr=(${item//,/ })

		curl "$FEISHU_WEB_HOOK" -X POST -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"IP Address '${arr[0]}' ping:'${arr[4]}' ms speed:'${arr[5]}' mb/s"}}'
	done
}

if [[ -z $AS ]]; then

	./CloudflareSpeedTest -tl 200  -dn 30

	if [ -z $FEISHU_WEB_HOOK ]; then
		echo "web hook url null"
	else
		processing_results
	fi
	
	exit 0
fi

as_arr=(${AS//,/ })
for ASN in ${as_arr[*]}; do

	IP_File=$ASN.txt

	curl https://whois.ipip.net/$ASN | grep "/$ASN/" | grep -v "IPv6" | sed 's/<[^>]*.//g' | sed 's/ //g' | sed '/^[  ]*$/d' >$IP_File

	./CloudflareSpeedTest -tl 200 -allip -f $IP_File -dn 10000

	if [ -z $FEISHU_WEB_HOOK ]; then
		echo "web hook url null"
	else
		processing_results
	fi

	rm -rf $IP_File
done
