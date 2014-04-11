class LoginController < ApplicationController
	protect_from_forgery :except => :do_login

	def login
puts "Session: #{session["user_id"]}"
		if session["user_id"].nil?
			respond_to do |format|
				format.html 
			end
		else
			redirect_to :controller => "application", :action => "index"
		end
	end

	def do_login
		username = params[:username]
		password = params[:password]

		if username.nil? || password.nil? || username==password
			respond_to do |format|
				format.json { render :json => { :login => "failure" } }
				format.html { redirect_to :action => "login" }
				format.xml { redirect_to :action => "login" }
			end
		else
			success = User.login(username, password)
			if success
				session["user_id"] = username

				respond_to do |format|
					format.json { render :json => { :login => "success" } }
					format.html { redirect_to :controller => "application", :action => "index" }
					format.xml { redirect_to :controller => "application", :action => "index" }
				end
			else
				respond_to do |format|
					format.json { render :json => { :login => "failure" } }
					format.html { redirect_to :action => "login" }
					format.xml { redirect_to :action => "login" }
				end
			end
		end
	end

	def do_logout
		session["user_id"] = nil
		redirect_to :action => "login"
	end
end
