OpenRss::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # See everything in the log (default is :info)
  config.log_level = :info

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.eager_load = true

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
