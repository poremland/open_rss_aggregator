require 'spec_helper'

describe LoginController do
	describe "routing" do
		it "routes to #login" do
			{ :get => "/login/login" }.should route_to(
				:controller => "login",
				:action => "login"
			)
		end

		it "routes to #do_login" do
			{ :post => "/login/do_login" }.should route_to(
				:controller => "login",
				:action => "do_login"
			)
		end

		it "routes to #do_logout" do
			{ :get => "/login/do_logout" }.should route_to(
				:controller => "login",
				:action => "do_logout"
			)
		end
	end
end
