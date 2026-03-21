require 'spec_helper'

RSpec.describe "OPML Import", type: :request do
  let(:user_id) { "user123" }
  let(:token) { "valid_token" }
  let(:opml_file) {
    fixture_file_upload(
      Rails.root.join('spec', 'fixtures', 'test.opml'),
      'text/x-opml'
    )
  }

  before do
    allow(JwtService).to receive(:decode).with(token).and_return({ 'user_id' => user_id })
    allow(JwtService).to receive(:valid?).with(token).and_return(true)

    # Create the fixture file
    FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures'))
    File.write(Rails.root.join('spec', 'fixtures', 'test.opml'), <<~XML)
      <opml version="2.0">
        <body>
          <outline text="Tech" title="Tech">
            <outline text="Feed 1" xmlUrl="http://feed1.com" />
          </outline>
        </body>
      </opml>
    XML

    allow(ImportFeedsJob).to receive(:perform_later)
  end

  it "accepts an OPML file and queues the import job" do
    post "/feeds/import",
      params: { file: opml_file },
      headers: { 'Authorization' => "Bearer #{token}" }

    expect(response).to have_http_status(:accepted)
    expect(JSON.parse(response.body)['count']).to eq(1)
    expect(ImportFeedsJob).to have_received(:perform_later).with(
      [{uri: "http://feed1.com", name: "Feed 1", category: "Tech"}],
      user_id
    )
  end

  it "returns error if no file provided" do
    post "/feeds/import",
      params: {},
      headers: { 'Authorization' => "Bearer #{token}" }

    expect(response).to have_http_status(:bad_request)
  end

  it "redirects to login when unauthenticated" do
    post "/feeds/import", params: { file: opml_file }
    expect(response).to have_http_status(:redirect)
  end
end
