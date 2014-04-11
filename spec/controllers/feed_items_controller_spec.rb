require 'spec_helper'

describe FeedItemsController do

  describe "GET 'mark_as_read'" do
    it "returns http success" do
      get 'mark_as_read'
      response.should be_success
    end
  end

end
