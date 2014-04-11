require 'spec_helper'

describe LoginController do

  describe "GET 'do_login'" do
    it "returns http success" do
      get 'do_login'
      response.should be_success
    end
  end

  describe "GET 'do_logout'" do
    it "returns http success" do
      get 'do_logout'
      response.should be_success
    end
  end

end
