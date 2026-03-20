require 'spec_helper'

RSpec.describe OpmlService do
  describe '.export' do
    let(:user_id) { 'test_user' }
    
    before do
      FactoryBot.create(:feed, user: user_id, name: 'Feed 1', uri: 'http://feed1.com', category: nil)
      FactoryBot.create(:feed, user: user_id, name: 'Feed 2', uri: 'http://feed2.com', category: 'Tech')
      FactoryBot.create(:feed, user: user_id, name: 'Feed 3', uri: 'http://feed3.com', category: 'Tech')
      FactoryBot.create(:feed, user: 'other_user', name: 'Other Feed', uri: 'http://other.com')
    end
    
    it 'generates valid OPML for a specific user' do
      xml = OpmlService.export(user_id)
      doc = Nokogiri::XML(xml)
      
      expect(doc.at_xpath('/opml/@version').value).to eq('2.0')
      expect(doc.at_xpath('/opml/head/title').text).to eq('RSS Subscriptions')
      
      # Should contain 3 feeds for test_user
      expect(doc.xpath('//outline[@type="rss"]').count).to eq(3)
      
      # Uncategorized feed at root
      expect(doc.at_xpath('/opml/body/outline[@xmlUrl="http://feed1.com"]')).not_to be_nil
      
      # Categorized feeds under category outline
      tech_category = doc.at_xpath('/opml/body/outline[@title="Tech"]')
      expect(tech_category).not_to be_nil
      expect(tech_category.xpath('outline[@xmlUrl="http://feed2.com"]').count).to eq(1)
      expect(tech_category.xpath('outline[@xmlUrl="http://feed3.com"]').count).to eq(1)
      
      # Should NOT contain other user's feeds
      expect(doc.at_xpath('//outline[@xmlUrl="http://other.com"]')).to be_nil
    end
  end
end
