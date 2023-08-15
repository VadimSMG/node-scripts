#!/bin/bash
echo "Input your hostname:"
read HOSTNAME
sudo hostnamectl set-hostname $HOSTNAME
curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=NRAK-JS2UER1PH7J8ZHYM7GC7TGQSO0M NEW_RELIC_ACCOUNT_ID=3693158 NEW_RELIC_REGION=EU /usr/local/bin/newrelic install
