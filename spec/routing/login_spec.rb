require 'spec_helper'

describe LoginController, type: :routing do
	describe "routing" do
		it "routes to #do_login" do
			expect(:post => "/login/do_login").to route_to(
				:controller => "login",
				:action => "do_login"
			)
		end

		it "routes to #do_logout" do
			expect(:get => "/login/do_logout").to route_to(
				:controller => "login",
				:action => "do_logout"
			)
		end
	end
end
