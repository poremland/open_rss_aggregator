require 'spec_helper'

class MockController < ApplicationController
  include JwtAuthenticatable

  def index
    render plain: 'Authenticated'
  end
end

RSpec.describe JwtAuthenticatable, type: :controller do
  controller(MockController) do
  end

  before do
    # Ensure JwtService is mocked for consistent testing
    allow(JwtService).to receive(:decode).and_return(nil)
    allow(JwtService).to receive(:valid?).and_return(false)
  end

  describe '#authenticate_with_jwt' do
    context 'when a valid JWT token is provided' do
      let(:user_id) { 1 }
      let(:valid_token) { 'valid.jwt.token' }

      before do
        request.headers['Authorization'] = "Bearer #{valid_token}"
        allow(JwtService).to receive(:decode).with(valid_token).and_return({ 'user_id' => user_id })
        allow(JwtService).to receive(:valid?).with(valid_token).and_return(true)
      end

      it 'sets @logged_in_user and allows access' do
        get :index
        expect(controller.instance_variable_get(:@logged_in_user)).to eq(user_id.to_s)
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('Authenticated')
      end
    end

    context 'when no JWT token is provided' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to('/login/login')
      end
    end

    context 'when an invalid JWT token is provided' do
      let(:invalid_token) { 'invalid.jwt.token' }

      before do
        request.headers['Authorization'] = "Bearer #{invalid_token}"
        allow(JwtService).to receive(:decode).with(invalid_token).and_return({ 'user_id' => 999 })
        allow(JwtService).to receive(:valid?).with(invalid_token).and_return(false)
      end

      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to('/login/login')
      end
    end

    context 'when the token is present but not a bearer token' do
      before do
        request.headers['Authorization'] = "NonBearerToken"
      end

      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to('/login/login')
      end
    end
  end
end
