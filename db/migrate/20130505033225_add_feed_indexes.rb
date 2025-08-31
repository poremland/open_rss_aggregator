class AddFeedIndexes < ActiveRecord::Migration[6.1]
  def up
	add_index :feeds, :uri
  end

  def down
	remove_index :feeds, :uri
  end
end
