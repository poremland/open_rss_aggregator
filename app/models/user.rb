class User
	def User.login(username, password)
		if (APP_CONFIG["mail_server_enable_tls"] || false)
			Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
			STDERR.puts("Enabling TLS")
		end

		smtp = Net::SMTP.new(APP_CONFIG["mail_server"], APP_CONFIG["mail_server_port"] || 25)
		begin
			smtp.start(APP_CONFIG["mail_domain"], username, password, :login)
			success = smtp.started?
			smtp.finish
		rescue Exception => e  
			puts e.message  
			puts e.backtrace.inspect 
			success = false
		end
		puts("Login Success: " + success.to_s);
	
		return success
	end
end

