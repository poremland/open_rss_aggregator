require 'spec_helper'

RSpec.describe "OPML Export", type: :request do
  let(:user_id) { "user123" }
  let(:token) { "valid_token" }

  before do
    allow(JwtService).to receive(:decode).with(token).and_return({ 'user_id' => user_id })
    allow(JwtService).to receive(:valid?).with(token).and_return(true)
    
    # Create some feeds for the user
    Feed.destroy_all
    FactoryBot.create(:feed, user: user_id, name: "Tech Feed", uri: "http://tech.com", category: "Tech")
    FactoryBot.create(:feed, user: user_id, name: "News Feed", uri: "http://news.com", category: nil)
  end

  it "exports OPML for the authenticated user" do
    get "/feeds/export", headers: { 'Authorization' => "Bearer #{token}" }

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq('text/x-opml')
    expect(response.headers['Content-Disposition']).to include('attachment; filename="subscriptions.opml"')
    
    doc = Nokogiri::XML(response.body)
    expect(doc.xpath('//outline[@type="rss"]').count).to eq(2)
    expect(doc.at_xpath('//outline[@title="Tech Feed"]')).not_to be_nil
    expect(doc.at_xpath('//outline[@title="News Feed"]')).not_to be_nil
    expect(doc.at_xpath('//outline[@title="Tech"]')).not_to be_nil
  end

  it "redirects to login when unauthenticated" do
    get "/feeds/export"
    expect(response).to have_http_status(:redirect)
    expect(response.headers['Location']).to include('/login/login')
  end
end
