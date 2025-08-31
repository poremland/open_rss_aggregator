#!/bin/bash

RSS_PID="$(ps -ef | grep puma | grep "open-rss-aggregator" | sed 's/[^0-9]*\([0-9]*\)\ .*/\1/g')"


if [ "$RSS_PID" == '' ]; then 
	echo "starting server"
	/usr/bin/env /usr/local/rvm/wrappers/ruby-3.4.4/ruby /YOUR/PATH/TO/open-rss-aggregator/script/rails s -e production -p 8778 -d
else
	echo "server already started"
fi

if [ "$1" == 'sync' ]; then
	/usr/bin/env /usr/local/rvm/wrappers/ruby-3.4.4/ruby /YOUR/PATH/TO/open-rss-aggregator/script/rails r -e production /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/sync_feeds_for_all_users.rb
	exit 1; 
fi 

if [ "$1" == 'purge' ]; then 
	/usr/bin/env /usr/local/rvm/wrappers/ruby-3.4.4/ruby /YOUR/PATH/TO/open-rss-aggregator/script/rails r -e production /YOUR/PATH/TO/open-rss-aggregator/lib/scripts/delete_older_feed_items.rb
	exit 1; 
fi
