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

  describe '#get_description' do
    let(:feed) { FactoryBot.create(:feed) }

    context 'when item has a summary' do
      it 'returns the item summary' do
        item = double('Feedjira::Entry', summary: 'This is a summary', content: nil, title: 'This is a title')
        expect(feed.send(:get_description, item)).to eq('This is a summary')
      end
    end

    context 'when item has no summary but has content' do
      it 'returns the item content' do
        item = double('Feedjira::Entry', summary: nil, content: 'This is content', title: 'This is a title')
        expect(feed.send(:get_description, item)).to eq('This is content')
      end
    end

    context 'when item has no summary or content but has a title' do
      it 'returns the item title' do
        item = double('Feedjira::Entry', summary: nil, content: nil, title: 'This is a title')
        expect(feed.send(:get_description, item)).to eq('This is a title')
      end
    end

    context 'when item has no summary, content, or title' do
      it 'returns nil' do
        item = double('Feedjira::Entry', summary: nil, content: nil, title: nil)
        expect(feed.send(:get_description, item)).to be_nil
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
        image: "http://example.com/media.mp4",
        content: nil
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
    let(:feedjira_entry1) { double('Feedjira::Entry', title: "Item 1", summary: "Description 1", url: "http://example.com/item1", published: Date.today.to_time, image: "http://example.com/media1.mp3", content: nil) }
    let(:feedjira_entry2) { double('Feedjira::Entry', title: "Item 2", summary: "Description 2", url: "http://example.com/item2", published: Time.parse("Wed, 30 Jul 2025 17:00:00 GMT"), image: nil, content: nil) }

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

    context 'when feed items have relative URLs' do
      let(:feed_with_relative_uri) { FactoryBot.create(:feed, uri: 'http://example.com/blog/feed.xml') }
      let(:relative_entry) { double('Feedjira::Entry', title: "Relative Item", summary: "Relative Description", url: "/blog/relative-item", published: Date.today.to_time, image: nil, content: nil) }
      let(:absolute_entry) { double('Feedjira::Entry', title: "Absolute Item", summary: "Absolute Description", url: "http://external.com/absolute-item", published: Date.today.to_time, image: nil, content: nil) }

      before do
        FeedItem.delete_all # Clean up before each test
        allow(HTTParty).to receive(:get).and_return(double(body: '<xml>'))
        allow(Feedjira).to receive(:parse).and_return(feedjira_feed)
        allow(feedjira_feed).to receive(:entries).and_return([relative_entry, absolute_entry])
        allow(FeedItem).to receive(:where).and_call_original # Unmock where for these tests
      end

      it 'resolves relative URLs to absolute URLs' do
        feed_with_relative_uri.update_feed_items
        new_feed_item = FeedItem.find_by(title: "Relative Item")
        expect(new_feed_item.link).to eq("http://example.com/blog/relative-item")
      end

      it 'does not change absolute URLs' do
        feed_with_relative_uri.update_feed_items
        new_feed_item = FeedItem.find_by(title: "Absolute Item")
        expect(new_feed_item.link).to eq("http://external.com/absolute-item")
      end

      context 'when atom feed has xhtml content' do
        let(:feed_with_xhtml) { FactoryBot.create(:feed, uri: 'http://example.com/atom-feed.xml') }
        let(:xhtml_entry) {
          double('Feedjira::Entry',
            title: "XHTML Content",
            summary: "Summary for XHTML content",
            url: "http://example.com/xhtml-item",
            published: Date.today.to_time,
            image: nil,
            content: "<div><p>This is some XHTML content</p></div>"
          )
        }

        before do
          FeedItem.delete_all
          allow(HTTParty).to receive(:get).and_return(double(body: '<xml>'))
          allow(Feedjira).to receive(:parse).and_return(feedjira_feed)
          allow(feedjira_feed).to receive(:entries).and_return([xhtml_entry])
          allow(FeedItem).to receive(:where).and_call_original
        end

        it 'passes the html from the content tag to the feed item' do
          feed_with_xhtml.update_feed_items
          new_feed_item = FeedItem.find_by(title: "XHTML Content")
          expect(new_feed_item.description).to eq("<div><p>This is some XHTML content</p></div>")
        end
      end

      context 'when a relative URL is invalid' do
        let(:invalid_relative_entry) { double('Feedjira::Entry', title: "Invalid Relative Item", summary: "Invalid Description", url: "://invalid-item", published: Date.today.to_time, image: nil, content: nil) }

        before do
          FeedItem.delete_all # Clean up before each test
          allow(feedjira_feed).to receive(:entries).and_return([invalid_relative_entry])
          allow(feed_with_relative_uri).to receive(:puts) # Suppress puts output during test
          allow(FeedItem).to receive(:where).and_call_original # Unmock where for these tests
        end

        it 'falls back to the original invalid URL and logs a warning' do
          feed_with_relative_uri.update_feed_items
          new_feed_item = FeedItem.find_by(title: "Invalid Relative Item")
          expect(new_feed_item.link).to eq("://invalid-item")
          expect(feed_with_relative_uri).to have_received(:puts).with(/Warning: Could not resolve relative URL ':\/\/invalid-item' with base 'http:\/\/example.com\/blog\/feed.xml'. Error: bad URI/)
        end
      end
    end
  end
end
