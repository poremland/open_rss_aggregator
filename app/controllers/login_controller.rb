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

class LoginController < ApplicationController
	include JwtAuthenticatable
	skip_before_action :authenticate_with_jwt, only: [:do_login, :request_otp, :refresh_token]

	def request_otp
		username = params[:username]
		otp = SecureRandom.hex(3)
		user_otp = Otp.new(otp: otp, user_id: username, expires_at: 10.minutes.from_now)
		user_otp.save!

		OtpMailer.otp_email(username, otp).deliver_now

		if request.format.json?
			render json: { login: "otp sent" }, status: :ok
		else
			render xml: { login: "otp sent" }, status: :ok
		end
	end

	def do_login
		username = params[:username]
		otp = params[:otp]

		if username.nil? || otp.nil?
			if request.format.json?
				render json: { login: "failure" }, status: :unauthorized
			else
				render xml: { login: "failure" }, status: :unauthorized
			end
		else
			user_otp = Otp.where(user_id: username).order(created_at: :desc).first

			if user_otp && user_otp.otp == otp && user_otp.expires_at > Time.now
				payload = { user_id: username }
				token = JwtService.encode(payload)

				@logged_in_user = "#{username}"
				response.headers['Authorization'] = "Bearer #{token}"

				if request.format.json?
					render json: { login: "success", token: token }, status: :ok
				else
					render xml: { login: "success", token: token }, status: :ok
				end
			else
				if request.format.json?
					render json: { login: "failure" }, status: :unauthorized
				else
					render xml: { login: "failure" }, status: :unauthorized
				end
			end
		end
	end

	def refresh_token
		token = request.headers['Authorization']&.split(' ')&.last
		if token.present? && JwtService.valid?(token)
			decoded_token = JwtService.decode(token)
			new_token = JwtService.encode({ user_id: decoded_token['user_id'] })
			render json: { token: new_token }
		else
			render json: { error: 'Invalid or expired token' }, status: :unauthorized
		end
	end

	def do_logout
		@logged_in_user = nil
		redirect_to "#{request.protocol}#{request.host_with_port}"
	end
end