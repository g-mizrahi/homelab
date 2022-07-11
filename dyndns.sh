#!/bin/sh

# A script to automatically update the DNS record on Cloudflare
# Author G-Mizrahi
# Date 2022
# Source CloudFlare
# https://api.cloudflare.com/

# Architecture :
#
# Retreive server current public IP
# Retreive DNS A record for the target domain
# If different :
# 	- update DNS record

# Variables :
#
# Domain
domain="<-----domain----->"
#
# Clouflare variables
# Get the zone ID and API key from the Cloudflare dashboard
zone="<-----zone ID----->"
api_key="<-----API key----->"
#
# Logging variables
ip_log_path="/var/log/dyndns/public_ip.log"
err_log_path="/var/log/dyndns/dyndns.log"

# Get the DNS A record ID for the target domain from Cloudflare
# The record ID is needed to update the record
# CloudFlare documentation to read DNS record
# GET zones/:zone_identifier/dns_records/:identifier
# Example :
# curl -X GET "https://api.cloudflare.com/client/v4/zones/023e105f4ecef8ad9ca31a8372d0c353/dns_records/372e67954025e0ba6aaa6d586b9e0b59" \
#     -H "X-Auth-Email: user@example.com" \
#     -H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41" \
#     -H "Content-Type: application/json"
dns_record=$(curl --silent -X GET "https://api.cloudflare.com/client/v4/zones/$zone/dns_records?type=A&name=$domain" \
  -H "Authorization: Bearer $api_key" \
  -H "Content-Type: application/json")

dns_id=$(echo $dns_record | jq -r '.result[0].id')
dns_ip=$(echo $dns_record | jq -re '.result[0].content')

# If the request didn't return the expected format
# Log the error and exit the program
if [[ $? != "0" ]]; then
  echo {\"date\":\"$(date +%Y-%m-%dT%H:%M:%S)\", \"level\":\"error\", \"message\":\"$dns_record\"} >> $err_log_path
  exit 1
fi

# Get the current public IP address of the server
# ipify exposes a free public API
server_ip=$(curl --silent -X GET "https://api.ipify.org?format=json" | jq -er '.ip')

# If the request didn't return the expected format
# Log the error and exit the program
if [[ $? != "0" ]]; then
  echo {\"date\":\"$(date +%Y-%m-%dT%H:%M:%S)\", \"level\":\"error\", \"message\":\"Failed to get the server IP from ipify\"} | tee -a $err_log_path
  exit 1
else
  # Log the public IP
  # To keep track of how often the public IP of the server changes
  echo {\"date\":\"$(date +%Y-%m-%dT%H:%M:%S)\", \"ip\":\"$server_ip\"} | tee -a $ip_log_path
fi

# Check if the current IP matches the domain IP
if [[ "$dns_ip" != "$server_ip" ]]; then
  # Update the DNS record for the domain
  # CloudFlare documentation to update a DNS record
  # PUT zones/:zone_identifier/dns_records/:identifier
  # Change the TTL and Proxied values in the URL for specific configuration
  new_dns=$(curl --silent -X PUT "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$dns_id" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$domain\",\"content\":\"$server_ip\",\"ttl\":3600,\"proxied\":false}")

  success=$(echo $new_dns | jq -re ".success")

  # If the request didn't return the expected format
  # Log the error and exit the program
  if [[ "$success" != "true" ]]; then
    echo {\"date\":\"$(date +%Y-%m-%dT%H:%M:%S)\", \"level\":\"error\", \"message\":\"$new_dns\"} | tee -a $err_log_path
    exit 1
  elif [[ "$success" == "true" ]]; then
    echo {\"date\":\"$(date +%Y-%m-%dT%H:%M:%S)\", \"level\":\"debug\", \"message\":\"$new_dns\"} | tee -a $err_log_path
    exit 0
  fi
fi

exit 0
