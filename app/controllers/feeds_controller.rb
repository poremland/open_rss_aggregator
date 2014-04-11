class FeedsController < ApplicationController
	protect_from_forgery :except => [:create, :mark_items_as_read] 

	def index
		respond_to do |format|
			format.html { redirect_to(:controller => "application") }
			format.xml	{ head :ok }
		end
	end

	def all
		@feeds = Feed.find(:all, :conditions => { 'user' => session["user_id"] }, :order => "name ASC")

		respond_to do |format|
			format.xml	{ render :xml => @feeds }
			format.json { render :json => @feeds.to_json }
		end
	end

	def tree
		@feeds = Feed.joins(:feed_items)
					.select('feeds.id as id, feeds.name as name, feeds.uri as uri, count(feed_items.id) as count')
					.group('feeds.id')
					.where({ 'feed_items.display' => true, 'user' => session["user_id"] })
					.order('name ASC')
		respond_to do |format|
			format.xml
			format.json { render :json => get_json_tree(@feeds) }
		end
	end

	def get_json_tree(feeds)
		feeds.collect { |feed|
			{
				:feed => {
					:count => feed.count,
					:name => feed.name,
					:id => feed.id,
					:uri => feed.uri
				}
			}
		}
	end

	def show
		feed = Feed.find(params[:id])
		@feed_items = feed.feed_items

		respond_to do |format|
			format.xml	{ render :xml => @feed_items }
			format.json { render :json => @feed_items.to_json }
		end
	end

	def sync
		feed = Feed.find(params[:id])
		feed.update_feed_items
		@count = feed.feed_items.count
		@id = feed.id
 
		respond_to do |format|
			format.xml
			format.json { render :json => { :count => @count, :id => @id } }
		end
	end

	def unread_feed_items
		feed = Feed.find(params[:id], :conditions => { 'user' => session["user_id"] })
		@count = feed.feed_items.count
		@id = feed.id
 
		respond_to do |format|
			format.xml
			format.json { render :json => { :count => @count, :id => @id } }
		end
	end

	def new
		@feed = Feed.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml	{ render :xml => @feed }
		end
	end

	def edit
		respond_to do |format|
			format.html { redirect_to(:controller => "application") }
			format.xml	{ head :ok }
		end
	end

	def create
		@feed = Feed.new
		@feed.uri = params[:feed][:uri]
		@feed.name = params[:feed][:name]
		@feed.user = params[:feed][:user]

		respond_to do |format|
			if @feed.save
				@feed.update_feed_items
				flash[:notice] = 'Feed was successfully created.'
				format.html { redirect_to(:controller => "application") }
				format.xml	{ render :xml => @feed, :status => :created, :location => @feed }
				format.json { render :json => @feed, :status => :created, :location => @feed }
			else
				flash[:notice] = 'Unable to create feed.'
				format.html { redirect_to(:controller => "application") }
				format.xml	{ render :xml => @feed.errors, :status => :unprocessable_entity }
				format.json	{ render :json => @feed.errors, :status => :unprocessable_entity }
			end
		end
	end

	def update
		respond_to do |format|
			format.html { redirect_to(:controller => "application") }
			format.xml	{ head :ok }
		end
	end

	def remove
		@feed = Feed.find(params[:id], :conditions => { 'user' => session["user_id"] })
		@feed.destroy

		respond_to do |format|
			format.html { redirect_to(:controller => "application") }
			format.xml	{ head :ok }
		end
	end

	def mark_items_as_read
		@feed = Feed.find(params[:id], :conditions => { 'user' => session["user_id"] })
		items = params[:items]
		#TODO: Figure out how to remove the eval
		# this is a hack to get around the fact that
		# the parameters aren't being sent correctly.
		items = JSON.parse(items) unless items.kind_of?(Array) or items.nil?
		item_ids = "id=#{items.join(" or id=")}"
		FeedItem.where(item_ids).update_all(:display => false) if not items.nil?

		@feed.reload
		@count = @feed.feed_items.count
		@id = @feed.id

		respond_to do |format|
			format.xml
			format.json { render :json => { :count => @count, :id => @id } }
		end
	end

	protected
	def secure?
		true
	end
end
