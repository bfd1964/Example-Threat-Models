##!/usr/bin/env bash
#
# Pull a list of projects from an Instance,
# generate a list of reference IDs for projects which can then be used to seed other API calls
#
# Script use
#
# -u instance name (does not require the iriusrisk.com domain)
#
# This script uses the jq json processing command line reference https://stedolan.github.io/jq/

apitoken=d6e2d270-35ab-4621-b63d-29ca18b73828;
projectsfile="./projects.json";

function process_json_for_projects() {
  #Strip double quotes from the content
  line=$(sed 's/\"//g' <<< $1);
  #split the line at the delimiter
  IFS=': ' read -r name value <<< "$line";
  if [[ "$name" == "Reference" ]]
  then
    #Output the value of the reference id from the json
    echo "$value"
  fi
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
| jq '.[] | {Name: .name, Reference: .ref}' > "$projectsfile"

#
# Read the pretty printed json and format Output, and do what you will with the results
#####

while IFS= read -r line
do
  process_json_for_projects "$line"
done < "$projectsfile"
