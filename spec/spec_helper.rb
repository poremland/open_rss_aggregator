require 'spork'

Spork.prefork do
	ENV["RAILS_ENV"] ||= 'development'

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

	module SpecHelper
	end

	RSpec.configure do |config|
		config.include SpecHelper
		config.mock_with :rspec

		config.before(:each) do
		end
	end
end

Spork.each_run do
	load "#{Rails.root}/config/routes.rb"
	Dir["#{Rails.root}/app/*/*.rb"].each { |f| load f }
	Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end
