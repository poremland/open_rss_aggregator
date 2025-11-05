OpenRss::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.eager_load = false

  # ActionMailer Config
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: Rails.application.config.app_config['mail_domain'] }
  config.action_mailer.smtp_settings = {
    address:              Rails.application.config.app_config['mail_server'],
    port:                 Rails.application.config.app_config['mail_server_port'],
    domain:               Rails.application.config.app_config['mail_domain'],
    user_name:            Rails.application.config.app_config['mail_user'],
    password:             Rails.application.config.app_config['mail_password'],
    authentication:       'plain',
    ssl:                  Rails.application.config.app_config['use_ssl'],
    enable_starttls_auto: Rails.application.config.app_config['mail_server_enable_tls']
  }
end
