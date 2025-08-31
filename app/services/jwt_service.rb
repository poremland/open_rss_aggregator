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