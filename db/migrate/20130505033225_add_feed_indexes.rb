class AddFeedIndexes < ActiveRecord::Migration
  def up
	add_index :feeds, :uri
  end

  def down
	remove_index :feeds, :uri
  end
end
