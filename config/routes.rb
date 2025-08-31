OpenRss::Application.routes.draw do
	  post "api/login", to: 'login#do_login', defaults: { format: :json }
  post "api/request_otp", to: 'login#request_otp', defaults: { format: :json }

	post "api/refresh_token", to: 'login#refresh_token', defaults: { format: :json }
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
	match "feeds/unread_feed_items/:id" => 'feeds#unread_feed_items', :via => :get
	match "feeds/remove/:id" => 'feeds#remove', :via => :get
	match "feeds/mark_items_as_read/:id" => 'feeds#mark_items_as_read', :via => :post
	post "feeds/create"
	resources :feeds

	root :to => 'application#index'
end
