#! /bin/bash

main(){
	if [ ! -f "$domains" ];then
		echo "file not found: $domains"
		exit 1
	fi
	# run subfinder
	mkdir subdomains
	subfinder -dL $domains -silent | anew "./subdomains/$output"
	while IFS= read -r line; do
		# run sublist3r
		python3 /home/hunter/tools/Turbolist3r/turbolist3r.py -d $line -q -o "./subdomains/$line.txt"
		cat "./subdomains/$line.txt" | anew "./subdomains/$output"
		# run github subdomain extractor
		github-subdomains -d $line -t $token -raw -k -q | anew "./subdomains/$output"
		rm -rf "$line.txt"
		rm -rf "./subdomains/$line.txt"	
	done < "$domains"
	
	echo "total subdomains found: `cat './subdomains/'$output | wc -l`"
}
usage(){
	echo "Usage: $0 -h <help> -t <github token> -i <domains.txt> -o <output.txt> -n <discord token for notify>"
	exit 1
}


ARGS=$(getopt -o t:i:o:n:h: -- "$@")

if [ $? -ne 0 ]; then
	usage
fi

eval set -- "$ARGS"

token=""
domains=""
output=""
notify=""
while true; do
	case "$1" in
		-t)
			token=$2
			shift 2
			;;
		-i)
			domains=$2
			shift 2
			;;
		-o)
			output=$2
			shift 2
			;;
		-n)
			notify=$2
			shift 2 
			;;
		-h)
			usage
			shift
			break
			;;
		--)
			shift
			break
			;;
	esac
done
if [ -z "$token" ] || [ -z "$domains" ] || [ -z "$output" ]; then
	usage
fi
main
