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
