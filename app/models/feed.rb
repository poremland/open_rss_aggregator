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

class Feed < ApplicationRecord
	has_many :feed_items,
		:inverse_of => :feed,
		:foreign_key => :feed_id, 
		:dependent => :destroy

	def update_feed_items
		begin
			xml = HTTParty.get(self.uri).body
			rss = Feedjira.parse(xml)
		rescue => e
			puts "Error updating feed items for feed: #{self.uri}. #{e.message}"
			return
		end

		if(rss.entries.nil? || rss.entries.empty?)
			puts "Error updating feed items for feed: #{self.uri}. Unable to fetch and parse #{self.uri}"
			return
		end

		rss.entries.each do |item|
			begin
				date = get_date(item)
				hash_key = get_hash_key(item, date)
				count = FeedItem.where(key: hash_key, feed_id: self.id).count
				count += FeedItem.where(link: item.url, feed_id: self.id).count
				count += FeedItem.where(title: item.title, feed_id: self.id).count
				next unless count == 0

				if(date && date != "" && Date.parse(date) > (Date.today - 30))
                                  begin
					self.feed_items << create_feed_item(item, item.url, item.url, hash_key, date)
                                  rescue => e
                                    puts "Error adding feed item for feed #{self.id} error message: #{e.message}"
                                  end
				end
			rescue => e
                          puts "Error adding feed item feed id: #{self.id} error message: #{e.message}"
				return
			end
		end
	end

	def create_feed_item(item, link, domain, hash_key, date)
		title = item.title || ""
		description = (item.summary.nil? || item.summary.empty?) ? title : item.summary
		media = get_media(item)
		fi = self.feed_items.new
		fi.title = title
		fi.link = link
		fi.description = description
		fi.timestamp = date
		fi.media = media
		fi.key = hash_key
		fi.save!
		fi
	end

	def get_media(item)
		if(!item.image.nil?)
			return item.image
		end
		return ""
	end

	def get_link(item)
		item.url =~ /^http/ ? item.url : item.entry_id
	end

	def get_hash_key(item, date)
		title = "" 
		link = ""
		begin
			title = (item.title.nil? || item.title.empty?) ? item.summary[0,25] : item.title
			link = item.url
		rescue => e
			puts "{e}"
		end
		opts = {
			:title => title,
			:link => link,
			:timestamp => date
		}
		FeedItem.hash_key_from_opts opts
	end

	def get_date(item)
		begin
			DateTime.parse(item.published.to_s).strftime("%Y-%m-%dT%H:%M:%SZ")
		rescue => e
			return Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
		end
	end
end