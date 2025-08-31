#`source /usr/local/rvm/environments/ruby-1.9.2-p320`

class DeleteOlderFeedItems < ActiveRecord::Base
	FeedItem.where("timestamp < '#{Date.today - 365}' AND favorite=0").delete_all
end
