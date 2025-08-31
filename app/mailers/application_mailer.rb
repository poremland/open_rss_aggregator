class ApplicationMailer < ActionMailer::Base
  def self.app_config
    Rails.application.config.app_config
  end

  default from: self.app_config['mail_user']
  layout 'mailer'
end

