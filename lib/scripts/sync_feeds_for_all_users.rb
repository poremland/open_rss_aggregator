# Copyright (C) 2025 Paul Oremland
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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