# app/controllers/concerns/jwt_authenticatable.rb
module JwtAuthenticatable
	extend ActiveSupport::Concern

	included do
		before_action :authenticate_with_jwt, except: [:refresh_token]
	end

	private

	def authenticate_with_jwt
		authenticated = false;
		token = request.headers['Authorization']&.split(' ')&.last
		if token.present?
			decoded_token = JwtService.decode(token)
			if decoded_token.present? and JwtService.valid?(token)
				@logged_in_user = "#{decoded_token['user_id']}"
				authenticated = true
			end
		end

		unless authenticated
			redirect_to "#{request.protocol}#{request.host_with_port}/login/login"
		end
	end
end
