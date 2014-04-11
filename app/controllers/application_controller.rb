class ApplicationController < ActionController::Base
	helper :all # include all helpers, all the time
	protect_from_forgery

	before_filter :authorize

	def index
		if session["user_id"].nil?
			session["return_to"] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
			redirect_to :controller => "login", :action => "login"
			return false
		end

		respond_to do |format|
			format.html # index.html.erb
			format.xml	{ render :xml => @feeds }
		end
	end

	protected
	# Override in controller classes that should require authentication
	def secure?
		false
	end

	private
	def authorize
		if secure? and session["user_id"].nil?
			session["return_to"] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
			redirect_to :controller => "login", :action => "login"
			return false
		end
	end
end
