require 'spec_helper'

describe FeedItemsController, type: :routing do
	describe "routing" do
		it "routes to #mark_as_read" do
			expect(:get => "/feed_items/mark_as_read/1").to route_to(
				:controller => "feed_items",
				:action => "mark_as_read",
				:id => "1"
			)
		end
	end
end
