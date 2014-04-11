require 'spec_helper'

describe FeedsController do
	describe "routing" do
		it "routes to #index" do
			{ :get => "/feeds/index" }.should route_to(
				:controller => "feeds",
				:action => "index"
			)
		end

		it "routes to #all" do
			{ :get => "/feeds/all" }.should route_to(
				:controller => "feeds",
				:action => "all"
			)
		end

		it "routes to #tree" do
			{ :get => "/feeds/tree" }.should route_to(
				:controller => "feeds",
				:action => "tree"
			)
		end

		it "routes to #show" do
			{ :get => "/feeds/show" }.should route_to(
				:controller => "feeds",
				:action => "show"
			)
		end

		it "routes to #sync" do
			{ :get => "/feeds/sync" }.should route_to(
				:controller => "feeds",
				:action => "sync"
			)
		end

		it "routes to #unread_feed_items" do
			{ :get => "/feeds/unread_feed_items" }.should route_to(
				:controller => "feeds",
				:action => "unread_feed_items"
			)
		end

		it "routes to #edit" do
			{ :get => "/feeds/edit" }.should route_to(
				:controller => "feeds",
				:action => "edit"
			)
		end

		it "routes to #create" do
			{ :get => "/feeds/create" }.should route_to(
				:controller => "feeds",
				:action => "create"
			)
		end

		it "routes to #update" do
			{ :get => "/feeds/update" }.should route_to(
				:controller => "feeds",
				:action => "update"
			)
		end

		it "routes to #remove" do
			{ :get => "/feeds/remove" }.should route_to(
				:controller => "feeds",
				:action => "remove"
			)
		end

		it "routes to #mark_items_as_read" do
			{ :get => "/feeds/mark_items_as_read" }.should route_to(
				:controller => "feeds",
				:action => "mark_items_as_read"
			)
		end
	end
end
