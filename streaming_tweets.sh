#!/bin/bash
#
# Get the latest tweets from your account.
#
# This script is based on a solution proposed by Mike Bounds
#  in the twitter discussion forum: https://dev.twitter.com/discussions/14460

set -o errexit

filters=modi # any words that you want to filter from tweet
consumer_key=YOUR_CONSUMER_KEY
consumer_secret=YOUR_CONSUMER_SECRET
oauth_token=YOUR_AUTH_TOKEN
oauth_secret=YOUR_AUTH_SECRET

timestamp=`date +%s`
nonce=`date +%s%T555555555 | openssl base64 | sed -e s'/[+=/]//g'`

signature_base_string="GET&https%3A%2F%2Fstream.twitter.com%2F1.1%2Fstatuses%2Ffilter.json&oauth_consumer_key%3D${consumer_key}%26oauth_nonce%3D${nonce}%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D${timestamp}%26oauth_token%3D${oauth_token}%26oauth_version%3D1.0%26track%3D${filters}"


signature_key="${consumer_secret}&${oauth_secret}"
oauth_signature=`echo -n ${signature_base_string} | openssl dgst -sha1 -hmac ${signature_key} -binary | openssl base64 | sed -e s'/+/%2B/' -e s'/\//%2F/' -e s'/=/%3D/'`
echo "${oauth_signature}"

header="Authorization: OAuth oauth_consumer_key=\"${consumer_key}\", oauth_nonce=\"${nonce}\", oauth_signature=\"${oauth_signature}\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"${timestamp}\", oauth_token=\"${oauth_token}\", oauth_version=\"1.0\""


result=`curl --get 'https://stream.twitter.com/1.1/statuses/filter.json' --data "track=${filters}" --header "${header}" --verbose | nc -lk 9999`

echo "${result}"
