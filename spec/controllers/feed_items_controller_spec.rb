require 'spec_helper'

describe FeedItemsController, type: :controller do
  before do
    allow(JwtService).to receive(:decode).and_return({ 'user_id' => 1 })
    allow(JwtService).to receive(:valid?).and_return(true)
    allow(FeedItem).to receive(:find).and_return(double('feed_item', update: true, display: true, :display= => true, save: true, feed: double('feed', reload: true, feed_items: double('feed_items', count: 0), id: 1)))
    request.headers['Authorization'] = "Bearer dummy_token"
  end

  describe "GET 'mark_as_read'" do
    it "returns http success" do
      get :mark_as_read, params: { id: 1 }
      expect(response).to be_successful
    end
  end

end
