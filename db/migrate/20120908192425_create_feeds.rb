class CreateFeeds < ActiveRecord::Migration[6.1]
  def change
    create_table :feeds do |t|
      t.string :uri
      t.string :name
      t.string :user

      t.timestamps
    end
  end
end
