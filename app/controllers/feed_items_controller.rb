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

class FeedItemsController < ApplicationController
	include JwtAuthenticatable

	def mark_as_read
		update_item(params[:id]) do |item|
			item.display = false
		end
	end

	def favorite
		update_item(params[:id]) do |item|
			item.favorite = true
		end
	end

	def unfavorite
		update_item(params[:id]) do |item|
			item.favorite = false
		end
	end

	def favorites
		@items = FeedItem.joins(:feed)
										 .select('feeds.id, feeds.name, feed_items.*')
										 .where({ 'favorite' => true, 'feeds.user' => @logged_in_user })
										 .order('name ASC')

		if request.format.json?
			render json: @items
		else
			render xml: @items
		end
	end

	def update_item(id, &block)
		feed_item = FeedItem.find(id)
		yield feed_item
		feed_item.save
		feed_item.feed.reload
		@count = feed_item.feed.feed_items.count
		@id = feed_item.feed.id

		if request.format.json?
			render json: { count: @count, id: @id }
		else
			render xml: { count: @count, id: @id }
		end
	end

	def show
		@feed_item = FeedItem.find(params[:id])

		if request.format.json?
			render json: @feed_item
		else
			render xml: @feed_item
		end
	end

	protected

	def secure?
		true
	end
end