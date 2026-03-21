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

class ImportFeedsJob < ApplicationJob
  queue_as :default

  def perform(feeds, user_id)
    feeds.each do |feed_data|
      feed_data = feed_data.with_indifferent_access
      # Skip if user already has an identical feed (URI, Name, and Category)
      next if Feed.exists?(
        uri: feed_data[:uri],
        name: feed_data[:name],
        category: feed_data[:category],
        user: user_id
      )

      begin
        feed = Feed.new(
          uri: feed_data[:uri],
          name: feed_data[:name],
          category: feed_data[:category],
          user: user_id
        )

        if feed.save
          # Fetch initial items
          feed.update_feed_items
        end
      rescue => e
        Rails.logger.error "Failed to import feed #{feed_data['uri']} for user #{user_id}: #{e.message}"
      end
    end
  end
end
