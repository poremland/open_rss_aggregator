require 'spec_helper'

describe ApplicationController do
	describe "routing" do
		it "routes to #index" do
			{ :get => "/" }.should route_to(
				:controller => "application",
				:action => "index"
			)
		end
	end
end
