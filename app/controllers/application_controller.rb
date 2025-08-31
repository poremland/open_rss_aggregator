class ApplicationController < ActionController::API
	include JwtAuthenticatable # Include your JWT authentication concern

	attr_reader :current_user # Make the authenticated user accessible in controllers

	def index
		if request.format.json?
			render json: @feeds
		else
			render xml: @feeds
		end
	end

	protected

	# Override in controller classes that should require authentication
	def secure?
		false # override this in specific controllers
	end

	private
end
