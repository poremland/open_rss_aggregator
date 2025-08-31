require 'spec_helper'

RSpec.describe Feed, type: :model do
  it { should have_many(:feed_items).inverse_of(:feed).with_foreign_key(:feed_id).dependent(:destroy) }

  describe '#get_date' do
    let(:feed) { FactoryBot.create(:feed) }

    context 'when item has a pubdate' do
      let(:item) { double('Feedjira::Entry', published: Time.parse("Wed, 30 Jul 2025 10:00:00 GMT")) }
      it 'returns the formatted date from pubdate' do
        expect(feed.send(:get_date, item)).to eq('2025-07-30T10:00:00Z')
      end
    end

    context 'when item has meta pubdate' do
      let(:item) { double('Feedjira::Entry', published: Time.parse("2025-07-30T11:00:00Z")) }
      it 'returns the formatted date from meta pubdate' do
        expect(feed.send(:get_date, item)).to eq('2025-07-30T11:00:00Z')
      end
    end

    context 'when item has no date information' do
      let(:item) { double('Feedjira::Entry', published: nil) }
      it 'returns the current time formatted' do
        travel_to(Time.parse('2025-07-30T13:00:00Z').utc) do
          expect(feed.send(:get_date, item)).to eq(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"))
        end
      end
    end
  end

  describe '#get_media' do
    let(:feed) { FactoryBot.create(:feed) }

    context 'when item has an image URL' do
      it 'returns the URL of an mp3 enclosure' do
        item = double('Feedjira::Entry', image: "http://example.com/audio.mp3")
        expect(feed.send(:get_media, item)).to eq("http://example.com/audio.mp3")
      end

      it 'returns the URL of a wav enclosure' do
        item = double('Feedjira::Entry', image: "http://example.com/audio.wav")
        expect(feed.send(:get_media, item)).to eq("http://example.com/audio.wav")
      end

      it 'returns the URL of an mpeg enclosure' do
        item = double('Feedjira::Entry', image: "http://example.com/video.mpeg")
        expect(feed.send(:get_media, item)).to eq("http://example.com/video.mpeg")
      end

      it 'returns the URL of an mp4 enclosure' do
        item = double('Feedjira::Entry', image: "http://example.com/video.mp4")
        expect(feed.send(:get_media, item)).to eq("http://example.com/video.mp4")
      end

      it 'returns the URL even with query parameters' do
        item = double('Feedjira::Entry', image: "http://example.com/audio.mp3?id=123")
        expect(feed.send(:get_media, item)).to eq("http://example.com/audio.mp3?id=123")
      end

      it 'returns the first matching media URL' do
        item = double('Feedjira::Entry', image: "http://example.com/audio.mp3")
        expect(feed.send(:get_media, item)).to eq("http://example.com/audio.mp3")
      end
    end

    context 'when item has no media enclosures' do
      it 'returns an empty string' do
        item = double('Feedjira::Entry', image: nil)
        expect(feed.send(:get_media, item)).to eq("")
      end

      it 'returns an empty string if enclosures is nil' do
        item = double('Feedjira::Entry', image: nil)
        expect(feed.send(:get_media, item)).to eq("")
      end

      it 'returns an empty string if enclosures is empty' do
        item = double('Feedjira::Entry', image: nil)
        expect(feed.send(:get_media, item)).to eq("")
      end
    end
  end

  describe '#get_link' do
    let(:feed) { FactoryBot.create(:feed) }

    context 'when item.url starts with http' do
      it 'returns item.url' do
        item = double('item', url: 'http://example.com/link', entry_id: 'entry123')
        expect(feed.send(:get_link, item)).to eq('http://example.com/link')
      end
    end

    context 'when item.url does not start with http' do
      it 'returns item.entry_id' do
        item = double('item', url: 'feedburner:entry-id', entry_id: 'entry123')
        expect(feed.send(:get_link, item)).to eq('entry123')
      end
    end
  end

  describe '#get_hash_key' do
    let(:feed) { FactoryBot.create(:feed) }
    let(:date) { '2025-07-30T14:00:00Z' }

    context 'when title and link are present' do
      let(:item) { double('Feedjira::Entry', title: "Test Title", url: "http://example.com/test", summary: "This is a description") }
      it 'generates a hash key using title, link, and date' do
        expected_hash = FeedItem.hash_key_from_opts(title: "TestTitle", link: "http://example.com/test", timestamp: date)
        expect(feed.send(:get_hash_key, item, date)).to eq(expected_hash)
      end
    end

    context 'when title is empty' do
      let(:item) { double('Feedjira::Entry', title: "", summary: "This is a description", url: "http://example.com/test") }
      it 'generates a hash key using description (first 25 chars), link, and date' do
        expected_hash = FeedItem.hash_key_from_opts(title: item.summary[0,25], link: item.url, timestamp: date)
        expect(feed.send(:get_hash_key, item, date)).to eq(expected_hash)
      end
    end

    context 'when title is nil' do
      let(:item) { double('Feedjira::Entry', title: nil, summary: "This is a description", url: "http://example.com/test") }
      it 'generates a hash key using description (first 25 chars), link, and date' do
        expected_hash = FeedItem.hash_key_from_opts(title: "Thisisadescription", link: "http://example.com/test", timestamp: date)
        expect(feed.send(:get_hash_key, item, date)).to eq(expected_hash)
      end
    end

    context 'when link is nil' do
      let(:item) { double('Feedjira::Entry', title: "Test Title", url: nil, summary: "This is a description") }
      it 'generates a hash key with nil link' do
        expected_hash = FeedItem.hash_key_from_opts(title: "TestTitle", link: nil, timestamp: date)
        expect(feed.send(:get_hash_key, item, date)).to eq(expected_hash)
      end
    end
  end

  describe '#create_feed_item' do
    let(:feed) { FactoryBot.create(:feed) }
    let(:item_data) do
      double('Feedjira::Entry',
        title: "New Feed Item",
        summary: "Description of new feed item",
        url: "http://example.com/new-item",
        image: "http://example.com/media.mp4"
      )
    end
    let(:link) { "http://example.com/new-item" }
    let(:domain) { "example.com" }
    let(:hash_key) { "some_hash_key" }
    let(:date) { "2025-07-30T15:00:00Z" }

    it 'creates and saves a new FeedItem' do
      expect { feed.send(:create_feed_item, item_data, link, domain, hash_key, date) }.
        to change(FeedItem, :count).by(1)

      new_feed_item = FeedItem.last
      expect(new_feed_item.title).to eq(item_data.title)
      expect(new_feed_item.link).to eq(item_data.url)
      expect(new_feed_item.description).to eq(item_data.summary)
      expect(new_feed_item.timestamp).to eq(date)
      expect(new_feed_item.media).to eq("http://example.com/media.mp4")
      expect(new_feed_item.key).to eq(hash_key)
      expect(new_feed_item.feed).to eq(feed)
    end

    context 'when description is empty or nil' do
      it 'uses title as description if description is empty' do
        allow(item_data).to receive(:summary).and_return("")
        feed_item = feed.send(:create_feed_item, item_data, link, domain, hash_key, date)
        expect(feed_item.description).to eq(item_data.title)
      end

      it 'uses title as description if description is nil' do
        allow(item_data).to receive(:summary).and_return(nil)
        feed_item = feed.send(:create_feed_item, item_data, link, domain, hash_key, date)
        expect(feed_item.description).to eq(item_data.title)
      end
    end

    context 'when title is nil' do
      it 'uses an empty string for title' do
        allow(item_data).to receive(:title).and_return(nil)
        feed_item = feed.send(:create_feed_item, item_data, link, domain, hash_key, date)
        expect(feed_item.title).to eq("")
      end
    end
  end

  describe '#update_feed_items' do
    let(:feed) { FactoryBot.create(:feed, uri: 'http://example.com/rss') }
    let(:feedjira_feed) { double('Feedjira::Feed') }
    let(:feedjira_entry1) { double('Feedjira::Entry', title: "Item 1", summary: "Description 1", url: "http://example.com/item1", published: Date.today.to_time, image: "http://example.com/media1.mp3") }
    let(:feedjira_entry2) { double('Feedjira::Entry', title: "Item 2", summary: "Description 2", url: "http://example.com/item2", published: Time.parse("Wed, 30 Jul 2025 17:00:00 GMT"), image: nil) }

    before do
      allow(Feedjira).to receive(:parse).and_return(feedjira_feed)
      allow(feedjira_feed).to receive(:entries).and_return([feedjira_entry1, feedjira_entry2])
      allow(FeedItem).to receive(:where).and_return(double(count: 0))
    end

    context 'when Feedjira parsing fails' do
      before do
        allow(Feedjira).to receive(:parse).and_raise("Feedjira Parsing Error")
        allow(feed).to receive(:puts) # Suppress puts output during test
      end

      it 'does not create feed items and logs an error' do
        expect { feed.update_feed_items }.not_to change(FeedItem, :count)
        expect(feed).to have_received(:puts).with(/Error updating feed items for feed: .*Feedjira Parsing Error/)
      end
    end

    context 'when RSS parsing returns nil or 0 entries' do
      before do
        allow(feedjira_feed).to receive(:entries).and_return([])
        allow(feed).to receive(:puts) # Suppress puts output during test
      end

      it 'does not create feed items and logs an error' do
        expect { feed.update_feed_items }.not_to change(FeedItem, :count)
        expect(feed).to have_received(:puts).with(/Error updating feed items for feed: .*Unable to fetch and parse/)
      end
    end

    context 'when a feed item is older than 30 days' do
      let(:old_feedjira_entry) { double('Feedjira::Entry', title: "Old Item", summary: "Old Description", url: "http://example.com/old-item", published: (Date.today - 31).to_time, image: nil) }

      before do
        allow(feedjira_feed).to receive(:entries).and_return([old_feedjira_entry])
      end

      it 'does not create feed items older than 30 days' do
        expect { feed.update_feed_items }.not_to change(FeedItem, :count)
      end
    end

    context 'when HTTParty successfully fetches and Feedjira parses the feed' do
      let(:sample_xml) { '<rss><channel><item><title>Test Item</title><link>http://test.com/item</link><pubDate>Wed, 30 Jul 2025 18:00:00 GMT</pubDate></item></channel></rss>' }
      let(:httparty_response) { double('HTTParty::Response', body: sample_xml) }

      before do
        allow(HTTParty).to receive(:get).and_return(httparty_response)
        allow(Feedjira).to receive(:parse).and_return(feedjira_feed)
        allow(feedjira_feed).to receive(:entries).and_return([feedjira_entry1])
        allow(FeedItem).to receive(:where).and_return(double(count: 0))
      end

      it 'creates new feed items' do
        expect { feed.update_feed_items }.to change(FeedItem, :count).by(1)
        new_feed_item = FeedItem.last
        expect(new_feed_item.title).to eq("Item 1")
        expect(new_feed_item.link).to eq("http://example.com/item1")
      end
    end

    context 'when HTTParty encounters an error' do
      before do
        allow(HTTParty).to receive(:get).and_raise(SocketError.new("Failed to open connection"))
        allow(feed).to receive(:puts) # Suppress puts output during test
      end

      it 'does not create feed items and logs an error' do
        expect { feed.update_feed_items }.not_to change(FeedItem, :count)
        expect(feed).to have_received(:puts).with(/Error updating feed items for feed: .*Failed to open connection/)
      end
    end
  end
end
