require 'spec_helper'

RSpec.describe "CORS", type: :request do
  let(:origin) { Rails.application.config.app_config['cors_origins'] }

  it "sets the Access-Control-Allow-Origin header for allowed origins" do
    get '/', headers: { 'Origin' => origin }
    expect(response.headers['Access-Control-Allow-Origin']).to eq(origin)
  end

  it "does not set the Access-Control-Allow-Origin header for disallowed origins" do
    get '/', headers: { 'Origin' => 'http://disallowed.host' }
    expect(response.headers['Access-Control-Allow-Origin']).to be_nil
  end
end
