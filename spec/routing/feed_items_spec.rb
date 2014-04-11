require 'spec_helper'

describe FeedItemsController do
	describe "routing" do
		it "routes to #mark_as_read" do
			{ :get => "/feed_items/mark_as_read" }.should route_to(
				:controller => "feed_items",
				:action => "mark_as_read"
			)
		end
	end
end
