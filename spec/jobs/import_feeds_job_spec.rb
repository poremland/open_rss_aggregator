require 'spec_helper'

RSpec.describe ImportFeedsJob, type: :job do
  describe '#perform' do
    let(:user_id) { 'test_user' }
    let(:feeds_data) {
      [
        { 'uri' => 'http://feed1.com', 'name' => 'Feed 1', 'category' => 'Tech' },
        { 'uri' => 'http://feed2.com', 'name' => 'Feed 2', 'category' => nil }
      ]
    }
    
    before do
      Feed.destroy_all
      allow_any_instance_of(Feed).to receive(:update_feed_items)
    end
    
    it 'creates new feeds for the user' do
      ImportFeedsJob.perform_now(feeds_data, user_id)
      
      feed1 = Feed.find_by(uri: 'http://feed1.com', user: user_id)
      expect(feed1.name).to eq('Feed 1')
      expect(feed1.category).to eq('Tech')
      
      feed2 = Feed.find_by(uri: 'http://feed2.com', user: user_id)
      expect(feed2.name).to eq('Feed 2')
      expect(feed2.category).to be_nil
    end
    
    it 'skips existing feeds for the same user' do
      FactoryBot.create(:feed, uri: 'http://feed1.com', user: user_id)
      
      expect {
        ImportFeedsJob.perform_now(feeds_data, user_id)
      }.to change(Feed, :count).by(1) # Only Feed 2 is new
    end
    
    it 'allows the same feed for different users' do
      FactoryBot.create(:feed, uri: 'http://feed1.com', user: 'other_user')
      
      expect {
        ImportFeedsJob.perform_now(feeds_data, user_id)
      }.to change(Feed, :count).by(2)
    end
  end
end
