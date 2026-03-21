require 'spec_helper'

RSpec.describe OpmlService do
  describe '.export' do
    let(:user_id) { 'test_user' }

    before do
      Feed.destroy_all
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

  describe '.import' do
    let(:user_id) { 'test_user' }
    let(:xml) {
      <<-XML
        <opml version="2.0">
          <head><title>Test OPML</title></head>
          <body>
            <outline text="Root Feed" xmlUrl="http://root.com" />
            <outline title="Tech" text="Tech Category">
              <outline title="Feed 1" text="Feed 1" xmlUrl="http://feed1.com" />
              <outline title="Subcategory">
                <outline title="Feed 2" xmlUrl="http://feed2.com" />
              </outline>
            </outline>
          </body>
        </opml>
      XML
    }

    it 'correctly parses OPML and extracts feeds with categories' do
      feeds = OpmlService.import(xml, user_id)

      expect(feeds.count).to eq(3)

      # Feed at root
      root_feed = feeds.find { |f| f[:uri] == 'http://root.com' }
      expect(root_feed[:name]).to eq('Root Feed')
      expect(root_feed[:category]).to be_nil

      # Feed in category
      feed1 = feeds.find { |f| f[:uri] == 'http://feed1.com' }
      expect(feed1[:name]).to eq('Feed 1')
      expect(feed1[:category]).to eq('Tech Category') # Nokogiri uses 'text' if both exist or 'title'

      # Feed in sub-category (we currently only support one level, so it takes the immediate parent)
      feed2 = feeds.find { |f| f[:uri] == 'http://feed2.com' }
      expect(feed2[:name]).to eq('Feed 2')
      expect(feed2[:category]).to eq('Subcategory')
    end

    it 'handles empty or malformed OPML' do
      expect(OpmlService.import("", user_id)).to eq([])
      expect(OpmlService.import("<invalid></invalid>", user_id)).to eq([])
    end
  end
end
