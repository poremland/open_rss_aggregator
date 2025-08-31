require 'spec_helper'

describe LoginController, type: :controller do
  describe 'POST #request_otp' do
    it 'creates a new OTP' do
      expect {
        post :request_otp, params: { username: 'test@example.com' }
      }.to change(Otp, :count).by(1)
    end

    it 'sends an email' do
      expect {
        post :request_otp, params: { username: 'test@example.com' }
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'returns a success response' do
      post :request_otp, params: { username: 'test@example.com' }
      expect(response).to be_successful
    end
  end

  describe 'POST #do_login' do
    let(:user) { 'test@example.com' }
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