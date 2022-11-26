#!/bin/bash

client_id=""
secret=""

function getToken() {
  tokens=$(curl -s -X POST -u "$client_id":"$secret" \
    https://bitbucket.org/site/oauth2/access_token \
    -d grant_type=refresh_token -d refresh_token=$(cat token.json | ./jq '.refresh_token' | tr -d '"'))
  echo "$tokens"
  echo "$tokens" >token.json
}

function approve() {
  curl --request POST \
    --url "https://api.bitbucket.org/2.0/repositories/${1}/${2}/pullrequests/${3}/approve" \
    --header "Authorization: Bearer $(cat token.json | ./jq '.access_token' | tr -d '\"')" \
    --header 'Accept: application/json'
}

function request-changes() {
  curl --request POST \
    --url "https://api.bitbucket.org/2.0/repositories/${1}/${2}/pullrequests/${3}/request-changes" \
    --header "Authorization: Bearer $(cat token.json | ./jq '.access_token' | tr -d '\"')" \
    --header 'Accept: application/json'
}

function comment() {
  curl --request POST \
    --url "https://api.bitbucket.org/2.0/repositories/${1}/${2}/pullrequests/${3}/comments" \
    --header "Authorization: Bearer $(cat token.json | ./jq '.access_token' | tr -d '\"')" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --data "{
	  \"content\": {
	    \"raw\": \"${4}\"
	  }
	}"
}

if [[ $1 == "--action" ]]; then
  getToken

  if [ "$2" = "approve" ] && [ "$3" = "--workspace" ] && [ "$5" = "--repo" ] && [ "$7" = "--id" ]; then
    approve "$4" "$6" "$8"
  fi

  if [ "$2" = "request-changes" ] && [ "$3" = "--workspace" ] && [ "$5" = "--repo" ] && [ "$7" = "--id" ]; then
    request-changes "$4" "$6" "$8"
  fi

  if [ "$2" = "comment" ] && [ "$3" = "--workspace" ] && [ "$5" = "--repo" ] && [ "$7" = "--id" ] && [ "$9" = "--text" ]; then
    comment "$4" "$6" "$8" "${10}"
  fi

fi

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
  echo "
[+] Approve.
 --action approve --workspace {workspace} --repo {repasitory} --id {pull_request_id}
	
[+] Request Changes.
 --action request-changes --workspace {workspace} --repo {repasitory} --id {pull_request_id}
	
[+] Comment.
 --action comment --workspace {workspace} --repo {repasitory} --id {pull_request_id} --text {\"your_text_here\"}

"
fi
