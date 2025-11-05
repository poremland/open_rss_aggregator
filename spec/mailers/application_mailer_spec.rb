require 'spec_helper'

describe ApplicationMailer, type: :mailer do
  let(:app_config) { Rails.application.config.app_config.dup }

  before do
    allow(Rails.application.config).to receive(:app_config).and_return(app_config)
  end

  describe 'from address' do
    it 'is configured from mail_from' do
      app_config['mail_from'] = 'test_from@example.com'
      # Reload the mailer to apply the new default from
      load 'app/mailers/application_mailer.rb'
      expect(ApplicationMailer.default[:from]).to eq('test_from@example.com')
    end

    it 'is used in sent emails' do
      app_config['mail_from'] = 'test_from@example.com'
      # Reload the mailer to apply the new default from
      load 'app/mailers/application_mailer.rb'

      # Create a temporary mailer to avoid polluting ApplicationMailer
      test_mailer = Class.new(ApplicationMailer) do
        def test_email
          mail(to: 'test@example.com', subject: 'test', body: 'test body')
        end
      end

      email = test_mailer.test_email.deliver_now
      expect(email.from).to include('test_from@example.com')
    end
  end
end
