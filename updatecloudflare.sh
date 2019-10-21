#!/bin/bash
#June 3, 2019
#By Robert John Canare

####################required input################
website="yourwebsite.com"
record_name="yourrecord_name"
##################################################

api_key="your API global keys"
email="youremail@email.com"
from_email="fromemail@email.com"
smtp="smtp"

#declare variable that needed on curl requests, maka sure A record is first record
zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$website" -H "X-Auth-Email: $email" -H "X-Auth-Key: $api_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1
)
record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$website" -H "X-Auth-Email: $email" -H "X-Auth-Key: $api_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1
)

#IP's
current_ip=$(curl -s http://ipv4.icanhazip.com)
current_zone_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier"  -H "X-Auth-Email: $email" -H "X-Auth-Key: $api_key" -H "Content-Type: application/json" | grep -Po '(?<="content":")[^"]*' | head -1)


if [[ $current_ip != $current_zone_ip  ]]; then
	curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier"  -H "X-Auth-Email: $email" -H "X-Auth-Key: $api_key" -H "Content-Type: application/json"  --data '{"type":"A","name":"'$website'","content":"'$current_ip'","proxied":true}'
	echo "Updating " $website " Dynamic DNS."| mailx -v -r $from_email -s "Updating CloudFlare DNS records" -S smtp="smtp" -S ssl-verify=ignore $email
else
	echo "IP for " $website " is not changed yet."| mailx -v -r $from_email -s "It's still the same IP" -S smtp="smtp" -S ssl-verify=ignore $email
fi
