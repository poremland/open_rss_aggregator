class FeedsController < ApplicationController
	include JwtAuthenticatable

	def index
		head :ok
	end

	def all
		@feeds = Feed.where(user: @logged_in_user).order("name ASC")
		if request.format.json?
			render json: @feeds
		else
			render xml: @feeds
		end
	end

	def tree
		@feeds = Feed.joins(:feed_items)
								 .select('feeds.id as id, feeds.name as name, feeds.uri as uri, count(feed_items.id) as count')
								 .group('feeds.id')
								 .where({ 'feed_items.display' => true, 'user' => @logged_in_user })
								 .order('name ASC')
		if request.format.json?
			render json: get_json_tree(@feeds)
		else
			render xml: get_xml_tree(@feeds)
		end
	end

	def get_json_tree(feeds)
		feeds.collect { |feed|
			{
				feed: {
					count: feed.count,
					name: feed.name,
					id: feed.id,
					uri: feed.uri
				}
			}
		}
	end

	def show
		feed = Feed.find(params[:id])
		@feed_items = feed.feed_items.where(display: true)
		if request.format.json?
			render json: @feed_items
		else
			render xml: @feed_items
		end
	end

	def sync
		feed = Feed.find(params[:id])
		feed.update_feed_items
		@count = feed.feed_items.count
		@id = feed.id
		if request.format.json?
			render json: { count: @count, id: @id }
		else
			render xml: { count: @count, id: @id }
		end
	end

	def unread_feed_items
		feed = Feed.joins(:feed_items)
								 .select('feeds.id as id, count(feed_items.id) as count')
								 .find(params[:id])
		@count = feed.feed_items.count
		@id = feed.id
		if request.format.json?
			render json: { count: @count, id: @id }
		else
			render xml: { count: @count, id: @id }
		end
	end

	def new
		@feed = Feed.new
		if request.format.json?
			render json: @feed
		else
			render xml: @feed
		end
	end

	def edit
		head :ok
	end

	def create
		@feed = Feed.new(params.require(:feed).permit(:uri, :name, :user))
		if @feed.save
			@feed.update_feed_items
			render json: @feed, status: :created, location: @feed
		else
			render json: @feed.errors, status: :unprocessable_entity
		end
	end

	def update
		@feed = Feed.find(params[:id])
		if @feed.update(params.require(:feed).permit(:uri, :name, :user))
			render json: @feed
		else
			render json: @feed.errors, status: :unprocessable_entity
		end
	end

	def remove
		@feed = Feed.where(id: params[:id], user: @logged_in_user)
		@feed.destroy_all
		render json: { id: params[:id], user: @logged_in_user, status: "deleted" }
	end

	def mark_items_as_read
		@feed = Feed.find_by(id: params[:id], user: @logged_in_user)
		if @feed
			items = params[:items]
			items = JSON.parse(items) unless items.kind_of?(Array) || items.nil?
			item_ids = "id IN (#{items.join(',')})" if items.present?
			FeedItem.where(item_ids).update_all(display: false) if item_ids.present?

			@feed.reload
			@count = @feed.feed_items.count
			@id = @feed.id

			if request.format.json?
				render json: { count: @count, id: @id }
			else
				render xml: { count: @count, id: @id }
			end
		else
			render json: { error: 'Feed not found' }, status: :not_found
		end
	end

	protected

	def secure?
		true
	end
end
