require 'spec_helper'

describe LoginController, type: :controller do
  describe 'POST #request_otp' do
    let(:allowed_domain) { Rails.application.config.app_config['domain_allow_list'] }
    let(:username) { "test@#{allowed_domain}" }
    let(:allowed_domain) { Rails.application.config.app_config['domain_allow_list'] }
    let(:username) { "test@#{allowed_domain}" }
    context 'when the domain is in the allow list' do
      it 'creates a new OTP' do
        expect {
          post :request_otp, params: { username: username }
        }.to change(Otp, :count).by(1)
      end

      it 'sends an email' do
        expect {
          post :request_otp, params: { username: username }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'returns a success response' do
        post :request_otp, params: { username: username }
        expect(response).to be_successful
      end
    end

    context 'when the domain is not in the allow list' do
      it 'does not create a new OTP' do
        expect {
          post :request_otp, params: { username: 'test@disallowed.com' }
        }.to_not change(Otp, :count)
      end

      it 'does not send an email' do
        expect {
          post :request_otp, params: { username: 'test@disallowed.com' }
        }.to_not change { ActionMailer::Base.deliveries.count }
      end

      it 'returns an unauthorized response' do
        post :request_otp, params: { username: 'test@disallowed.com' }
        expect(response).to be_unauthorized
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Email domain is not on the allow list.')
      end
    end
  end

  describe 'POST #do_login' do
    let(:allowed_domain) { Rails.application.config.app_config['domain_allow_list'] }
    let(:username) { "test@#{allowed_domain}" }
    let(:user) { username }
    let(:otp) { '123456' }

    context 'with a valid OTP' do
      before do
        Otp.create(user_id: user, otp: otp, expires_at: 10.minutes.from_now)
      end

      it 'returns a JWT token' do
        post :do_login, params: { username: user, otp: otp, format: :json }
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
      end
    end

    context 'with an invalid OTP' do
      it 'returns an unauthorized error' do
        post :do_login, params: { username: user, otp: 'wrong_otp', format: :json }
        expect(response).to be_unauthorized
      end
    end

    context 'with an expired OTP' do
      before do
        Otp.create(user_id: user, otp: otp, expires_at: 10.minutes.ago)
      end

      it 'returns an unauthorized error' do
        post :do_login, params: { username: user, otp: otp, format: :json }
        expect(response).to be_unauthorized
      end
    end
  end
end
