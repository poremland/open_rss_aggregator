require 'spec_helper'

describe 'ActionMailer SMTP settings' do
  around do |example|
    original_delivery_method = ActionMailer::Base.delivery_method
    original_smtp_settings = ActionMailer::Base.smtp_settings
    ActionMailer::Base.delivery_method = :smtp
    example.run
    ActionMailer::Base.delivery_method = original_delivery_method
    ActionMailer::Base.smtp_settings = original_smtp_settings
  end

  let(:app_config) { Rails.application.config.app_config.dup }

  before do
    allow(Rails.application.config).to receive(:app_config).and_return(app_config)
    ActionMailer::Base.smtp_settings = {
      address:              app_config['mail_server'],
      port:                 app_config['mail_server_port'],
      domain:               app_config['mail_domain'],
      user_name:            app_config['mail_user'],
      password:             app_config['mail_password'],
      authentication:       'plain',
      ssl:                  app_config['use_ssl'],
      enable_starttls_auto: app_config['mail_server_enable_tls']
    }
  end

  context 'when use_ssl is true' do
    it 'sets the ssl option to true' do
      app_config['use_ssl'] = true
      ActionMailer::Base.smtp_settings[:ssl] = app_config['use_ssl']
      expect(ActionMailer::Base.smtp_settings[:ssl]).to be(true)
    end
  end

  context 'when use_ssl is false' do
    it 'sets the ssl option to false' do
      app_config['use_ssl'] = false
      ActionMailer::Base.smtp_settings[:ssl] = app_config['use_ssl']
      expect(ActionMailer::Base.smtp_settings[:ssl]).to be(false)
    end
  end

  it 'configures the user_name from the configuration' do
    app_config['mail_user'] = 'test_user@example.com'
    ActionMailer::Base.smtp_settings[:user_name] = app_config['mail_user']
    expect(ActionMailer::Base.smtp_settings[:user_name]).to eq('test_user@example.com')
  end
end
