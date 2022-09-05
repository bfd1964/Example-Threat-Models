##!/usr/bin/env bash
#
# Pull a list of projects from an Instance
#
# Script use
#
# -u instance name (does not require the iriusrisk.com domain)
#
# This script uses the jq json processing command line reference https://stedolan.github.io/jq/

apitoken="use your own token";
projectsfile="./projects.json"
linecount=0

function process_json() {
  echo "$linecount: $1"
}

while getopts u: flag
do
    case "${flag}" in
        u) instance=${OPTARG};;
    esac
done

#
# Connection Details
#####
instance_url="https://${instance}.iriusrisk.com";
api_url="${instance_url}/api/v1/products/";
token_header="api-token: ${apitoken}"

echo "Instance: $instance";
echo "Instance URL: $instance_url";
echo "API URL: $api_url";
echo "Token Header: $token_header";

#
# Pull list of Projects, and use jq to pretty print the json into a file for processing
#####
curl -vvv --silent --location --request GET "$api_url" \
--header 'Accept: application/json' \
--header "$token_header" \
| jq '.[] | {Name: .name, Referemce: .ref}' > "$projectsfile"

#
# Read the pretty printed json and format Output, and do what you will with the results
#####

while IFS= read -r line
do
  ((linecount++))
  process_json "$line"
done < "$projectsfile"
