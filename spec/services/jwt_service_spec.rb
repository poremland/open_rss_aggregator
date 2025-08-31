require 'spec_helper'

RSpec.describe JwtService, type: :service do
  describe '.encode' do
    it 'sets the expiration to 1 day by default' do
      travel_to Time.zone.now do
        payload = { user_id: 1 }
        token = JwtService.encode(payload)
        decoded_token = JwtService.decode(token)

        expect(decoded_token['exp']).to eq(1.day.from_now.to_i)
      end
    end

    it 'allows overriding the expiration' do
      travel_to Time.zone.now do
        payload = { user_id: 1 }
        expiration = 2.hours.from_now
        token = JwtService.encode(payload, expiration)
        decoded_token = JwtService.decode(token)

        expect(decoded_token['exp']).to eq(expiration.to_i)
      end
    end
  end
end
