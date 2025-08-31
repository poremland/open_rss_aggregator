require 'spork'

Spork.prefork do
	ENV["RAILS_ENV"] ||= 'test'

	if ENV["COVERAGE"]
		require 'simplecov'
		require 'simplecov-rcov'
		class SimpleCov::Formatter::MergedFormatter
			def format(result)
				SimpleCov::Formatter::HTMLFormatter.new.format(result)
				SimpleCov::Formatter::RcovFormatter.new.format(result)
			end
		end
		SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
		SimpleCov.start 'rails'
	end

	require File.expand_path("../../config/environment", __FILE__)
	require 'rspec/rails'
  require 'shoulda/matchers'

	module SpecHelper
    def generate_jwt_token(user)
      JwtService.encode({ user_id: user.id })
    end
	end

	RSpec.configure do |config|
		config.include SpecHelper
		config.mock_with :rspec
    config.include FactoryBot::Syntax::Methods
    config.include ActiveSupport::Testing::TimeHelpers

    config.before(:suite) do
      # Ensure the test database schema is loaded
      ActiveRecord::Migration.maintain_test_schema!
    end

    Shoulda::Matchers.configure do |shoulda_config|
      shoulda_config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end

	end
end

Spork.each_run do
	load "#{Rails.root}/config/routes.rb"
	Dir[Rails.root.join("app", "**", "*.rb")].each { |f| load f }
	Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end
