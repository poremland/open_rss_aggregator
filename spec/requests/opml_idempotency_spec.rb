require 'spec_helper'

RSpec.describe "OPML Idempotency", type: :request do
  let(:user_id) { "paul@oremland.net" }
  let(:token) { "valid_token" }
  let(:opml_content) {
    <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <opml version="2.0">
        <body>
          <outline type="rss" text="Daring Fireball" title="Daring Fireball" xmlUrl="https://daringfireball.net/index.xml" htmlUrl=""/>
          <outline type="rss" text="NPR" title="NPR" xmlUrl="https://feeds.npr.org/1001/rss.xml" htmlUrl=""/>
          <outline type="rss" text="Test" title="Test" xmlUrl="https://daringfireball.net/index.xml" htmlUrl=""/>
        </body>
      </opml>
    XML
  }
  let(:opml_file) {
    fixture_file_upload(
      Rails.root.join('spec', 'fixtures', 'idempotency.opml'),
      'text/x-opml'
    )
  }

  before do
    allow(JwtService).to receive(:decode).with(token).and_return({ 'user_id' => user_id })
    allow(JwtService).to receive(:valid?).with(token).and_return(true)

    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures'))
    File.write(Rails.root.join('spec', 'fixtures', 'idempotency.opml'), opml_content)

    # We want to actually run the job for this spec to verify the DB state
    allow(ImportFeedsJob).to receive(:perform_later) do |feeds, uid|
      ImportFeedsJob.perform_now(feeds, uid)
    end

    # Stub network calls for feed updates
    allow_any_instance_of(Feed).to receive(:update_feed_items)

    Feed.where(user: user_id).destroy_all
  end

  it "does not create duplicate feeds when importing the same file twice" do
    # First Import
    post "/feeds/import",
      params: { file: opml_file },
      headers: { 'Authorization' => "Bearer #{token}" }

    expect(response).to have_http_status(:accepted)
    expect(Feed.where(user: user_id).count).to eq(3)

    # Verify the specific feeds exist
    expect(Feed.exists?(name: "Daring Fireball", user: user_id)).to be true
    expect(Feed.exists?(name: "Test", user: user_id)).to be true

    # Second Import (with same file)
    post "/feeds/import",
      params: { file: opml_file },
      headers: { 'Authorization' => "Bearer #{token}" }

    expect(response).to have_http_status(:accepted)
    # Count should still be 3
    expect(Feed.where(user: user_id).count).to eq(3)
  end

  it "allows manual creation of duplicates even if they exist" do
    # Create one manually
    Feed.create!(name: "Daring Fireball", uri: "https://daringfireball.net/index.xml", user: user_id)

    # Import
    post "/feeds/import",
      params: { file: opml_file },
      headers: { 'Authorization' => "Bearer #{token}" }

    expect(Feed.where(user: user_id, name: "Daring Fireball").count).to eq(1) # Job should skip the duplicate

    # Manually create another
    expect {
      Feed.create!(name: "Daring Fireball", uri: "https://daringfireball.net/index.xml", user: user_id)
    }.to change(Feed, :count).by(1)

    expect(Feed.where(user: user_id, name: "Daring Fireball").count).to eq(2)
  end
end
