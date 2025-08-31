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

class FeedItem < ApplicationRecord
	belongs_to :feed, :inverse_of => :feed_items, :foreign_key => :feed_id
	validates_presence_of :feed

	def generate_hash_key
		return @hash_key unless @hash_key.nil?
		opts = {
			:title => self.title,
			:link => self.link,
			:timestamp => self.timestamp
		}
		@hash_key = FeedItem.hash_key_from_opts opts
	end

	def self.hash_key_from_opts opts
		link = opts[:link]
		link = URI.encode_www_form_component(link) unless link.nil?
		domain = link
		domain = URI.parse(link) unless domain.nil?
		domain = domain.host.downcase unless domain.nil? || domain.host.nil?
		title = opts[:title]
		title = opts[:title].gsub(/[^0-9A-Za-z]/,'') unless title.nil?
		timestamp = opts[:timestamp]
		timestamp = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") if timestamp.nil?
		Digest::SHA1.hexdigest "#{domain}_#{title}_#{timestamp}"
	end
end