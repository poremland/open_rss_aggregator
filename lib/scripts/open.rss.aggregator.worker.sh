#!/bin/sh

source "/etc/profile.d/rvm.sh" 

if [ $1 == 'sync' ]; then
	/usr/bin/env /usr/local/rvm/wrappers/ruby-1.9.3-p392/ruby /YOUR/PATH/TO/open-rss-aggregator/script/rails r -e production /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/sync_feeds_for_all_users.rb > /var/log/httpd/open.rss.aggregator.cron.log 
	exit 1; 
fi 

if [ $1 == 'purge' ]; then 
	/usr/bin/env /usr/local/rvm/wrappers/ruby-1.9.3-p392/ruby /YOUR/PATH/TO/open-rss-aggregator/script/rails r -e production /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/scripts/delete_older_feed_items.rb > /var/log/httpd/open.rss.aggregator.cron.log
	exit 1; 
fi
