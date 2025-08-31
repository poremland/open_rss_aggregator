#`source /usr/local/rvm/environments/ruby-1.9.2-p320`

class SyncFeedsForAllUsers < ActiveRecord::Base
	feeds = Feed.all.sort {|x,y| x.user <=> y.user}
	number_of_feeds = feeds.count
	start_time = Time.now
	puts Time.now

	Parallel.each(feeds) do |feed|
		::ActiveRecord::Base.establish_connection
		begin
			old_unread = feed.feed_items.size
			feed.update_feed_items
			new_unread = feed.feed_items.size - old_unread
			puts "#{new_unread} new feed items in #{feed.name} for #{feed.user}"
		rescue => e
                  puts "Error updating feed #{feed.id} #{feed.name} for #{feed.user}: #{e}"
		end
	end
	end_time = Time.now
	puts "Updated #{number_of_feeds} feeds in #{end_time - start_time} seconds"
end
