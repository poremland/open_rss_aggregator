# app/services/jwt_service.rb
module JwtService
	class << self
		def encode(payload, expiration = 1.days.from_now)
			payload[:exp] = expiration.to_i
			JWT.encode(payload, OpenRss::Application.config.secret_token, 'HS256')
		end

		def decode(token)
			JWT.decode(token, OpenRss::Application.config.secret_token, true, { algorithm: 'HS256' })[0]
		rescue JWT::DecodeError
			nil
		end

		def valid?(token)
			payload = decode(token)
			return false unless payload

			expiration = payload["exp"]
			now = 0.seconds.from_now.to_i
			(expiration - now) > 0
		end
	end
end
