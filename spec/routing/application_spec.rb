require 'spec_helper'

describe ApplicationController, type: :routing do
	describe "routing" do
		it "routes to #index" do
			expect(:get => "/").to route_to(
				:controller => "application",
				:action => "index"
			)
		end
	end
end
