# Copyright (C) 2025 Paul Oremland
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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