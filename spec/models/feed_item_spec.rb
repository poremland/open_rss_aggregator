require 'spec_helper'

RSpec.describe FeedItem, type: :model do
  it { should belong_to(:feed).inverse_of(:feed_items).with_foreign_key(:feed_id) }
  it { should validate_presence_of(:feed) }

  describe '#generate_hash_key' do
    let(:feed_item) { FactoryBot.build(:feed_item, title: 'Test Title', link: 'http://example.com/test', timestamp: Time.parse('2025-01-01T12:00:00Z').utc.to_s) }
    it 'memoizes the hash key' do
      first_call = feed_item.generate_hash_key
      feed_item.title = 'New Title' # Change attribute to ensure memoization
      second_call = feed_item.generate_hash_key
      expect(first_call).to eq(second_call)
    end
  end
end
