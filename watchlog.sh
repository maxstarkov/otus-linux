#!/bin/bash

settings=/opt/watchlog/settings
lockfile=/opt/watchlog/lockfile

PROGNAME=$(basename $0)

parse_logfile() {

	grep -Po '.*".+?"\s+\d+' $2 \
        | awk -v start_date=$(date -d "$1" +[%d/%b/%Y:%H:%M:%S) \
        '$4 > start_date {arr["ip"][$1]+=1; arr["url"][$7]+=1; arr["code"][$NF]+=1; if($NF !~ /2[0-9]+|3[0-9]+/) {arr["error"][$0]+=1}}\
        END {for (i in arr["ip"]) {print "IP " arr["ip"][i] " " i}; \
	for (i in arr["url"]) {print "URL " arr["url"][i] " " i};
	for (i in arr["error"]) {print "ERROR " arr["error"][i] " " i};
	for (i in arr["code"]) {print "CODE " arr["code"][i] " " i}}'

}

get_message_text() {

	echo "Watchlog report."
        echo ""
	echo "Log file: $3"
	echo "Start date: $start_date; End date: $end_date"
        echo ""
	echo "Top-$1 access ip-adress: count, ip"
        echo
	echo "$4" | awk '/^IP/ {print "  " $2 " " $3}' | sort -rnb | head -n $1
        echo ""
	echo "Top-$2 access url: count, url"
        echo ""
	echo "$4" | awk '/^URL/ {print " " $2 " " $3}' | sort -rnb | head -n $2
        echo ""
	echo "All http error: count, request"
	echo ""
        echo "$4" | awk '/^ERROR/ {$1=""; print " " $0}'
        echo ""
	echo "All http return codes: count, code"
        echo ""
	echo "$4" | awk '/^CODE/ {print " " $2 " " $3}' | sort -rnb

}

run() {

	if [ -e $settings ]
	then
		start_date=$(date -f $settings)
	else
		start_date=$(date -d 'now-24 hours')
	fi

	end_date=$(date)

	log_info=$(parse_logfile "$start_date" $3)

	echo "$(get_message_text $1 $2 $3 "$log_info")"	

	echo "$end_date" > $settings

}

usage() {

	echo "$PROGNAME: usage: $PROGNAME topIP topURL logfile
	- topIP: number of IP to output to the report,
	- topURL: number of URL to output to the report,
	- logfile: path to the log file for processing."

}

check_param() {

        if [[ $# -ne 3 ]]
        then
                usage >&2
                exit 1
        elif [[ $1 -le 0 ]]
        then
                echo "number of IP to output to the report must be greater than zero"
                usage >&2
                exit 2
        elif [[ $2 -le 0 ]]
        then
                echo "number of URL to output to the report must be greater than zero"
                usage >&2
                exit 2
        elif [[ ! -e $3 ]]
        then
                echo "log file must be exist"
                usage >&2
                exit 3
        fi

}

main() {

	check_param $1 $2 $3

	if ( set -o noclobber; echo "$$" > "$lockfile") 2>/dev/null;
	then
		trap 'rm -f "$lockfile"; exit $?' EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR
		
		echo "$(run $1 $2 $3)" | mail -s "Wachlog" vagrant@localhost
		
		rm -f "$lockfile"
		trap - EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR
	else
		echo "Failed to acquire lockfile: $lockfile"
		echo "Held by $(cat $lockfile)"
	fi
}

main $1 $2 $3
