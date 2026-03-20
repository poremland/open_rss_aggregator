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

class OpmlService
  def self.export(user_id)
    feeds = Feed.where(user: user_id).order(:category, :name)
    
    builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
      xml.opml(version: "2.0") {
        xml.head {
          xml.title "RSS Subscriptions"
          xml.dateCreated Time.now.rfc822
        }
        xml.body {
          # Group by category
          grouped_feeds = feeds.group_by(&:category)
          
          # Handle uncategorized feeds first (where category is nil or empty)
          uncategorized = (grouped_feeds.delete(nil) || []) + (grouped_feeds.delete("") || [])
          uncategorized.each do |feed|
            xml.outline(
              type: "rss",
              text: feed.name,
              title: feed.name,
              xmlUrl: feed.uri,
              htmlUrl: "" # Feeds don't currently store the site URL separately
            )
          end
          
          # Handle categorized feeds
          grouped_feeds.each do |category, category_feeds|
            xml.outline(text: category, title: category) {
              category_feeds.each do |feed|
                xml.outline(
                  type: "rss",
                  text: feed.name,
                  title: feed.name,
                  xmlUrl: feed.uri,
                  htmlUrl: ""
                )
              end
            }
          end
        }
      }
    end
    
    builder.to_xml
  end
end
