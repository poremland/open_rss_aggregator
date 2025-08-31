class ApplicationRecord < ActiveRecord::Base
	self.abstract_class = true

  def self.app_config
    Rails.application.config.app_config
  end

  def app_config
    self.class.app_config
  end
end
