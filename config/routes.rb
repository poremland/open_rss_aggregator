OpenRss::Application.routes.draw do
	get "login/login"
	post "login/do_login"
	get "login/do_logout"

	match "feed_items/mark_as_read/:id" => 'feed_items#mark_as_read', :via => :get
	match "feed_items/favorite/:id" => 'feed_items#favorite', :via => :get
	match "feed_items/unfavorite/:id" => 'feed_items#unfavorite', :via => :get
	get "feed_items/favorites"
	match "feed_items/:id" => 'feed_items#show', :via => :get

	get "feeds/all"
	get "feeds/tree"
	match "feeds/sync/:id" => 'feeds#sync', :via => :get
	get "feeds/unread_feed_items"
	match "feeds/remove/:id" => 'feeds#remove', :via => :get
	match "feeds/mark_items_as_read/:id" => 'feeds#mark_items_as_read', :via => :post
	post "feeds/create"
	resources :feeds

	root :to => 'application#index'
end
