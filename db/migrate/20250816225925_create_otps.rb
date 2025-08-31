class CreateOtps < ActiveRecord::Migration[8.0]
  def change
    create_table :otps, id: false do |t|
      t.string :id, primary_key: true
      t.string :otp
      t.string :user_id
      t.datetime :expires_at

      t.timestamps
    end
  end
end
