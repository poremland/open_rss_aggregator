class Otp < ApplicationRecord
  before_create :generate_id

  def generate_id
    self.id = SecureRandom.uuid
  end
end
