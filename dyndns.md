# Dynamic DNS with Cloudflare

The goal is to update the DNS records for a domain regularly to emulate a dynamic DNS from the CLI.

## Cloudflare API keys

- Create an account and register a domain on [Cloudflare](https://cloudflare.com).
- Create an API token to modify DNS records on the [dashboard](https://dash.cloudflare.com/profile/api-tokens).
- Retrieve the zone ID on the general dashboard for the domain.

## Setup

- Insert the API token and zone ID as well as the domain in the script.
- By default the script will try to write logs to a directory `/var/log/dyndns`. This directory needs to exist and have acceptable permissions (for example `chown user:user /var/log/dyndns`) so that the script can write to it.
- Because a dedicated DNS token is used there is no need to provide the email address.
- Be carefull not to commit the API key to any public repository as it could be used to highjack the DNS records for the domain.

## Run with crontab

- To run the DNS update every day use `crontab -e` and write the following :
```
0 0 * * * /bin/bash /home/user/dyndns.sh
```
- Make sure the script is in a directory where it can be read by the user.
