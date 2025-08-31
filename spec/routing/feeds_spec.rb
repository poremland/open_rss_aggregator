require 'spec_helper'

describe FeedsController, type: :routing do
	describe "routing" do
		it "routes to #index" do
			expect(:get => "/feeds").to route_to(
				:controller => "feeds",
				:action => "index"
			)
		end

		it "routes to #all" do
			expect(:get => "/feeds/all").to route_to(
				:controller => "feeds",
				:action => "all"
			)
		end

		it "routes to #tree" do
			expect(:get => "/feeds/tree").to route_to(
				:controller => "feeds",
				:action => "tree"
			)
		end

		it "routes to #show" do
			expect(:get => "/feeds/1").to route_to(
				:controller => "feeds",
				:action => "show",
				:id => "1"
			)
		end

		it "routes to #sync" do
			expect(:get => "/feeds/sync/1").to route_to(
				:controller => "feeds",
				:action => "sync",
				:id => "1"
			)
		end

		it "routes to #unread_feed_items" do
			expect(:get => "/feeds/unread_feed_items/1").to route_to(
				:controller => "feeds",
				:action => "unread_feed_items",
				:id => "1"
			)
		end

		it "routes to #create" do
			expect(:post => "/feeds").to route_to(
				:controller => "feeds",
				:action => "create"
			)
		end

		it "routes to #update" do
			expect(:put => "/feeds/1").to route_to(
				:controller => "feeds",
				:action => "update",
				:id => "1"
			)
		end

		it "routes to #remove" do
			expect(:get => "/feeds/remove/1").to route_to(
				:controller => "feeds",
				:action => "remove",
				:id => "1"
			)
		end

		it "routes to #mark_items_as_read" do
			expect(:post => "/feeds/mark_items_as_read/1").to route_to(
				:controller => "feeds",
				:action => "mark_items_as_read",
				:id => "1"
			)
		end
	end
end
