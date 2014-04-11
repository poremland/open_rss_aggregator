#`source /usr/local/rvm/environments/ruby-1.9.2-p320`

class DeleteOlderFeedItems < ActiveRecord::Base
	FeedItem.where("timestamp < '#{Date.today - 1825}'").delete_all
end
